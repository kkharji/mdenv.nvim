local config = require'mdenv.config'
local vals = config.values
local eq = assert.are.same

describe("mdenv-config", function()
  it("has default values.", function()
    eq(true, not vim.tbl_isempty(config.values), "It has the default values")
  end)
  it("changes default values.", function()
    config.set{
      conceal = { enable = false }
    }
    eq(false, vals.conceal.enable, "It changes the default values")
  end)
  it("errors out if key doesn't exists in default configuration.", function()
    local ok, _ = pcall(config.set, {
      folding = { invalidkey = false }
    })

    eq(false, ok, "It should error out.")
  end)
  it("errors out if key value type mismatch.", function()
    local ok, _ = pcall(config.set, {
      preview = { auto_open = 'yes' }
    })

    eq(true, not ok, "It should error out.")
  end)
  it("skip type checking for special keys.", function()
    local ok, _ = pcall(config.set, {
      navigation = {
        mappings = {
          ['a'] = function () end,
          ['b'] = false,
          ['c'] = 'str'
        }
      }
    })
    eq(true, ok, "It should error out.")
    local ok, _ = pcall(config.set, {
      mappings = {
        ['a'] = function () end,
        ['b'] = false,
        ['c'] = 'str'
      }
    })
    eq(true, ok, "It should not error out.")
    local ok, _ = pcall(config.set, {
      conceal = {
        blacklist = {
          ['a'] = function () end,
          1,
          'str'
        }
    }})
    eq(true, ok, "It should not error out.")
  end)
end)
