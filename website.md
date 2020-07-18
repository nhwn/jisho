# Jisho
Jisho is a web-based tool for generating custom searchable dictionaries for the TI-Nspire CX calculator series. To learn how to use it, just keep scrolling down. If you want to jump right in to making your own dictionary, click [here](#editor) to jump to the editor.

<video autoplay loop muted width="500" playsinline>
    <source src="assets/demo.webm" type="video/webm">
    <source src="assets/demo.mp4" type="video/mp4">
</video>

## Overview
Jisho is a great alternative to using the built-in notes or an external PDF viewer for quickly looking up textual information. Since it just produces a standalone .tns file, there's no need for 3rd party software like Ndless. As long as the calculator's operating system is 3.6 or higher, Jisho will work on any CX series calculator, including non-CAS, CAS, and CX II models. The minimum required operating system is fairly old, so you're probably good to go. If you need to [check the version](https://www.vernier.com/til/1725) or [upgrade to a newer operating system](https://education.ti.com/en/software/update/ti-nspire-software-update), click the provided links for further instructions.

There are 2 parts to Jisho: a browser-based dictionary editor and an executable .tns file containing the actual dictionary. The process of making your own dictionaries is pretty straightforward:

1. Import or type your terms and definitions into the dictionary editor.
2. Click the "Download .tns" button to download the executable .tns file.
3. Plug your calculator into your computer with a mini-USB cable.
4. Use TI's [Student Software](https://education.ti.com/en/software/details/en/a78091cd540843d68ab8ee5853c84828/student-nspirecx) or [Computer Link](https://education.ti.com/en/products/computer-software/ti-nspire-computer-link) to send the .tns file to your calculator. [Here's](https://www.dummies.com/education/graphing-calculators/how-to-send-and-receive-ti-nspire-files-or-folders/) some instructions if you're not sure how to do this.
5. Open the .tns file on your calculator.
6. Profit.

The next sections provide more detailed information on how to use the editor and the dictionary.

## Using the dictionary

### Basics

When you open the .tns file on your calculator, you'll see two boxes. The top box is for entering the keywords you want to search for, and the lower box will display the matching results in alphabetical order. If the top box isn't automatically focused on startup, use the trackpad mouse to click on it. As you type characters into the search box, the matching terms in the results box will be updated in real-time.

- To focus the results box, press `enter` while the search box is focused to move the cursor to the results box. 
- To navigate the cursor around in the results box, press the arrow keys. You can keep scrolling down if there's too many results to fit in one screen.
- To show the definition of the word under the cursor, press `enter`. Note that the horizontal position of the cursor doesn't matter; only the row position matters.
- To navigate the cursor around in the results box, press the arrow keys. You can keep scrolling down if the definition is too long to fit in one screen.
- To stop viewing the definition of a word, press `esc`. This will take you back to the previous list of results. You can then navigate to another word using the arrow keys.
- To focus the search box, press `esc` while the results box is focused to move the cursor to the search box. You can then press `del` to make room for a new query.
- To quit the dictionary, press `doc`, select "File", then select "Close". When the calculator asks if you want to save your changes, select "No".

### Extra notes

- An empty query will match all possible terms in the dictionary.
- The search will always be case-insensitive.
- Using the mouse to focus each box is discouraged. Use the keyboard shortcuts to get around.
- By default, both the terms and definitions will be searched. As a result, a term will match even if it doesn't physically contain the query (as long as its corresponding definition does). You can disable this if you want (more on this below).

### Configuration

If you want to change the search behavior or font size, press the `menu` button on your calculator to bring up the configuration menu. Navigate to the option you want to change, then press `enter`. Changes will take place immediately.

- Search Options
    - Terms Only - Search only the list of terms to determine matching results.
    - Terms and Defs (default) - Search both the list of terms and definitions to determine matching results. 
- Font Sizes
    - 9 (default) - Set the font size to 9.
    - 12 - Set the font size to 12.
    - 16 - Set the font size to 16.
    - 24 - Set the font size to 24.

## Using the editor

### Basics

The dictionary editor displays a table of all the possible terms and definitions that will be used to create your dictionary.

- To change the value of an entry, just click on it, and start typing away.
- To add more rows, click the "Add Row" button.
- To delete a row, click its checkbox, then click the "Delete Selection" button.
- To delete all the rows, click the top left checkbox, then click the "Delete Selection" button.
- To download the .tns file, click the "Download .tns" button.

### Things to look out for

- If you have duplicate terms, the definition of the term with the highest number will be used.
- If you have any blank terms, their entry will be discarded during the creation of the .tns file.
- Line breaks are not added unless you actually press `Enter`; otherwise, it's just a visual line break.
- The terms will be sorted in alphabetical order during the creation of the .tns file, so the order you see in the editor is not the order in the actual dictionary.
- The downloaded .tns file will always be named "jisho.tns", so you should rename your files accordingly if you have multiple dictionaries.
- Calculator support for non-printable ASCII characters isn't the greatest. I just got lucky with the kanji in the demo, so you might run into issues with displaying Unicode characters. As a workaround, type out the phonetic equivalent (e.g. write √ as sqrt). This will also make finding results easier since your search keywords will probably just consist of alphanumeric characters.

### Importing from Quizlet

To import the flashcards from a Quizlet, click the "Import Quizlet" button. This will prompt you to paste in the HTML source code of the target Quizlet. 

If you're not sure how to get the HTML source code of a website, here's how you do it:

1. Right-click anywhere on the target page.
2. Click the option that says "View Page Source" (this is for Chrome; the exact option may vary from browser to browser).
3. Select and copy the entire region of text. You can use `Control-a` and `Control-c` to do this (use `Command` instead of `Control` if you're on a Mac).

After you're done pasting, click "OK" to exit the prompt. If the entered HTML source code is successfully parsed, the new terms and definitions will be appended to the table. If there's an error parsing the HTML, you may get an alert, but nothing will happen. Obviously, this is a text-driven tool, so don't expect pictures from your Quizlet to show up.

> I'm aware that this is a very hacky way to do this. Quizlet makes web scraping fairly difficult, so I decided  on a relatively more maintainable solution. On the bright side, you can use this technique to get the contents of your private Quizlets.

### Importing from JSON

To import raw JSON data, click the "Import JSON" button. This will prompt you to paste in the raw JSON you want to use. After you're done pasting, click "OK" to exit the prompt. If the JSON is successfully parsed, the new terms and definitions will be appended to the table. If there's an error, you may get an alert, but nothing will happen. 

The keys of the imported JSON data are treated as the new terms, and the values are treated as the definitions. Note that the values effectively get stringified, so pass in JSON that has strings for values.

## Issues

If you ever run into any issues, open up an issue at the [repo](https://github.com/nhwn/jisho). As for licensing, this tool is distributed under the [MIT](https://opensource.org/licenses/MIT) license, so feel free go ham on the source code.

## Editor
This is the editor for creating your .tns files. The sky's the limit!

