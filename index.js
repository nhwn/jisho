function zipToObject(a, b) {
    let c = {};
    a.forEach((e, i) => {
        c[e] = b[i];
    }) 
    return c;
}
function downloadTNS(script) {
    saveAs(
        new Blob([luna.createTNS(script)], {
            type: 'application/octet-stream',
        }),
        'script.tns'
    );
}
function clearEntries() {
    document.querySelectorAll('.entry').forEach(entry => {
        entry.remove();
    });
}
function createResizingTextArea() {
    let textarea = document.createElement('textarea');
    textarea.setAttribute('rows', 1);
    let offset = textarea.offsetHeight - textarea.clientHeight;
    textarea.addEventListener('input', function(event) {
        event.target.style.height = 'auto';
        event.target.style.height = event.target.scrollHeight + offset + 'px';
    });
    return textarea;
}
function sortObject(object) {
    return Object.keys(object).sort().reduce((a, c) => (a[c] = object[c], a), {})
}

function createEntry() {
    let entry = document.createElement('div');
    let termInput = createResizingTextArea();
    let definitionInput = createResizingTextArea();
    let deleteEntryButton = document.createElement('button');
    let separator = document.createElement('div');

    entry.setAttribute('class', 'entry')

    termInput.setAttribute('class', 'term')
    termInput.setAttribute('placeholder', 'term')
    definitionInput.setAttribute('placeholder', 'definition')
    definitionInput.onblur = function() {
    }
    definitionInput.setAttribute('class', 'definition')
    deleteEntryButton.onclick = function() {
        entry.remove();
    }
    deleteEntryButton.innerHTML = 'Delete entry'
    separator.setAttribute('class', 'separator')

    entry.appendChild(termInput);
    entry.appendChild(separator)
    entry.appendChild(definitionInput);
    entry.appendChild(deleteEntryButton);

    return entry;
}
function test() {
    let dictionary = readEntries();
    let script = createLuaScript(dictionary);
    downloadTNS(script);
}
function addEntry() {
    let entry = createEntry();
    document.getElementById('entries').appendChild(entry);
}
function readEntries() {
    let terms = Array.from(document.querySelectorAll('.term'))
        .map(node => node.value);
    let definitions = Array.from(document.querySelectorAll('.definition'))
        .map(node => node.value);
    return zipToObject(terms, definitions);
}
function populateEntries(inputObject) {
    let frag = document.createDocumentFragment();
    for (const [key, value] of Object.entries(inputObject)) {
        let entry = createEntry();
        entry.children[0].value = key;
        entry.children[2].value = value;
        frag.appendChild(entry);
    }
    document.getElementById('entries')
        .insertBefore(frag, document.getElementById('add'));
}
function parseQuizletHTML(html) {
    const domparser = new DOMParser();
    const doc = domparser.parseFromString(html, 'text/html');
    const terms = Array.from(doc.querySelectorAll('.SetPageTerm-wordText'))
        .map( element => element.childNodes[0].innerText);
    const definitions = Array.from( doc.querySelectorAll('.SetPageTerm-definitionText'))
        .map(element => element.childNodes[0].innerText);
    return zipToObject(terms, definitions);
}
function createLuaScript(dictionary) {
    dictionary = sortObject(dictionary);
    let terms = Object.keys(dictionary).map(key => JSON.stringify(key.trim())).join(',');
    let defs = Object.values(dictionary).map(value => JSON.stringify(value.trim())).join(',');
    return String.raw`platform.apilevel="2.5"local a=true;local b=true;local c=D2Editor.newRichText()local d=D2Editor.newRichText()local e={${terms}}local f={${defs}}local g={}local h={-1}local i=""local j=0;local k=0;local l=false;toolpalette.register{{"Search Options",{"Auto",function()a=true end},{"Manual",function()a=false end},{"Term Only",function()b=false end},{"Term and Def Search",function()b=true end}},{"Font Sizes",{"9",function()d:setFontSize(9)end},{"12",function()d:setFontSize(12)end},{"16",function()d:setFontSize(16)end},{"24",function()d:setFontSize(24)end}}}local function m()l=false;local n=c:getText()n=n==nil and""or n:match"^%s*(.-)%s*$"g={}for o=1,#e do if n==""or e[o]:lower():find(n:lower())or b and f[o]:lower():find(n:lower())then g[#g+1]=e[o]end end;i=""if next(g)==nil then d:setText(i)return end;i=table.concat(g,"\n")local p=0;for o=1,#g do p=p+g[o]:len()+1;h[o+1]=p-1 end;d:setExpression(i,h[2],h[2])end;function on.resize(q,r)local s=0;j=q;k=r;c:move(j*0.015,k*0.03):resize(j*0.975,k*0.11):setMainFont("sansserif","r",9):setTextChangeListener(function()if a then m()end end):setFocus():registerFilter{enterKey=function()if not a then m()end;d:setFocus()end}d:move(j*0.015,k*0.17):resize(j*0.975,k*0.81):setMainFont("sansserif","r",7):setReadOnly():registerFilter{enterKey=function()if not l and i~=""then _,s=d:getExpressionSelection()for o=1,#h do if s>=h[o]+1 and s<=h[o+1]then local t;for u=1,#e do if e[u]==g[o]then t=u;break end end;d:setExpression(f[t],0,0)l=true;return end end end end,escapeKey=function()if l then d:setExpression(i,s,s)l=false else c:setFocus()end end}m()end;function on.paint(v)v:drawRect(j*0.01,k*0.02,j*0.98,k*0.12)v:drawRect(j*0.01,k*0.165,j*0.98,k*0.82)end`
}
