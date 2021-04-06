local fmt = string.format
local util = {}

---Creates lua string function call. used for mappings and autocmds
---@param mname string: the module name
---@return function: accept the fname and return a lua require ...
util.strfun = function (mname)
  return function (fname)
    return fmt("require'%s'.%s", mname, fname)
  end
end

--- Check if a given variable is empty. covers lists, tables, strings and check
--- if the variable is nil.
---@param xs any
---@return boolean
util.is_empty = function(xs)
  if type(xs) == "string" then
    return xs == ''
  elseif type(xs) == "table" then
    return vim.tbl_isempty(xs)
  elseif xs == nil then
    return true
  end
end

---Same as |is_empty| except it return true if the given variable is not empty.
---@param xs any
---@return boolean
util.not_empty = function(xs)
  return not util.is_empty(xs)
end

---Reverse the k with v, used for looking up by values.
---@param t table: table to reverse.
---@return table: reversed table
util.kv_reverse = function(t)
  local _t = {}
  for k,v in pairs(t) do
    _t[v] = k
  end
  return _t
end

return util
