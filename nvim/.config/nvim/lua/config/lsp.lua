-- Native LSP setup (Neovim 0.12+): vim.lsp.config / vim.lsp.enable.
--
-- Goals
--   * no server starts at startup; a server starts only when a buffer with a
--     matching filetype is opened AND a project root is found
--     (`workspace_required`), so unrelated files never spawn a server;
--   * one client per project root, shared by every buffer of that project;
--   * when the last buffer attached to a client is closed, that client is
--     stopped (1.5 s grace period, never while other buffers are attached).
--
-- Escape hatch: set `vim.g.lsp_single_file = true` before startup to allow
-- servers to run without a project root (single-file mode), e.g. for a scratch
-- .cpp in /tmp.
--
-- Servers come from nvim-lspconfig (which is only config data since 0.11);
-- this module only refines filetypes/roots and adds the lifecycle.

local M = {}

M.jdtls_ready = false

-- Directory where Arch ships qmlls (/usr/lib/qt6/bin) - not in $PATH.
local QT_BIN = "/usr/lib/qt6/bin"

---@param name string
---@return string?
local function find_exe(name)
  if vim.fn.executable(name) == 1 then
    return name
  end
  local p = vim.fs.joinpath(QT_BIN, name)
  if vim.fn.executable(p) == 1 then
    return p
  end
  return nil
end

--- Pick a JDK for jdtls: the newest one that is not newer than the JDK the
--- installed jdtls was built for (Arch's jdtls 1.62 needs JavaSE 25; a newer
--- default JVM such as 27 does not satisfy the OSGi EE requirement).
---@return string? dir
---@return integer? version
local function pick_java_home()
  local best, best_ver
  local best_any, best_any_ver
  for name, kind in vim.fs.dir("/usr/lib/jvm") do
    if kind == "directory" and name:match("^java%-%d+%-openjdk$") then
      local dir = vim.fs.joinpath("/usr/lib/jvm", name)
      local release = vim.fs.joinpath(dir, "release")
      local ok, lines = pcall(vim.fn.readfile, release)
      local raw = ok and table.concat(lines, "\n") or ""
      local ver = tonumber(raw:match('JAVA_VERSION="(%d+)'))
      if ver then
        if not best_any_ver or ver > best_any_ver then
          best_any, best_any_ver = dir, ver
        end
        if ver <= 25 and (not best_ver or ver > best_ver) then
          best, best_ver = dir, ver
        end
      end
    end
  end
  return best or best_any, best_ver or best_any_ver
end

--- Root finder that refuses to pick a root outside the requested markers.
---@param markers (string|string[])[]
---@param exclude? string[] markers that mean "this is not our project"
---@return fun(bufnr: integer, on_dir: fun(dir?: string))
local function root_dir(markers, exclude)
  return function(bufnr, on_dir)
    if exclude then
      local other = vim.fs.root(bufnr, exclude)
      local root = vim.fs.root(bufnr, markers)
      if other and (not root or #other > #root) then
        return -- e.g. a deno project while ts_ls is asked to attach
      end
    end
    local dir = vim.fs.root(bufnr, markers)
    if dir then
      on_dir(dir)
    end
  end
end

---@type table<string, {filetypes: string[], markers: (string|string[])[], override_root?: boolean, settings?: table, cmd?: string}>
local servers = {
  clangd = {
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    markers = {
      "compile_commands.json",
      "compile_flags.txt",
      ".clangd",
      "CMakeLists.txt",
      "Makefile",
      ".git",
    },
  },
  ts_ls = {
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    markers = {
      "tsconfig.json",
      "jsconfig.json",
      "package.json",
      "bun.lock",
      "bun.lockb",
      "pnpm-workspace.yaml",
      "yarn.lock",
      "package-lock.json",
      ".git",
    },
    -- nvim-lspconfig has its own root_dir (deno handling); keep the deno
    -- exclusion but use the explicit marker list above.
    override_root = true,
  },
  basedpyright = {
    filetypes = { "python" },
    markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
  },
  pyright = {
    filetypes = { "python" },
    markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
  },
  jdtls = {
    filetypes = { "java" },
    markers = {
      "pom.xml",
      "build.gradle",
      "build.gradle.kts",
      "settings.gradle",
      "settings.gradle.kts",
      ".git",
    },
  },
  lua_ls = {
    filetypes = { "lua" },
    markers = { { "stylua.toml", ".luarc.json", ".luarc.jsonc" }, ".git" },
    -- Single-file Lua is common and harmless (config editing); do not gate it.
    override_root = true,
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        workspace = {
          checkThirdParty = false,
          library = { vim.env.VIMRUNTIME },
        },
        diagnostics = { globals = { "vim" } },
        telemetry = { enable = false },
      },
    },
  },
  rust_analyzer = {
    filetypes = { "rust" },
    markers = { "Cargo.toml", ".git" },
  },
  gopls = {
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    markers = { "go.work", "go.mod", ".git" },
  },
  qmlls = {
    filetypes = { "qml", "qmljs" },
    markers = { "qmldir", ".git" },
  },
}

