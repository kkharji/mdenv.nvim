mdenv.nvim
===

mdenv is caveman markdown/pandoc editing environment born out of frustration
with existing mediums to edit markdown documents in vim. It build upon and
inspired by many existing plugins (see [insperation]) and tries to be that
single plugin you needed to make editng markdown files joyful, sensable and
fast.

### Requirements

- Neovim nightly
* Pandoc
* pandoc-imagine
* TexLive

Features/Modules
---

* Folding
  + [ ] fold mode stack.
  * [ ] fold mode nested
  * [ ] fold text format.
* Syntax Highlighting
  * Highlight Group
    * [ ] **Headings** with conceal of # with user defined values
    * [ ] **URL**. (maybe not)
    * [ ] **Emojis** (maybe not)
    * [ ] **Footnote** with conceal.
    * [ ] **Styles** with conceal: bold, italic, mixed, verbatim, strikeout.
    * [ ] **Citations**.
    * [ ] **Lists** with conceal of user defined values.
    * [ ] **Checkbox**: with conceal uncheaked/checked/pending
    * [ ] **Codeblocks** with conceal start/end.
    * [ ] **Qoute** with conceal of '>'
  * pre-include
    * [ ] HTML highlighting.
    * [ ] Latex highlighting.
    * [ ] Yaml/fontmatter highlighting.
    * [ ] Any other languages defined in highlighting.fanced
  * [ ] Support HTML multiline highlight.
  * [ ] set html markdown comments
  * [ ] try to make codeblock more fancy and visually pleasing.
  * [ ] enable user to specfiy codeblock fanced highlighting
  * [ ] enable user to blacklist conceals.
  * Features
  * [ ] control conceallevel.
  * [ ] control concealcursor.
  * [ ] control what to conceal, blacklist conceals.
  * [ ] add a language highlighting on the fly.



- Dead link detection.
- Toggle lines to list/tasks items
* Toggle table to csv and back



Inspirations
---

- https://github.com/wincent/corpus
* https://github.com/SidOfc/mkdx
- https://github.com/bwhelm/vim-listmode
* https://github.com/vim-pandoc/vim-pandoc
* https://github.com/coachshea/vim-textobj-markdown

<!-- help -->
<!--
  * http://vim.wikia.com/wiki/Creating_new_text_objects
  * https://github.com/shushcat/vim-minimd simple implementation of pandoc
  * https://github.com/conornewton/vim-pandoc-markdown-preview
  * https://github.com/rafcamlet/simple-wiki.nvim <!-- visual selection -->
  * https://github.com/CourrierGui/vim-markdown <!-- syntax higlighting -->
  * https://github.com/PurpleGuitar/vim-pandoc-tasks
-->
<!-- references -->
[insperations]: #inspirations
