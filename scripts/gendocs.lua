-- Setup telescope with defaults
require('pandoc_nvim').setup()

local docgen = require('docgen')

local docs = {}

docs.test = function()
  -- TODO: Fix the other files so that we can add them here.
  local input_files = {
    "./lua/pandoc_nvim/init.lua",
  }

  table.sort(input_files, function(a, b)
    return #a < #b
  end)

  local output_file = "./doc/pandoc_nvim.txt"
  local output_file_handle = io.open(output_file, "w")

  for _, input_file in ipairs(input_files) do
    docgen.write(input_file, output_file_handle)
  end

  output_file_handle:write(" vim:tw=78:ts=8:ft=help:norl:\n")
  output_file_handle:close()
  vim.cmd [[checktime]]
end

docs.test()

return docs
