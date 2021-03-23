mdenv.nvim
===

mdenv is caveman markdown/pandoc editing environment born out of frustration
with existing mediums to edit markdown documents in vim. It builds upon and
inspired by many existing plugins (see [insperations]), and tries to be that
single plugin you needed for making editng markdown files and producing
documents from markdown markup language (+extensions) joyful, sensable and fast.

### Requirements

* Neovim nightly
* Pandoc
* pandoc-imagine
* TexLive

Features/Modules
---

- Folding
  - [ ] fold mode stack.
  - [ ] fold mode nested
  - [ ] fold text format.
- Syntax Highlighting
  - [x] LINK:   don't underline and highlight links, change link group.
  - [X] MARKUP: Comment surrounding shouldn't be red.
  - [x] MARKUP: Heading delimitar should be same highlight group as header
  - [x] INCLUDE: YAML doesn't work
  - [-] Fenced: Languages defined in fence doesn't work. Using `g:markdown_fenced_languages` for now.
  - [ ] CodeBlock: dim codeblock background.
  - [ ] MARKUP: Make bold and italic fgcolor optional.
  - [ ] MARKUP: Code shouldn't be highlighted as strings, but rather as Special.
  - [ ] Extra: checkboxs chars and color
  - [ ] Headings: Adding a styling sep breaks atx heading highlight

- Other
  - Dead link detection.
  - Toggle lines to list/tasks items
  - Toggle table to csv and back

Inspirations & Credit
---

- https://github.com/wincent/corpus
- https://github.com/SidOfc/mkdx
- https://github.com/bwhelm/vim-listmode
- https://github.com/vim-pandoc/vim-pandoc
- https://github.com/coachshea/vim-textobj-markdown
- https://jblevins.org/projects/markdown-mode/

[insperations]: #inspirations