local function setup_servers()
  local strict = vim.g.lsp_single_file ~= true

  for name, cfg in pairs(servers) do
    ---@type vim.lsp.Config
    local conf = {
      filetypes = cfg.filetypes,
      workspace_required = strict,
    }
    if cfg.override_root or (name == "lua_ls") then
      conf.root_dir = root_dir(cfg.markers, name == "ts_ls" and { "deno.json", "deno.jsonc", "deno.lock" } or nil)
    else
      conf.root_markers = cfg.markers
    end
    if cfg.settings then
      conf.settings = cfg.settings
    end
    vim.lsp.config(name, conf)
  end

  -- lua_ls has no project root in some setups; keep it working either way.
  vim.lsp.config("lua_ls", { workspace_required = false })

  -- jdtls 1.62 is built for JavaSE 25; pin a compatible JDK instead of
  -- whatever happens to be `java` (a newer JDK 27 fails the OSGi EE check).
  local java_home, java_ver = pick_java_home()
  M.jdtls_ready = java_home ~= nil and (java_ver or 0) >= 25
  if java_home then
    vim.lsp.config("jdtls", { cmd_env = { JAVA_HOME = java_home } })
  end
end

local function enable_servers()
  local function enable(name, bin, extra)
    local exe = find_exe(bin)
    if not exe then
      return false
    end
    if extra then
      extra(exe)
    end
    vim.lsp.enable(name)
    return true
  end

  enable("clangd", "clangd")

  if find_exe("basedpyright-langserver") then
    vim.lsp.enable("basedpyright")
  else
    enable("pyright", "pyright-langserver")
  end

  enable("ts_ls", "typescript-language-server")

  if M.jdtls_ready then
    enable("jdtls", "jdtls")
  elseif find_exe("jdtls") then
    -- Do not spawn a JVM that is known to fail: say what is missing instead.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "java",
      once = true,
      callback = function()
        vim.notify(
          "jdtls 1.62 requires JavaSE 25; no compatible JDK found.\n"
            .. "Install it once with:  sudo pacman -S jdk25-openjdk\n"
            .. "then restart Neovim (Java files work without LSP until then).",
          vim.log.levels.WARN
        )
      end,
    })
  end

  enable("lua_ls", "lua-language-server")
  enable("rust_analyzer", "rust-analyzer")
  enable("gopls", "gopls")
  enable("qmlls", "qmlls", function(exe)
    vim.lsp.config("qmlls", { cmd = { exe } })
  end)
end

-- ---------------------------------------------------------------------------
-- Lifecycle: stop a server once no buffer is attached to it anymore.
-- ---------------------------------------------------------------------------

local timers = {} ---@type table<integer, uv.uv_timer_t>

---@param client vim.lsp.Client
---@return boolean
local function has_attached_buffers(client)
  return client.attached_buffers ~= nil and next(client.attached_buffers) ~= nil
end

---@param client vim.lsp.Client
---@return boolean
local function is_busy(client)
  return client.requests ~= nil and next(client.requests) ~= nil
end

---@param id integer
local function schedule_stop(id)
  if timers[id] then
    timers[id]:stop()
    timers[id]:close()
    timers[id] = nil
  end

  local timer = assert(vim.uv.new_timer())
  timers[id] = timer
  timer:start(1500, 0, vim.schedule_wrap(function()
    if timers[id] ~= timer then
      return
    end
    timer:stop()
    timer:close()
    timers[id] = nil

    local live = vim.lsp.get_client_by_id(id)
    if not live or live:is_stopped() then
      return
    end
    -- Another buffer of the same project still uses it: keep it.
    if has_attached_buffers(live) or is_busy(live) then
      return
    end

    local root = live.config.root_dir or "no workspace"
    live:stop()
    vim.notify(("LSP %s stopped (%s)"):format(live.name, root), vim.log.levels.DEBUG)
  end))
end

local function setup_lifecycle()
  vim.api.nvim_create_autocmd("LspDetach", {
    group = vim.api.nvim_create_augroup("config_lsp_lifecycle", { clear = true }),
    desc = "Stop LSP clients that no longer have any buffer",
    callback = function(ev)
      schedule_stop(ev.data.client_id)
    end,
  })
end

---@param client vim.lsp.Client
---@param bufnr integer
---@return integer number of other buffers using this client
local function other_buffers(client, bufnr)
  local n = 0
  for buf in pairs(client.attached_buffers or {}) do
    if buf ~= bufnr then
      n = n + 1
    end
  end
  return n
end

local function setup_commands()
  vim.api.nvim_create_user_command("LspStop", function(args)
    local clients = args.bang and vim.lsp.get_clients() or vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then
      vim.notify("LspStop: no LSP client for this buffer", vim.log.levels.WARN)
      return
    end
    for _, client in ipairs(clients) do
      local others = other_buffers(client, vim.api.nvim_get_current_buf())
      if others > 0 and not args.bang then
        vim.notify(
          ("LspStop: %s serves %d other buffer(s), not stopped (use :LspStop!)"):format(client.name, others),
          vim.log.levels.WARN
        )
      else
        client:stop()
        vim.notify(("LspStop: %s stopped"):format(client.name), vim.log.levels.INFO)
      end
    end
  end, { bang = true, desc = "Stop LSP client(s) of the current buffer (bang: all clients)" })

  vim.api.nvim_create_user_command("LspStatus", function()
    local clients = vim.lsp.get_clients()
    if #clients == 0 then
      vim.notify("LspStatus: no running language servers", vim.log.levels.INFO)
      return
    end
    local lines = {}
    for _, client in ipairs(clients) do
      lines[#lines + 1] = ("%s  buffers=%d  root=%s"):format(
        client.name,
        vim.tbl_count(client.attached_buffers or {}),
        client.config.root_dir or "-"
      )
    end
    vim.notify("LspStatus:\n" .. table.concat(lines, "\n"), vim.log.levels.INFO)
  end, { desc = "Show running LSP clients and their buffers" })
end

function M.setup()
  setup_servers()
  enable_servers()
  setup_lifecycle()
  setup_commands()
end

return M
