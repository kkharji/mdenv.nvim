local mdenv = {}
local preview = require'mdenv.modules.preview'
local editing = require'mdenv.modules.editing'

--- Attach mdenv to through ftplugn/markdown.vim
--- TODO(tami5): loop over all the modules inside lua/mdenv/modules and call attach
--- function.
--- TODO(tami5): Check if ftplugn breaks or produce undesirable behavior with
--- completion previews or hovers. If that the case create a BufReadPost *.md.
mdenv.attach = function()
  preview.attach()
  editing.attach()
end

mdenv.setup = function(opts)
  require'mdenv.config'.set(opts)
end

return mdenv
