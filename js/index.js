// stuff that cares about the DOM

const table = document.getElementById('entries');
const rows = table.children;
const toggle = document.getElementById('toggle');

function createRow(initialIndex, term = '', definition = '') {
    const row = document.createElement('tr');
    const checkbox = document.createElement('input');
    checkbox.type = 'checkbox';
    const checkboxWrapper = document.createElement('td');
    checkboxWrapper.appendChild(checkbox);
    const displayedIndex = document.createElement('td');
    displayedIndex.innerHTML = initialIndex + 1;
    const termInput = document.createElement('td');
    termInput.className = 'term';
    termInput.contentEditable = 'true';
    termInput.innerText = term;
    const definitionInput = document.createElement('td');
    definitionInput.innerText = definition;
    definitionInput.className = 'definition';
    definitionInput.contentEditable = 'true'; 
    row.appendChild(checkboxWrapper);
    row.appendChild(displayedIndex);
    row.appendChild(termInput);
    row.appendChild(definitionInput);
    return row;
}

function appendRow() {
    const row = createRow(table.children.length);
    table.appendChild(row);
}

function appendRows(terms, definitions) {
    const frag = document.createDocumentFragment();
    for (const [i, term] of terms.entries()) {
        const row = createRow(i + rows.length, term, definitions[i]);
        frag.appendChild(row);
    }
    table.appendChild(frag);
}

function readRows() {
    const terms = Array.from(document.querySelectorAll('.term'))
        .map(node => node.innerText.trim());
    const definitions = Array.from(document.querySelectorAll('.definition'))
        .map(node => node.innerText.trim());
    const dictionary = zipToObject(terms, definitions);
    // no blank terms
    delete dictionary[''];
    return sortObject(dictionary);
}

function deleteSelectedRows() {
    // raw loop access in reverse since length changes on removal
    for (let i = rows.length - 1; i >= 0; i--) {
        if (rows[i].firstChild.firstChild.checked) {
            rows[i].remove();
        }
    }
    // renumber rows with raw loop because we need to mutate in place
    for (let i = 0; i < rows.length; i++) {
        rows[i].children[1].innerHTML = i + 1;
    }
    toggle.checked = false;
}

function toggleCheckboxes(checkboxNode) {
    for (const row of rows) {
        row.firstChild.firstChild.checked = checkboxNode.checked;
    }
}

// stuff that doesn't care about the DOM as much

function importFromQuizletHTML() {
    const input = prompt('Paste your Quizlet HTML source code into the box below.', '');
    if (input !== '') {
        try {
            const [terms, definitions] = parseQuizletHTML(input);
            appendRows(terms, definitions);
        }
        catch (e) {
            alert(e);
        }
    }
}

function importFromJSON() {
    const input = prompt('Paste your JSON data into the box below.', '');
    if (input !== '') {
        try {
            const parsedObject = JSON.parse(input);
            const terms = Object.keys(parsedObject);
            const definitions = Object.values(parsedObject);
            appendRows(terms, definitions);
        }
        catch (e) {
            alert(e);
        }
    }
}

function downloadTNS() {
    const dictionary = readRows();
    const script = createLuaScript(dictionary);
    const buffer = [luna.createTNS(script)];
    const blob = new Blob(buffer, {type: 'application/octet-stream'});
    saveAs(blob, 'jisho.tns');
}

function createLuaScript(dictionary) {
    const terms = Object.keys(dictionary).map(JSON.stringify).join(',');
    const definitions = Object.values(dictionary).map(JSON.stringify).join(',');
    return String.raw`platform.apilevel="2.3"local a,b,c={${terms}},{${definitions}},{-1}local d=true;local e,f=D2Editor.newRichText(),D2Editor.newRichText()local g,h,i,j,k;local function l()local m=e:getText()m=m and m:match("^%s*(.-)%s*$"):lower()or nil;local n={}g={}if not m then n=a;g=b else for o=1,#a do if a[o]:lower():find(m,1,true)or d and b[o]:lower():find(m,1,true)then n[#n+1]=a[o]g[#g+1]=b[o]end end end;k=false;h=""if not next(n)then f:setText(h)else local p=0;for o=1,#n do p=p+n[o]:len()+1;c[o+1]=p-1 end;h=table.concat(n,"\n")f:setExpression(h,c[2],c[2])end end;function on.resize(q,r)local s;i,j=q,r;e:move(i*0.015,j*0.03):resize(i*0.975,j*0.11):setMainFont("sansserif","r",9):setTextChangeListener(l):setFocus():registerFilter{enterKey=function()f:setFocus()end}f:move(i*0.015,j*0.17):resize(i*0.975,j*0.81):setMainFont("sansserif","r",9):setReadOnly():registerFilter{enterKey=function()if not k and h~=""then _,s=f:getExpressionSelection()for o=1,#g do if s>=c[o]+1 and s<=c[o+1]then f:setText(g[o])k=true;return end end end end,escapeKey=function()if k then f:setExpression(h,s,s)k=false else e:setFocus()end end}l()end;function on.paint(t)t:drawRect(i*0.01,j*0.02,i*0.98,j*0.12)t:drawRect(i*0.01,j*0.165,i*0.98,j*0.82)end;toolpalette.register{{"Search Options",{"Terms Only",function()d=false end},{"Terms and Defs",function()d=true end}},{"Font Sizes",{"9",function()f:setFontSize(9)end},{"12",function()f:setFontSize(12)end},{"16",function()f:setFontSize(16)end},{"24",function()f:setFontSize(24)end}}}`
}

function zipToObject(a, b) {
    // assume lengths are equal
    return a.reduce((acc, cur, i) => {
        acc[cur] = b[i];
        return acc;
    }, {})
}

function sortObject(o) {
    return Object.keys(o).sort().reduce((a, c) => (a[c] = o[c], a), {})
}

function parseQuizletHTML(html) {
    const domparser = new DOMParser();
    const doc = domparser.parseFromString(html, 'text/html');
    const terms = Array.from(doc.querySelectorAll('.SetPageTerm-wordText'))
        .map(term => htmlToString.convert(term.firstChild.innerHTML));
    const definitions = Array.from(doc.querySelectorAll('.SetPageTerm-definitionText'))
        .map(definition => htmlToString.convert(definition.firstChild.innerHTML));
    return [terms, definitions];
}

