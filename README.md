# Jisho

Jisho is a web-based tool for generating custom searchable dictionaries for the TI-Nspire CX calculator series. 

To use it, head to [https://nhwn.github.io/jisho](https://nhwn.github.io/jisho). There, you'll find a demo, usage instructions, and the dictionary creation tool itself.

## Developer notes

Jisho is basically a glorified Lua script. The website is just a means of initializing said script with the user's terms and definitions.

The general build process of the script goes something like this:

1. Get terms and definitions from the user via Quizlet HTML, JSON, or manual input through the editor.
2. Inject the terms and definitions into the Lua script template (although it's really the whole program, sans the global tables).
3. Embed the created script into a .tns file.
4. Download the .tns file.

All of the magic happens in the `js` directory. 
- `index.js` houses the main logic for running the website's editor. 
- `htmlToString.js` is a crudely [browserified](http://browserify.org/) version of [html-to-text](https://www.npmjs.com/package/html-to-text). I literally spent an hour looking for a robust solution for converting something like `3 &lt; 4 <br> yes` into `3 < 4 \n yes`, and that package answered my prayers (I couldn't find any native browser solutions). It's necessary for parsing Quizlet HTML into its proper plaintext form, so its insane code bloat is a tradeoff I'm willing to make.
- `saveAs.js` is a minified version of [FileSaver.js](https://github.com/eligrey/FileSaver.js/). It's necessary for saving the .tns to the user's machine. Even though there are CDN versions available, I like having local copies of everything. Sue me ¯\\\_(ツ)\_/¯.

- `luna.js` is a minified, standalone version of [Luna](https://github.com/ndless-nspire/luna/tree/84d64c3906e46e198b678d653bb9cd4cff22752b). It's necessary for generating the .tns file.
- `jisho.lua` is the actual script that gets embedded in the .tns file. There are a bunch of other notes inside here regarding how the script works.
- `minify-lua.sh` is a hackity hackity build script for generating the corresponding Javascript to put in `index.js`. Note that it depends on [luamin](https://github.com/mathiasbynens/luamin) for minifying `jisho.lua`.

Someday, I'll get a proper build system. **Someday**.
