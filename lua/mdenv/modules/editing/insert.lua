local insert = {}
local util = require'mdenv.internal.util'

--- Simple wrapper that escape, as well as repeat char.
---@param char string: the char to escape and/or repeate.
---@param times number: number of times to repeat.
---@return string
local tr = function(char, times)
  return string.rep(vim.api.nvim_replace_termcodes(char, true, true, true), times or 1)
end

--- backspace
local bs = function(times)
  return tr('<BS>', times)
end

--- move up
local mup = function(times)
  return tr('<up>', times)
end

--- move down
local mdown = function(times)
  return tr('<down>', times)
end

--- move right
local mright = function(times)
  return tr('<right>', times)
end

--- move left
local mleft = function(times)
  return tr('<left>', times)
end

--- Checks if str start with whitespace.
---@param str string
---@return boolean
local startwithws = function(str)
  -- local content, = vim.api.nvim_get_current_line()
  if str:match"^%S+" then
    return false
  elseif str:gsub("^%s*(.-)%s*$", "%1") == "" then
    return true
  end
end

local trim = function (str)
  return str:gsub("^%s*(.-)%s*$", "%1") or ""
end

--- Handles `-` char in insert mode.
--- If the dash is pressed in the beginning of the line, or followed by
--- whitespace only then:
---      - 1st click  = '- ',
---      - 2nd click  = '- [ ]', 3rd = '-'
---      - 3rd click  = '-'
--- if the cursor at line 1, then
---      - 1st click = fontmatter block
---      - 2nd click = '-'
--- TODO: skip of there's a text above the current line. so that to make atx
--- heading it wouldn't require pressing - three times. Or better, single - result
--- TODO: refactor
--- in `---`.
--- NOTE: this a dump version inspried by glepnir/smartinput.nvim.
insert.handle_dash_char = function()
  local st, nd, th = '- ', '- [ ] ', '-'
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local cline = vim.api.nvim_get_current_line()

  if cline:match("^%s*-%s$") or startwithws(cline) or trim(cline) == trim(nd) then
    if (row == 1 and col == 0) or row == 2 then
      local range = vim.fn.getline(1,3)
      if range[1] == "---" and range[2] == "" and range[3] == "---" then
        return bs(4) .. mdown() .. mright(3) .. bs(4) .. '-'
      end
        return '---\n\n---' .. mup()
    else
      local cline_trimed, st_trimed, nd_trimed = trim(cline), trim(st), trim(nd)

      if cline_trimed ~= st_trimed and cline_trimed ~= nd_trimed then
        return st
      elseif cline_trimed == st_trimed then
        return bs(#st) .. nd
      elseif cline_trimed == nd_trimed then
        return bs(#nd) .. th
      end
    end
  else
    return "-"
  end
end

return insert
