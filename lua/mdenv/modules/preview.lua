local nvim   = require'mdenv.internal.nvim'
local job    = require'plenary.job'
local Path    = require'plenary.path'
local log    = require'plenary.log'.new({ plugin = 'MdEnv' })
local _cfg   = require'mdenv.config'.values
local util   = require'mdenv.internal.util'
local fmt    = string.format
local join   = table.concat
local cfg    = _cfg.preview
local maps   = _cfg.mappings
local strfun = util.strfun('mdenv.modules.preview')
local uv     = vim.loop
local preview = {}
local pandoc = vim.fn.executable("pandoc") == 1

--- In case the user open html preview and want to still use it
local curr_kind = nil

-- Because attach function maybe ran twice for some odd reason!!!
local last_attached_file = ''

---Generates the table require to generate preview files.
---@param kind string: the kind to generate.
---@return table
preview._get_info = function(kind)
  local info = {}
  info.filename = vim.split(vim.fn.expand("%:t"), "%.")[1]
  info.cwd = uv.cwd()
  info.out_path = join { cfg.path(), "/", info.filename, ".", kind }
  info.out_exists = uv.fs_lstat(info.out_path) ~= nil
  info.source_path = vim.fn.expand('%:p')
  info.source_exits = uv.fs_lstat(info.source_path) ~= nil

  return info
end

preview._on_gen_error = function(job, kind)
  local err  = join(job:stderr_result(), "\n")
  local fmsg = "[mdenv] Fail to generate %s: %s"

  -- TODO: make it open a quickfix
  return log.error(fmt(fmsg, kind, err))
end

--- The default template to use when generating PDF files.
--- by default this function returns an empty list.
--- Users can use this function to return different template based on what
--- ever condition they see fit, e.g. current_dir, time of day (dark/light),
--- based on environment variables ... etc. Additionally, this function will
--- skip using the template if template file doesn't exists.  -@note This
--- function will be ignored when `cfg.preview.pdf.templates` is set and the
--- file has fontmatter with a vaild template name defined.  see
--- |preview.templates|
---@return table: {path = 'path/to/template', vars = {k=v}, extra {...}}
preview.get_template = cfg.pdf.get_template

--- WIP: A key value pairs of template and a function identical to
--- |preview.get_template| to get template for a given fontmatter template
--- value.
preview.templates = cfg.pdf.templates

