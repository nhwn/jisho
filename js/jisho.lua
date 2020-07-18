--[[
Author: Nathan Nguyen

Forgive me, father, for using global variables; interdependent callbacks suck.

This is the uncompressed source code for the Lua script that powers Jisho. Note
that you need to initialize the terms and definitions with equally-sized arrays 
of string literals for this to work properly. This is done externally in the
website, so if you're playing with this on your own, you need to directly 
initialize your data.

Here's how end users should use it:
1. Open the document
2. If the top box isn't focused already, use the mouse to click and focus it
3. Type a query and watch the results change live
4. Press <Enter> to switch focus from the search box to the results box
5. Use the arrow keys to navigate to the word you're looking for
6. Press <Enter> to view the definition of the word under the cursor
7. Press <Esc> when you're done viewing to return to the results list
8. Press <Esc> again to switch focus back to the search box
- If you want to change the font size of the results or only search the terms,
press <Menu>, navigate to the option you want, and press <Enter>.

Here's how it works at a high level:
1. Get sanitized query from user
2. For each term and definition, check if query is inside 
3. If so, save the matching term and definition into respective lists
3. Create a list of ranges of cursor positions based on matching term length
4. Show the list of matching terms to the user
5. For each range, check if current cursor position is inside it
6. If so, use the index of that range to get definition of selected term
7, Show the definition to the user

Here's some notes about the design:
- If the query is nil, lookup() will match on all terms. This also allows us to
populate the results with all the terms on startup without user input.
- When lookup() is iterating over the terms and definitions, it performs a 
hardcoded case-insensitive search. In addition, it will look for the query in 
the term AND the definition by default.
- cursorBounds is initialized with a -1 to allow the formula in the 
cursorBounds loop to work properly
- #cursorBounds == #terms + 1 because we need to iterate over ranges of cursor
positions, and each range is determined by 2 adjacent values in cursorBounds
- Even though iterating over cursorBounds is a linear search, I haven't seen
any performance bottlenecks there; the main culprit is setting the display
string of the results box
- #terms == #definitions and #matchedTerms == #matchedDefinitions
- In an early design, I tried storing the terms and definitions in a table that 
mapped terms to definitions. It was a bad idea because I had to sort a new table 
to get alphabetical ordering, and I didn't know about the whole string hashing 
overhead. I settled on keeping separate arrays, and I saw a ~2x improvement in
speed. 
- I experimented with attaching listeners to arrowUp and arrowDown events to 
increment/decrement the results row index, but it was easy to cause a crash or
unexpected behavior if you use the mouse to click around (and preventing mouse 
clicks from propagating doesn't work). Since I want to prioritize being 
user-friendly, I decided to go with the current O(n) solution (which couples 
the actual row index with the cursor position) instead of an O(1) one (which 
decouples the row index and cursor position). In practice, I haven't noticed
any visible performance hit, so I think it's fine.

Example of how cursor bounds are checked:

┌─────────────────
│hello -- i = 1
│world -- i = 2
│

This will set cursorBounds = {-1, 5, 11}. getExpressionSelection() will 
return values in [0, 5] if the cursor is anywhere on the first line and values 
in [6, 11] for the 2nd line. From this, we can deduce that we need to check 
inclusively between cursorBounds[i] + 1 and cursorBounds[i + 1]. Note that 
the # of values in each range == matchedTerms[i]:len() + 1 since the cursor 
is the weird | one and lies between individual characters.

Here's a couple of Lua things to know:
- arrays are just tables (but optimized as of Lua 5.0)
- starting index is conventionally set to 1
- liberally use local; possible performance boost
- the # operator returns the number of entries in a table
- nil and 0 evaluate to false in boolean expressions; everything else is true
- next(table) evaluates to false if table is empty and true otherwise
- omit {} or "" in function call if the table/string is the only argument;
e.g. f({}) can be f{}
- Lua tables are unordered, so don't try to rely on accessing in insertion-order
- A ? B : C can be approximated by A and B or C as long as B is never false 

--]]

platform.apilevel = "2.3"
local terms, definitions, cursorBounds = {}, {}, {-1} 
local searchTermsAndDefinitions = true
local searchBar, results = D2Editor.newRichText(), D2Editor.newRichText()
-- uninitialized since initial call to on.resize() will take care of them
local matchedDefinitions, displayString, width, height, viewingDefinition

local function lookup()
    local query = searchBar:getText()
    query = query and query:match("^%s*(.-)%s*$"):lower() or nil
    local matchedTerms = {}
    matchedDefinitions = {}
    if not query then
        matchedTerms = terms
        matchedDefinitions = definitions
    else
        for i = 1, #terms do
            if terms[i]:lower():find(query, 1, true) 
                or searchTermsAndDefinitions 
                and definitions[i]:lower():find(query, 1, true) 
            then    
                matchedTerms[#matchedTerms + 1] = terms[i]
                matchedDefinitions[#matchedDefinitions + 1] = definitions[i]
            end
        end
    end
    viewingDefinition = false
    displayString = ""
    if not next(matchedTerms) then
        results:setText(displayString)
    else 
        local accumulator = 0
        for i = 1, #matchedTerms do
            accumulator = accumulator + matchedTerms[i]:len() + 1
            cursorBounds[i + 1] = accumulator - 1
        end
        -- display results and place cursor on first word
        displayString = table.concat(matchedTerms, "\n")
        results:setExpression(displayString, cursorBounds[2], cursorBounds[2])
    end
end
function on.resize(w, h)
    local cursorPosition
    width, height = w, h
    searchBar
    :move(width * 0.015, height * 0.03)
    :resize(width * 0.975, height * 0.11)
    :setMainFont("sansserif", "r", 9)
    :setTextChangeListener(lookup)
    :setFocus()
    :registerFilter { enterKey = function() results:setFocus() end }
    results
    :move(width * 0.015, height * 0.17)
    :resize(width * 0.975, height * 0.81)
    :setMainFont("sansserif", "r", 9)
    :setReadOnly()
    :registerFilter { 
    enterKey = function()
        if not viewingDefinition and displayString ~= "" then
            _, cursorPosition = results:getExpressionSelection()
            for i = 1, #matchedDefinitions  do
                if cursorPosition >= cursorBounds[i] + 1 
                    and cursorPosition <= cursorBounds[i + 1] 
                    then
                        results:setText(matchedDefinitions[i])     
                        viewingDefinition = true
                        return  -- return early to avoid testing higher bounds
                    end
                end
            end
    end,
    escapeKey = function()
        if viewingDefinition then
            -- go back to list of terms if viewing definition
            results:setExpression(displayString, cursorPosition, cursorPosition)
            viewingDefinition = false
        else
            -- switch focus to search bar if viewing terms list 
            searchBar:setFocus()
        end
    end
    }
    -- start out with a list of everything (nil query)
    lookup()
end
function on.paint(gc)
    gc:drawRect(width * 0.01, height * 0.02, width * 0.98, height * 0.12)
    gc:drawRect(width * 0.01, height * 0.165, width * 0.98, height * 0.82)
end
toolpalette.register {
    { "Search Options",
        {"Terms Only", function() searchTermsAndDefinitions = false end},
        {"Terms and Defs", function() searchTermsAndDefinitions = true end},
    },
    { "Font Sizes",
        { "9", function() results:setFontSize(9) end},
        { "12", function() results:setFontSize(12) end},
        { "16", function() results:setFontSize(16) end},
        { "24", function() results:setFontSize(24) end},
    }
}
