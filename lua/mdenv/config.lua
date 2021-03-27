local config = {}
local log = require'plenary.log'.new({
  plugin = 'MdEnv'
})

-- log.error("hi")

_MdEnvCfg = _MdEnvCfg or {}

config.values = _MdEnvCfg

local defaults = {
  --- debug mode
  debug = false,
  --- Normal/Visual Mode leaderkey.
  leader = '<localleader>',
  --- insert Mode leaderkey.
  ileader = '<localleader>',
  --- Folding Module configuration
  folding = {
    --- Whether folding module should be disabled.
    enable = true,
    --- How should the headings be folded, (nested, stack)
    mode = 'stack',
    --- Whether to fold fontmatter or not.
    frontmatter = false,
  },
  --- Bibliographies Module Configuration
  bib = {},
  --- Preview Module Configuration
  preview = {
    --- Whether to activate previwer on BufEnter enter.
    auto_open = false,
    --- What format to default to when launching the previewer (web, pdf)
    preffered_previewer = 'pdf',
    --- Whether to regenerate on save.
    auto_gen  = true,
    --- Whether to delete generated files on VimLeave
    clean = false,
    --- pdf browser to open the generate pdf file.
    pdf = 'zathura',
    --- Browser to open the generate html file.
    browser = 'firefox',
    --- path to save generated pdf and html files.
    path = function()
      --- can be current directory or a path under current directory.
      --- true: generate in current directory under export
      return '/tmp/mdenv'
    end,
  },
  --- Toc module configuration
  toc = {
    --- Whether to open toc automatically.
    auto = false,
    --- Where to open the split (left, right, popup)
    position = 'left',
    --- the size of the toc split
    width = 0.2,
  },
  --- Syntax configuration
  syntax = {
    --- Whether to enable mdenv syntax configurations. setting it to false might
    --- not work since - syntax configurations is located in syntax/markdown.vim
    enable = true,
    --- Whether to italicize emphases, bold strong emphases and other styles to
    --- reflect the markup visual equivalent.
    markup = true,
    --- Whether to use roman style for numbered lists.
    roman_lists = true,
    --- TODO
    definition_lists = false,
    --- Languages to include syntax files for. Be aware that to many fenced
    --- languages (working only in code blocks) may effect performance. There is
    --- an additional syntax command to add fenced languages highlighting on the
    --- fly, when you need to, but for this list, make sure to only include what
    --- you need
    include = {
      yaml = true,
      html = true,
      tex = true,
      fenced = {},
    },
    --- Cocneal configurations
    conceal = {
      --- Set to false to totally disable conceal configurations
      enable = true,
      --- Whether to conceal markups like **/_/~/ ... etc
      markup = true,
      --- Whether to conceal urls []() -> []
      url = false,
      --- wrapper for concealcursor
      cursor = 'nv',
      --- wrapper for conceallevel
      level = 2,
      --- Groups that you don't want be concealed.
      blacklist = { },
      --- Conceal chars
      chars = {
        super = 'ⁿ',
        sub = 'ₙ',
        atx = "◼",
        codelang = "—",
        codeend = "—",
        abbrev = '→',
        footnote = "༎",
        definition = ' ',
        quote = "❚",
        list = "•",
        checkbox_empty = "▢", -- TODO: implement
        checkbox_done = "✔", -- TODO: implement
        checkbox_pending = '—', -- TODO: implement
        comment_start = '‹',
        comment_end = '›'
      },
    },
  },
  --- Images Module configuration, for dealing with images.
  images = {
    enable = true,
  },
  --- Module for enahancing editing experience.
  editing = {
    preferred_styles = {
      bold = '*',
      italic = '_',
    },
    --- text objects omap
    text_objects = {
      select_section = 's',
      select_header = 'S',
    },

    --- Whether to enable insert magic mappings.
    insert_magic = true,

    --- `textwidth`: The max textwidth before breaking the line.
    textwidth = 75,

    --- fontmatter: Whether to use fontmatter.
    fontmatter = true,

    --- Pending `autotitle`: Whether to automatically append title to fontmatter.
    --- e.g. `this_is_file_name.md` > `title: This is File Name`
    --- Note: if on_write is false, then this will be manual. Additionally, if
    --- fontmatter is false, then this won't work at all.
    autotitle = true,

    --- Pending `autotoc`: Whether to write and maintain table of content.
    autotoc = false,

    --- Pending `autoref`: Whether to move links target to the end of the file.
    --- e.g. `[Home](https://...)` > `[home]` & `[home]: https://...`
    --- e.g. `[Home]` > `[home]` & `[home]: ./home.md if found or empty`
    autoref = true,
  },

  --- Module for dealing with navigation
  navigation = {
    enable = true,
    --- web browser
    web_browser = 'firefox',
    img_browser = 'sxiv',

    -- Mappings here are mapped without leader key
    mappings = {
      --- Navigate to the next header.
      [']]'] = 'next_header',
      --- Navigate to the previous header.
      ['[['] = 'prev_header',
      --- Open links in same buffer.
      ['gf'] = 'open_link_here',
      --- Open links in split.
      ['gF'] = 'open_link_split',
      --- Open links in float.
      ['go'] = 'open_link_float',
      --- Open links in new nvim instance.
      ['gO'] = 'open_link_nvim',
      --- Navigate to the previous file.
      ['gb'] = 'prev_link',
      --- Navigate to the next file.
      ['gn'] = 'next_link',
    },
  },

  --- Words module configuration
  --- Module for dealing with words.
  --- e.g. find synonyms, correct spelling .. etc
  writing = {},

  --- lists module configuration
  lists = {
    enable = true,
    preferred_list_char = '-',
    preferred_todo_text = '[ ]',
    preferred_pending_text = '[-]',
    preferred_done_text = '[X]',
    mappings = {
      ['<tab>'] = 'indent',
      ['<s-tab>'] = 'deindent'
    }
  },

  mappings = {
    ['op'] = 'open_pdf',
    ['oh'] = 'open_html',
    ['t']  = 'open_toc',
    ['l']  = 'toggle_list_item',
    ['b']  = 'toggle_bold',
    ['e']  = 'toggle_italic',
    ['E']  = 'toggle_mix',
    ['q']  = 'toggle_quote',
    ['x']  = 'toggle_strickout',
    ['c']  = 'toggle_verbtim',
    ['#']  = 'toggle_header',
    ['=']  = 'promote_header',
    ['-']  = 'demote_header',
    ['p']  = 'paste_link_or_images',
    ['<f1>']  = function ()
      print('mappings functions works')
    end,
    ['zz'] = 'toggle_spelling',
  },



}