--- Process latex template from
---@param tp table: the template to process. It is the direct output of
--|preview.get_template| or `preview.template['template_name']()``
---@return table: generator args for the `tp`
preview._process_template = function(tp)
  local args = {}
  local path = Path:new(tp.path):expand()

  if uv.fs_lstat(path) == nil  then return end

  args[#args+1] = fmt("--template=%s", path)

  if tp.vars then
    for k, v in pairs(tp.vars) do
      args[#args+1] = "-V"
      args[#args+1] = fmt('%s="%s"', k, v)
    end
  end

  return util.not_empty(tp.extra) and args or vim.tbl_flatten{ args, tp.extra }
end

---Generates preview generator command line arguments
---@param o table: options
---@field kind string: pdf or html
---@field source_path string: filepath of the markdown file.
---@field out_path string: the desired filepath of generate file.
---@field extra_args table: Any extra args to append to the command line args.
---@return table
preview._get_gen_args = function(o)
  local extra_args = o.extra_args
  local kind = o.kind
  local source_path = o.info.source_path
  local out_path = o.info.out_path
  local args = {'-s', source_path, '-o', out_path }

  if kind == 'pdf' then
    args[#args+1] = "--pdf-engine=" .. cfg.pdf.engine

    -- TOOD: First check if current fontmatter has a key 'template'.
    -- If it does check if preview.templates[name] is non-nil, if so use it
    -- instead of `preview.get_template`
    local tp = cfg.pdf.get_template() -- can't use preview.get_template :/

    if util.not_empty(tp) then
      args = vim.tbl_flatten{ args, preview._process_template(tp) }
    end

  else
    args[#args+1] = "--self-contained"
  end

  return util.not_empty(extra_args) and vim.list_extend(args, extra_args) or args
end

---Generate preview files
---@param o table: options
---@field kind string: what kind to generate, default to cfg.preferred_kind
--- or last kind open for preview.
---@field silent boolean: whether to notify you at the start of generation and
--- when the files are generated successfully.
---@field extra_args table: additional arguments to glow to the generator.
---@field cb function: the function to call when done generating, default is
---@field info table: details about the file and path to generate to. see the
--- return table from |preview._get_info|
--- a simple checker.
---@see generate
---@see get_info
---@see post
---@return function job
preview.generate = function(o)
  local i
  local kind = curr_kind or cfg.preferred_kind
  local d = {
    kind = kind,
    silent = cfg.auto_gen.silent,
    gen_args = {},
    info = preview._get_info(kind)
  }

  o = vim.tbl_extend("keep", o or {}, d)
  i = o.info

  if not i.source_exits then
    return
  end
  if not o.silent then
    print(fmt("[Mdenv]: Generating %s ...", kind))
  end

  return job:new {
    command = 'pandoc',
    args = preview._get_gen_args(o),
    cwd = i.cwd,
    on_exit = vim.schedule_wrap(function(j, c)
      if c ~= 0 then
        preview._on_gen_error(j, kind)
      elseif not o.silent then
        print(fmt("[Mdenv]: %s Generated.", kind))
      end
    end)
  }
end

---Wrapper around generate that checks if preview module is enabled.
preview.auto_generate = function()
  if not cfg.auto_gen.enable() then return end
  preview.generate():start()
end

--- Creates open job
preview._open_job = function(o)
  return job:new{
    command = o.kind == "pdf" and cfg.pdf.cmd or cfg.html.cmd,
    args = { o.info.out_path },
    on_exit = vim.schedule_wrap(function(j, c)
      if c ~= 0 then preview.on_gen_error(j, o.kind) end
    end)
  }
end

---Open Mdenv Previewer
--- if |cfg.enable| return true, then it will open the previewer if the file
--- already exists, else generate then open. else nothing.
---@param kind string: 'pdf' or 'html', default to |cfg.preferred_kind|
---@see generate
---@see open
preview.open = function(kind)
  local run
  kind = kind or cfg.preferred_kind

  local o = { kind = kind, info = preview._get_info(kind) }

  if not o.info.out_exists then
    run = preview.generate(o)
    run:and_then_on_success_wrap(preview._open_job(o))
  else
    run = preview._open_job(o)
  end

  -- So that generator changes to the most recent open method.
  curr_kind = kind
  run:start()
end

---Main attach function for preview module.
--- Checks for pandoc executable, error
preview.attach = function ()
  local au = {}
  local filepath = vim.fn.expand("%:p")

  --- skip if already attached
  if last_attached_file == filepath then return end
  last_attached_file = filepath

  --- check for pandoc executable
  if not pandoc then return log.error("pandoc executable not found") end

  --- auto-generate preview files
  if cfg.auto_gen.enable() then
    local events = {'BufWritePre'}

    -- Disabled be default until I figure out what commands to add to make this
    -- trully aggressive
    if cfg.auto_gen.aggressive then
      local events = {
        'InsertLeave',
        'CursorHold',
        'CursorHoldI',
        'CursorMovedI'
      }
      for _, e in ipairs(events) do
        events[#events+1] = e
      end
    end

    au[('%s *.md'):format(join(events, ","))] = ('lua %s'):format(strfun('auto_generate()'))
  end

  --- auto-open previewer
  if cfg.auto_open() then
    preview.open()
  end

  --- attach autocmds
  if not vim.tbl_isempty(au) then
    nvim.augroup("preview", au)
  end

  --- attach mappings
  local rmaps = util.kv_reverse(maps)

  nvim.map({
    ['nx|' .. _cfg.leader .. rmaps['open_pdf']] = strfun("open('pdf')"),
    ['nx|' .. _cfg.leader .. rmaps['open_html']] = strfun("open('html')")
  })

end

return preview
