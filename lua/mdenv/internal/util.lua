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
