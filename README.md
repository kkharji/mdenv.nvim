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

### Credit

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
  * https://github.com/wsdjeg/vim-fetch gf reference
-->

<!-- references -->
[Credit]: #credit
[annotate.el]: https://github.com/bastibe/annotate.el
