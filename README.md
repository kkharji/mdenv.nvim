mdenv.nvim
===

mdenv is caveman markdown/pandoc editing environment born out of frustration
with existing mediums to edit markdown documents in vim. It builds upon and
inspired by many existing plugins (see [Credit]), and tries to be that
single plugin you needed for making editng markdown files and producing
documents from markdown markup language (+extensions) joyful, sensable and fast.

### Requirements

* Neovim nightly
* Pandoc
* pandoc-imagine
* TexLive

Features/Modules
---

### Folding

- [ ] fold mode stack.
- [ ] fold mode nested
- [ ] fold text format.

### Syntax Highlighting
- [x] LINK:   don't underline and highlight links, change link group.
- [X] MARKUP: Comment surrounding shouldn't be red.
- [x] MARKUP: Heading delimitar should be same highlight group as header
- [x] INCLUDE: YAML doesn't work
- [-] Fenced: Languages defined in fence doesn't work. Using `g:markdown_fenced_languages` for now.
- [-] Fenced: conceal and highlighting breaks in lists: conceal break when there is not empty line above or below.
- [ ] CodeBlock: dim codeblock background.
- [ ] MARKUP: Make bold and italic fgcolor optional.
- [ ] MARKUP: number lists should be same color as dashed lists
- [ ] MARKUP: empty verbterm \`\` is not reconginized as verbterm and it breaks highlight for the following lines.
- [ ] List: delimitar should be same color as the checkbox or Conceal.
- [ ] MARKUP: Code shouldn't be highlighted as strings, but rather as Special.
- [ ] Extra: checkboxs chars and color
- [ ] Headings: Adding a styling sep breaks atx heading highlight

### Indent

* [ ] `==` should not break indentation of lists.
* [ ] J should merge lists

### Editing
- [ ] LIST: Tab in any mode, indent/deindent list items, including todos #hard.
  - NOTE: The number of space should refelct the user number of space or be
    a single tab if the user uses that
- [ ] Shift-enter/Ctrl-enter o/O in lists creates a new list or checkboxs item. #medium
  Or enter with double enter convert it to a regular line.
- [x] List: `-` create a list or todo item in insert as well as fontmeter
  block
- [ ] LIST: Toggle/Cycle checkboxs. #easy
- [ ] OTHER: style a range or current word #easy
- [ ] edit codeblock or table in a popup window using the new api #medium.

### Events
- [ ] When a user has a reference to heading, define it automatically on write,
      and delete it when it's no longer used.

### Completion #later
- Heading tags completion #later
- Advance writing completion #later

### Other
  - Dead link detection.
  - Virtual text for footnotes, kinda like annotations. see [annotate.el]
  - Toggle lines to list/tasks items.
  - Toggle table to csv and back.
  - convert between CSV and table.

### Review of markdown highlighting plugins

- `mkdx`
  - mappings maps to different actions depending on,
    vim mode, clipboard content, .. etc
  - generate table of content and update it on write.
  - jump to file.
  - indent and unindent lists, and number lists.
  - Auto update check-Boxes based on child changes or parent.

- `plasticboy/vim-markdown`
  - highlighting breaks of list items break on multiple lines.
  - when trying to navigate to the current headline, it jump to the above
    headline.
  - side table of content works well, I wish if it has more infomration,
    with out line numbers

- Other
  - I'd like to use command line to jump to headers where I have auto completion
  - of the content. I think this will require looking into wilder#set_option. It
    will be a handy jummp tool.
  - side table of content controled by c-n/c-p when it's activated and unmapped
    when closed. or maybe just quick fix.
  - edit a single section, or zoom in.
  - add footnote mapping
  - handle header renaming and fix internal link


Credit
---

- https://github.com/wincent/corpus
- https://github.com/SidOfc/mkdx
- https://github.com/bwhelm/vim-listmode
- https://github.com/vim-pandoc/vim-pandoc
- https://github.com/coachshea/vim-textobj-markdown
- https://jblevins.org/projects/markdown-mode/

<!-- help -->

<!--
  * http://vim.wikia.com/wiki/Creating_new_text_objects
  * https://github.com/shushcat/vim-minimd simple implementation of pandoc
  * https://github.com/conornewton/vim-pandoc-markdown-preview
  * https://github.com/rafcamlet/simple-wiki.nvim -- visual selection
  * https://github.com/CourrierGui/vim-markdown 00 syntax higlighting
  * https://github.com/PurpleGuitar/vim-pandoc-tasks
-->

<!-- references -->
[Credit]: #credit
[annotate.el]: https://github.com/bastibe/annotate.el
