--[[
Forgive me, father, for using global variables (these callbacks depend on reading global state)

Dear future me, here are some lua idioms/tips that you'll probably forget:
    - arrays are just tables, and the starting index is at 1
    - next(table) == nil to see if table is empty
    - omit {} or "" in function call if the table/string is the only argument (e.g. f({}) -> f{})
    - Lua tables are unordered, so don't try to rely on accessing in insertion-order
    - a ? b : c can be approximated by a and b or c in most cases

This program revolves around 2 textboxes: @searchBar and @results. Whenever a user types a query in @searchBar, the textbox calls lookup(). lookup() examines the contents of @searchBar, trims it, then iterates 
through @terms (and @definitions by default) in a case-insensitive search. If it finds a match, the corresponding term is appended to @matches. Next, @displayString is constructed by joining @matches with newlines, the indexes of each word boundary (this is stored in @wordBoundaries).

@results
┌─────────────
│hello
│world
│
│

This will set @wordBoundaries to {-1, 5, 11}. 



--]]
platform.apilevel = "2.5"
-- reload results when query changes by default
local liveUpdate = true
-- search both term and definition for query by default
local searchTermsAndDefinitions = true
local searchBar = D2Editor.newRichText()
local results = D2Editor.newRichText()
-- I decided to use separate arrays instead of a table with terms as keys and definitions as values to avoid hashing (crude benchmark showed over 2x speedup). The old method also involved calls to a sorting function on every lookup for alphabetical ordering, so the new array method bypasses this by offloading the sorting to the browser (we don't need to do anything because the indexes effectively hardcode the sequential order)
local terms = {
    -- inject terms here
}
local definitions = {
    -- inject definitions here
}
-- stores all the strings that match the query 
local matches = {}
local wordBoundaries = {-1}
local displayString = ""
local width = 0
local height = 0
local viewingDefinition = false
toolpalette.register {
    {"Search Options",
        {"Auto", function() liveUpdate = true end},
        {"Manual", function() liveUpdate = false end},
        {"Term Only", function() searchTermsAndDefinitions = false end},
        {"Term and Def Search", function() searchTermsAndDefinitions = true end},
    },
    {"Font Sizes",
            {"9", function() results:setFontSize(9) end},
            {"12", function() results:setFontSize(12) end},
            {"16", function() results:setFontSize(16) end},
            {"24", function() results:setFontSize(24) end},
    }
}
local function lookup()
    viewingDefinition = false
    local query = searchBar:getText()
    query = query == nil and "" or query:match"^%s*(.-)%s*$"   
    matches = {}
    -- empty query is wildcard, always use case insensitive search
    for i = 1, #terms do
        if query == "" or terms[i]:lower():find(query:lower()) or searchTermsAndDefinitions and definitions[i]:lower():find(query:lower()) then    
            matches[#matches + 1] = terms[i]
        end
    end
    -- displayString must be global so enterKey handler can see it
    displayString = ""
    -- sets results textbox to empty if there aren't any matches and immediately returns
    if next(matches) == nil then
       results:setText(displayString)
       return
    end
    displayString = table.concat(matches, "\n")
    local accumulator = 0
    for i = 1, #matches do
        accumulator = accumulator + matches[i]:len() + 1
        wordBoundaries[i + 1] = accumulator - 1
    end
    -- set results textbox to the contents of displayString with the cursor index on the first word
    results:setExpression(displayString, wordBoundaries[2], wordBoundaries[2])
end
-- entry point
function on.resize(w, h)
    local cursorPosition = 0
    width = w
    height = h
    -- set up search bar textbox
    searchBar:move(width * 0.015, height * 0.03)
    :resize(width * 0.975, height * 0.11)
    :setMainFont("sansserif","r", 9)
    :setTextChangeListener(function() if liveUpdate then lookup() end end)
    :setFocus()
    :registerFilter { 
        enterKey = function()
            -- we don't need to call lookup again if we have live updates
            if not liveUpdate then
                lookup()
            end
            results:setFocus()
        end
    }
    -- set up results textbox
    results:move(width * 0.015, height * 0.17)
    :resize(width * 0.975, height * 0.81)
    :setMainFont("sansserif","r", 7)
    :setReadOnly()
    :registerFilter { 
        enterKey = function()
            if not viewingDefinition and displayString ~= "" then
                -- cursorPosition is global so the escapeKey handler can put the cursor back where it was before after we're done viewing the definition
                -- getExpressionSelection returns 3 values, but we only care about the position of the cursor (an integer describing the location in the string, starting at 0)
                _, cursorPosition = results:getExpressionSelection()
                for i = 1, #wordBoundaries do
                    -- if cursorPosition falls within the bounds of the word under the cursor, immediately return (we don't need to keep looking since we found the range)
                    if cursorPosition >= wordBoundaries[i] + 1 and cursorPosition <= wordBoundaries[i + 1] then
                        local index
                        for j = 1, #terms do
                            if terms[j] == matches[i] then
                                index = j
                                break
                            end
                        end
                        results:setExpression(definitions[index], 0, 0)     
                        viewingDefinition = true
                        return
                    end
                end
            end
        end,
        escapeKey = function()
            if viewingDefinition then
                -- go back to list of matches since we're done viewing definition
                results:setExpression(displayString, cursorPosition, cursorPosition)
                viewingDefinition = false
            else
                -- go back to search bar if we're currently viewing the list of matches
                searchBar:setFocus()
            end
        end
    }
    -- do lookup so we can start out with a list of everything
    lookup()
end
function on.paint(gc)
    gc:drawRect(width * 0.01, height * 0.02, width * 0.98, height * 0.12)
    gc:drawRect(width * 0.01, height * 0.165, width * 0.98, height * 0.82)
end
