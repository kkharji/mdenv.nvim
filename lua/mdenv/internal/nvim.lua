local nvim = {}
local fmt = string.format

local is_expr = function(info, k)
  local expr_clue = string.match(info.rhs, "?")
  local vlua = string.match(info.rhs, "v:lua")
  local expr = expr_clue or vlua
  -- TODO: FIXME or bulk remapping with s won't work
  local valid_key = string.match(k, "i") or string.match(k, "s|")
  -- return valid_key
  if valid_key and expr then
    return true
  else
    return false
  end
end

local get_rhs = function(k, info, lua, cmd)
  local f = "%s"
  if (lua or cmd) then
    f = lua and "<cmd>lua %s<cr>" or ":%s<cr>"
  end

  if info.rhs:find("v:lua") then
    if is_expr(info, k) then
      info.o.expr = true
    else
      info.rhs = fmt(":call %s<cr>", info.rhs)
    end
  end

  if info.rhs:find("require") and not info.o.expr then
    info.rhs = fmt("<cmd>lua %s<cr>", info.rhs)
  end

  return fmt(f, info.rhs)
end

local get_modes = function(mk)
  local ret = {}
  for mode, _ in string.gmatch(mk[1], "(%w)") do
    table.insert(ret, mode)
  end
  return ret
end

local get_info = function(k, v)
  local t = type(v)
  local info = {}

  if t == "table" then
    info.rhs = v[1]; v[1] = nil
    info.type = type(info.rhs)
    info.bufonly = v.buffer ~= nil and v.buffer or nil
    v.buffer = nil

    info.bufonly = type(info.bufonly) == "boolean" and 0 or info.bufonly
    info.o = v
  elseif t == "string" or t == "function" then
    info.rhs = v
    info.o = {}
    info.type = t
  end

  info.o = vim.tbl_extend("keep", info.o, {
    noremap = true,
    silent = true,
    expr = is_expr(info, k)
  })

  return info
end


local map_item = function(k, v, lua, cmd)
  local info = get_info(k, v)
  local mk = vim.split(k, "|")
  local modes = get_modes(mk)

  lua = lua or info.o.lua; info.o.lua = nil
  cmd = cmd or info.o.cmd; info.o.cmd = nil

  info.rhs = get_rhs(k, info, lua, cmd)
  info.lhs = mk[2]

  return modes, info
end

nvim.map = function(spec)
  for _, m in ipairs((function()
    local ret = {}
    local bufnr = type(spec.buffer) == "boolean" and 0 or spec.buffer; spec.buffer = nil
    local noremap = spec.noremap ; spec.noremap = nil
    local silent = spec.silent; spec.silent = nil
    local expr = spec.expr; spec.expr = nil
    local lua = spec.lua; spec.lua = nil
    local cmd = spec.cmd; spec.cmd = nil

    for k, v in pairs(spec) do
      modes, m = map_item(k, v, lua, cmd)

      m.o.noremap = vim.F.if_nil(noremap, m.o.noremap)
      m.o.silent = vim.F.if_nil(silent, m.o.silent)
      m.o.expr = vim.F.if_nil(expr, m.o.expr)

      for _, mode in ipairs(modes) do
        ret[#ret+1] = {
          mode = mode, lhs = m.lhs, rhs = m.rhs, opts = m.o,
          bufonly = m.bufonly or bufnr,
        }
      end
    end
    return ret
  end
  )())
  do
    if m.bufonly then
      vim.api.nvim_buf_set_keymap(m.bufonly, m.mode, m.lhs, m.rhs, m.opts)
    else
      vim.api.nvim_set_keymap(m.mode, m.lhs, m.rhs, m.opts)
    end
  end
end

nvim.augroup = function(module, spec)
  local name = 'Mden' .. module:gsub("^%l", string.upper)
  local autocmds = {}

  for event, autocmd in pairs(spec) do
    local t = type(autocmd)
    local is_str = t == "string"
    local is_tbl = t == "table"
    local is_list = is_tbl and vim.tbl_islist(autocmd) or nil

    if is_str then
      table.insert(autocmds, {event, autocmd})

    elseif is_list then
      for _, value in ipairs(autocmd) do
        table.insert(autocmds, { event, value })
      end

    elseif (is_tbl and not is_list) then
      for partial, value in pairs(autocmd) do
        table.insert(autocmds, { event .. ' ' .. partial, value })
      end

    end
  end

  vim.cmd("augroup " .. name)
  vim.cmd("autocmd!")

  for _, autocmd in ipairs(autocmds) do
    vim.cmd(fmt("autocmd %s %s", autocmd[1], autocmd[2]))
  end

  vim.cmd("augroup END")
end

return nvim