--- Enahnced version of builtin type function that inclued list type.
---@param val any
---@return string
local get_type = function(val)
  local typ = type(val)
  if val == "table" then
    return vim.tbl_islist(val) and "list" or "table"
  else
    return typ
  end
end

--- returns true if the key name should be skipped when doing type checking.
---@param key string
---@return boolean: true if it should be if key skipped
local should_skip_type_checking = function(key)
  for _, v in ipairs({ 'mappings', 'blacklist', 'fenced' }) do
    for _, k in ipairs(vim.split(key, "%.")) do
      if k:find(v) then
        return true
      end
    end
  end
  return false
end


--- Checks defaults values types against modification values.
--- skips type checking if the key match an item in `skip_type_checking`.
---@param dv any: defaults values
---@param mv any: custom values or modifications .
---@param trace string
---@return string: type of the default value
local check_type = function(dv, mv, trace)
  local dtype = get_type(dv)
  local mtype = get_type(mv)
  local skip = should_skip_type_checking(trace)

  --- hmm I'm not sure about this.
  if dv == nil and not skip then
    return log.error(('Invalid configuration key: `%s`'):format(trace))

  elseif dtype ~= mtype and not skip then
    return log.error(
      ('Unexpcted configuration value for `%s`, expected %s, got %s')
      :format(trace, dtype, mtype)
    )
  end

  return dtype
end

--- Consumes configuration options and sets the values of keys.
--- supports nested keys and values
---@param startkey string: the parent key
---@param d table: default configuration key
---@param m table: the value of startkey
local consume_opts
consume_opts = function(startkey, d, m)
  for k, v in pairs(m) do
    local typ = check_type(d[k], v, ("%s.%s"):format(startkey, k))
    if typ == "table" then
      consume_opts(startkey .. "." .. k, d[k], v)
    else
      d[k] = v
    end
  end
end

--- Set or extend defaults configuration
---@param opts table
config.set = function(opts)
  opts = opts or {}

  if next(opts) ~= nil then
    for k, v in pairs(opts) do
      local typ = check_type(_MdEnvCfg[k], v, k)
      if typ ~= "table" then
        _MdEnvCfg[k] = v
      else
        consume_opts(k, _MdEnvCfg[k], v)
      end
    end
  else
    if vim.tbl_isempty(_MdEnvCfg) then
      _MdEnvCfg = defaults
      config.values = _MdEnvCfg
    end
  end
end

config.set()

return config
