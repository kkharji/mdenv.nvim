local nvim   = require'mdenv.internal.nvim'
local job    = require'plenary.job'
local log    = require'plenary.log'.new({ plugin = 'MdEnv' })
local _cfg   = require'mdenv.config'.values
local util   = require'mdenv.internal.util'
local fmt    = string.format
local join   = table.concat
local cfg    = _cfg.preview
local maps   = _cfg.mappings
local strfun = util.strfun('mdenv.modules.preview')
local preview = {}

local get_info = function(kind)
  local info = {}
  info.filename = vim.split(vim.fn.expand("%:t"), "%.")[1]
  info.cwd = vim.loop.cwd()
  info.out = join { cfg.path(), "/", info.filename, ".", kind }
  info.path = vim.fn.expand("%")
  info.preview_exits = vim.loop.fs_lstat(info.out)
  info.source_exits = vim.loop.fs_lstat(vim.fn.expand('%:p'))

  return info
end

local generate = function(opts)
  -- assert(type(opts.kind) == "string")
  opts = opts or {}
  local args = {'-s', opts.info.path, '-o', opts.info.out }

  if opts.kind == 'pdf' then
    args[#args+1] = "--pdf-engine=" .. cfg.pdf.engine
  else
    args[#args+1] = "--self-contained"
  end
  -- print(vim.inspect(opts))
  return job:new({
    command = 'pandoc',
    args = vim.tbl_flatten{ args, opts.gen_args or {} },
    cwd = opts.info.cwd,
    on_exit = vim.schedule_wrap(opts.cb)
  }):start()
end

local open = function(opts)
  job:new({
    command = opts.kind == "pdf" and cfg.pdf.cmd or cfg.html.cmd,
    args = {opts.info.out}
  }):start()
end

local notify_fail = function(job, kind)
  local err  = join(job:stderr_result(), "\n")
  local fmsg = "[mdenv] Unable to generate %s: %s"

  return log.error(fmt(fmsg, kind, err))
end

-- TODO: make it open a quickfix
local post = function(fn, opts)
  return function (j, c)
    if c ~= 0 then
      return notify_fail(j, opts.kind)
    end

    if not opts.silent then
      print(fmt("[Mdenv]: %s Generated.", opts.kind))
    end

    if fn then
      return fn(opts)
    end
  end
end

--- In case the user open html preview and want to still use it
local curr_kind = nil

---Generate preview files
---@param o table: options
---@field kind string: what kind to generate, default to cfg.preferred_kind
--- or last kind open for preview.
---@field silent boolean: whether to notify you at the start of generation and
--- when the files are generated successfully.
---@field gen_args table: additional arguments to glow to the generator.
---@field cb function: the function to call when done generating, default is
--- a simple checker.
---@see generate
---@see get_info
---@see post
preview.generate = function(o)
  local defaults = {
    kind = curr_kind or cfg.preferred_kind,
    silent = cfg.auto_gen.silent,
    gen_args = {},
  }

  o = vim.tbl_extend("keep", o or {}, defaults)

  o.info = o.info or get_info(o.kind)
  if not o.info.source_exits then return end

  o.cb = o.cb or post(nil, o)

  -- TODO: animate gerernating pdf with spinner
  if not o.silent then
    print(fmt("[Mdenv]: Generating %s ...", o.kind))
  end

  return generate(o)
end

---Wrapper around generate that checks if preview module is enabled.
preview.auto_generate = function()
  if not cfg.auto_gen.enable() then return end
  preview.generate()
end

---Open Mdenv Previewer
--- if |cfg.enable| return true, then it will open the previewer if the file
--- already exists, else generate then open. else nothing.
---TODO: do we need to stop the user from opening preview?
---@param kind string: 'pdf' or 'html', default to |cfg.preferred_kind|
---@see generate
---@see open
preview.open = function(kind)
  local o = {
    kind = kind or cfg.preferred_kind,
    info = get_info(kind),
  }
  o.cb = post(function() return open(o) end, o)
  curr_kind = kind; (o.info.preview_exists and open or generate)(o)
end

---Main attach function for preview module.
--- Checks for pandoc executable, error
preview.attach = function ()
  local au = {}

  ----------------------- check for pandoc executable
  if not vim.fn.executable("pandoc") == 1 then
    return log.error("pandoc executable not found")
  end

  ----------------------- auto-generate preview files
  if cfg.auto_gen.enable() then
    local events = {'BufWritePre'}

    if cfg.auto_gen.aggressive then
      for _, e in ipairs {
        'InsertLeave'
      } do events[#events+1] = e end
    end

    au[('%s *.md'):format(join(events, ","))] = ('lua %s'):format(strfun('auto_generate()'))
  end

  ----------------------- auto-open previewer
  if cfg.auto_open() then
    preview.open()
  end

  ----------------------- attach autocmds
  if not vim.tbl_isempty(au) then
    nvim.augroup("preview", au)
  end

  ----------------------- attach mappings
  local rmaps = util.kv_reverse(maps)

  nvim.map({
    ['nx|' .. _cfg.leader .. rmaps['open_pdf']] = strfun("open('pdf')"),
    ['nx|' .. _cfg.leader .. rmaps['open_html']] = strfun("open('html')")
  })
end
preview.attach()
return preview
