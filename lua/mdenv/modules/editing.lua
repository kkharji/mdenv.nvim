local editing = {}
local insert = require'mdenv.modules.editing.insert'
local map = require'mdenv.internal.nvim'.map
local cfg = require'mdenv.config'.values.editing

editing.attach = function ()
  if cfg.insert_magic then
    _MdEnvCfg.funcs = {}
    _MdEnvCfg.funcs.handle_dash_char = insert.handle_dash_char

    map{
      buffer = true,
      ['i|-'] = 'v:lua._MdEnvCfg.funcs.handle_dash_char()'
    }
  end
end

return editing
