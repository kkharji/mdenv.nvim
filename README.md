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

### Preview

- [x] Generate and open pdf files
- [x] Support conditional loading of preview module features.
- [x] Change from one kind to another depending on last kind used to open the
  previewer
- [x] Only open pdf files if there aren't already open.
- [ ] Auto-generate (aggressive) on any overall changes in the buffer.
- [ ] Auto-refresh html page when regenerating html.
- [ ] Auto-scroll html pages depending on current line in the buffer.
- [ ] provide user a function to set HTML css.
- [ ] Update previwer on switching to antoher markdown buffer.
- [ ] On generation errors open quickfix with the errors.
- [ ] provide user with function to set latex template for pdf
- [ ] Set pandoc options and overriding preview defualts through fontmatter.
  - e.g. generate pdf filename, template, css, template variables.
- [ ] Close previewer on nvim exit.
- [ ] cover other Filetypes then `*.md`, better yet, load them from a cfg value

### Folding

- [ ] fold mode stack.
- [ ] fold mode nested
- [ ] fold text format.

### Syntax Highlighting

- [x] don't underline and highlight links, change link group.
- [X] Comment surrounding shouldn't be red.
- [x] Heading delimitar should be same highlight group as header
- [x] Fix YAML syntax highlight not getting activitied
- [ ] codeblocks conceal break when indented in a list if there's no space above
  or bellow.
- [ ] dim codeblock background.
- [ ] Make bold and italic fgcolor optional.
- [ ] Fix empty verbterm \`\` being not recognized as verbterm (it breaks highlight for the following lines).
- [ ] Make number lists same color as dashed lists.
- [ ] Make list delimiter same color as the check-Boxes or Conceal.
- [ ] Fix styling separator breaking atx heading highlight.
- [ ] Fix bug leading to the use `g:markdown_fenced_languages`.
- [ ] Make level 1, level 2, level 3 have different conceal char and optional.

### Indent

* [ ] Fix `==` breaking indentation of lists.
* [ ] Make J merge check-Boxes, deleting the check-Boxes on merge.


### Editing/Insert

- [x] Make dash create a list, checkbox as well as fontmatter when being at 1st line.
- [ ] Shift-enter/Ctrl-enter o/O in lists creates a new list or checkboxes item. #medium
  Or enter with double enter convert it to a regular line.

### Editing/all
- [ ] Make `<Tab>` in all modes, indent/de-indent list items, including checkboxes.
  - NOTE: The number of space should refelct the user number of space or be
  a single tab if the user uses that

#### Other
- [ ] Toggle/Cycle check-Boxes.
- [ ] style (bold/italic/verbterm) a range or current word #easy

### Extension
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
