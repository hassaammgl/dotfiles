-- Plugin management for Neovim 0.12 using the built-in `vim.pack`.
--
-- This replaced the lazy.nvim bootstrap (lua/config/lazy.lua and
-- lazy-lock.json are gone). The plugin specs in lua/plugins/*.lua are reused
-- unchanged: `opts`, `config`, `main`, `keys`, `dependencies`, `branch` and
-- `version` are all still honored. No plugin file had to be rewritten.
--
-- Differences vs lazy.nvim, on purpose:
--   * everything is loaded at startup (~24 plugins, no rtp juggling);
--     startup stays in the tens of milliseconds and there are no background
--     handlers or daemons.
--   * install/update/clean is `vim.pack` native:
--       :PackUpdate  -> review + apply updates (also aliased as :Lazy)
--       :PackSync    -> reinstall/realign to nvim-pack-lock.json
--       :PackStatus  -> list managed plugins and their state
--       :PackClean   -> remove plugins that are no longer in the specs
--   * the lockfile is nvim-pack-lock.json (commit it with the dotfiles).

local M = {}

local GH = "https://github.com/"

--- True when `src` is already a complete git remote: URL scheme or scp-like
--- SSH (`git@github.com:owner/repo`). Anything else is `owner/repo` shorthand.
---@param src string
---@return boolean
local function is_remote(src)
  return src:match("^%a[%w+.-]*://") ~= nil or src:match("^[%w._-]+@[%w._-]+:") ~= nil
end

---@class PackSpec
---@field src string
---@field name string
---@field version? string|table
---@field opts? table
---@field config? fun(plug: PackSpec, opts?: table)
---@field main? string
---@field keys? table[]
---@field build? string|string[]
---@field dev? string
---@field priority? integer
---@field dependencies? table

--- Normalize a lazy.nvim style spec into a vim.pack spec + setup data.
---@param raw string|table
---@return PackSpec?
local function normalize(raw)
  if type(raw) == "string" then
    raw = { raw }
  end
  local src = raw[1] or raw.src
  if type(src) ~= "string" then
    return nil
  end

  if not is_remote(src) then
    -- Bare name ("catppuccin" as a dependency) refers to an existing package.
    if not src:match("/") then
      return nil
    end
    src = GH .. src
  end

  local name = raw.name or src:match("([^/]+)$"):gsub("%.git$", "")
  -- lazy.nvim `version = "*"` means "latest release"; track the default branch.
  -- Semver ranges ("1.*", ">=1.2") become real ranges, not git refs.
  local version = raw.branch or raw.version
  if type(version) == "string" then
    if version == "*" or version == "" then
      version = nil
    elseif version:match("[%*%^~<>=]") then
      version = vim.version.range(version)
    end
  end

  return {
    src = src,
    name = name,
    version = version,
    opts = raw.opts,
    config = raw.config,
    main = raw.main,
    keys = raw.keys,
    build = raw.build,
    dev = raw.dev,
    priority = raw.priority or 100,
    dependencies = raw.dependencies,
  }
end

--- Collect specs from a list, dependencies first, de-duplicated by name.
---@param list table
---@param out PackSpec[]
---@param seen table<string, true>
local function collect(list, out, seen)
  for _, raw in ipairs(list) do
    local spec = normalize(raw)
    if spec and not seen[spec.name] then
      seen[spec.name] = true
      local deps = type(raw) == "table" and raw.dependencies or nil
      if type(deps) == "table" then
        collect(deps, out, seen)
      elseif type(deps) == "string" then
        collect({ deps }, out, seen)
      end
      out[#out + 1] = spec
    end
  end
end

---@return PackSpec[]
local function load_specs()
  local dir = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "plugins")
  local files = vim.fn.globpath(dir, "*.lua", false, true)
  table.sort(files)

  local specs, seen = {}, {}
  for _, file in ipairs(files) do
    local ok, mod = pcall(dofile, file)
    if ok and type(mod) == "table" then
      collect(mod, specs, seen)
    elseif not ok then
      vim.schedule(function()
        vim.notify(("pack: failed to load %s\n%s"):format(file, mod), vim.log.levels.ERROR)
      end)
    end
  end

  -- Stable sort by priority: catppuccin (1000) must apply before anything that
  -- reads its palette (lualine, bufferline, ...).
  for i, s in ipairs(specs) do
    s._i = i
  end
  table.sort(specs, function(a, b)
    if a.priority ~= b.priority then
      return a.priority > b.priority
    end
    return a._i < b._i
  end)
  return specs
end

--- Module name lazy.nvim would have inferred (repo basename minus ".nvim").
---@param spec PackSpec
---@return string
local function main_module(spec)
  if spec.main then
    return spec.main
  end
  return (spec.name:gsub("%.nvim$", ""))
end

--- Each plugin spec loaded from lua/plugins/*.lua (see lua/config/pack.lua).
---@type PackSpec[]
M.specs = {}

---@param spec PackSpec
local function apply_keys(spec)
  if type(spec.keys) ~= "table" then
    return
  end
  for _, key in ipairs(spec.keys) do
    if type(key) == "table" and key[1] and key[2] then
      local opts = {}
      for k, v in pairs(key) do
        if type(k) == "string" and k ~= "mode" then
          opts[k] = v
        end
      end
      local ok, err = pcall(vim.keymap.set, key.mode or "n", key[1], key[2], opts)
      if not ok then
        vim.schedule(function()
          vim.notify(("pack: keymap %s from %s failed: %s"):format(key[1], spec.name, err), vim.log.levels.WARN)
        end)
      end
    end
  end
end

---@param spec PackSpec
local function setup(spec)
  -- `cmd` is intentionally ignored: plugins are loaded at startup and create
  -- their own user commands, so stubs would collide with them.
  apply_keys(spec)

  if spec.config then
    local ok, err = pcall(spec.config, spec, spec.opts)
    if not ok then
      vim.schedule(function()
        vim.notify(("pack: config for %s failed:\n%s"):format(spec.name, err), vim.log.levels.ERROR)
      end)
    end
    return
  end

  if spec.opts ~= nil then
    local ok, mod = pcall(require, main_module(spec))
    if not ok then
      vim.schedule(function()
        vim.notify(("pack: cannot require %s\n%s"):format(spec.name, mod), vim.log.levels.WARN)
      end)
      return
    end
    if type(mod.setup) ~= "function" then
      vim.schedule(function()
        vim.notify(("pack: %s has opts but no setup()"):format(spec.name), vim.log.levels.WARN)
      end)
      return
    end
    local ok2, err = pcall(mod.setup, spec.opts)
    if not ok2 then
      vim.schedule(function()
        vim.notify(("pack: setup for %s failed:\n%s"):format(spec.name, err), vim.log.levels.ERROR)
      end)
    end
  end
end

--- Build hooks: every spec's `build` field (":TSUpdate" for nvim-treesitter,
--- "make" / "cargo build" / ... for anything else), keyed by plugin name.
---@type table<string, string>
local builds = {}

--- `:Lazy` compatibility: the alpha dashboard and old muscle memory use it.
function M.update()
  vim.pack.update()
end

function M.status()
  local managed = vim.pack.get()
  local active, inactive = 0, 0
  for _, plug in ipairs(managed) do
    if plug.active then
      active = active + 1
    else
      inactive = inactive + 1
    end
  end
  vim.notify(
    ("vim.pack: %d managed, %d loaded, %d not loaded\n%s"):format(
      #managed,
      active,
      inactive,
      table.concat(vim.tbl_map(function(p)
        return ("  %s%s"):format(p.spec.name, p.active and "" or " (inactive)")
      end, managed), "\n")
    ),
    vim.log.levels.INFO
  )
end

function M.sync()
  vim.pack.update(nil, { target = "lockfile" })
end

function M.clean()
  local unused = vim.iter(vim.pack.get())
    :filter(function(p)
      return not p.active
    end)
    :map(function(p)
      return p.spec.name
    end)
    :totable()
  if #unused == 0 then
    vim.notify("vim.pack: nothing to clean", vim.log.levels.INFO)
    return
  end
  vim.pack.del(unused)
end

---@return PackSpec[]
function M.load()
  local specs = load_specs()
  M.specs = specs

  -- Collect `build` hooks declared in the specs before installing, so they run
  -- on install/update via the PackChanged event below.
  for _, spec in ipairs(specs) do
    if type(spec.build) == "table" then
      builds[spec.name] = table.concat(spec.build, " ")
    elseif type(spec.build) == "string" then
      builds[spec.name] = spec.build
    end
  end

  vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
      local name, kind = ev.data.spec.name, ev.data.kind
      local cmd = builds[name]
      if not cmd or kind == "delete" then
        return
      end
      if not ev.data.active then
        pcall(vim.cmd.packadd, name)
      end
      if cmd:sub(1, 1) == ":" then
        pcall(vim.cmd, cmd)
      else
        -- Shell build ("make", "cargo build", ...): run in the plugin dir,
        -- never blocking startup.
        vim.system(cmd, { cwd = ev.data.path, text = true }, function(out)
          if out.code ~= 0 then
            vim.schedule(function()
              vim.notify(
                ("pack: build failed for %s (%s):\n%s"):format(name, cmd, out.stderr or out.stdout or ""),
                vim.log.levels.ERROR
              )
            end)
          end
        end)
      end
    end,
  })

  local packs = {}
  local dev = {}
  for _, spec in ipairs(specs) do
    -- `dev = "~/path"` uses a local checkout instead of the managed copy:
    -- prepended to runtimepath, never installed/updated by vim.pack
    -- (same idea as lazy.nvim's dev mode). Remove the field to go back to git.
    if type(spec.dev) == "string" then
      local dir = vim.fn.expand(spec.dev)
      if vim.fn.isdirectory(dir) == 1 then
        vim.opt.rtp:prepend(dir)
        dev[spec.name] = true
      else
        vim.schedule(function()
          vim.notify(
            ("pack: dev path for %s does not exist (%s) - using the managed copy"):format(spec.name, dir),
            vim.log.levels.WARN
          )
        end)
      end
    end
    if not dev[spec.name] then
      packs[#packs + 1] = {
        src = spec.src,
        name = spec.name,
        version = spec.version,
      }
    end
  end

  local ok, err = pcall(vim.pack.add, packs, { load = true, confirm = false })
  if not ok then
    vim.schedule(function()
      vim.notify(("vim.pack: install/load failed:\n%s"):format(err), vim.log.levels.ERROR)
    end)
  end

  for _, spec in ipairs(specs) do
    local t0 = vim.uv.hrtime()
    setup(spec)
    if vim.env.PACK_DEBUG then
      io.stderr:write(("  setup %-24s %7.2fms\n"):format(spec.name, (vim.uv.hrtime() - t0) / 1e6))
    end
  end

  vim.api.nvim_create_user_command("PackUpdate", M.update, { desc = "Update plugins (vim.pack)" })
  vim.api.nvim_create_user_command("PackSync", M.sync, { desc = "Sync plugins to nvim-pack-lock.json" })
  vim.api.nvim_create_user_command("PackStatus", M.status, { desc = "Show managed plugins" })
  vim.api.nvim_create_user_command("PackClean", M.clean, { desc = "Remove unmanaged plugins" })
  vim.api.nvim_create_user_command("Lazy", M.update, { desc = "Update plugins (vim.pack alias)" })

  return specs
end

M.load()

return M
