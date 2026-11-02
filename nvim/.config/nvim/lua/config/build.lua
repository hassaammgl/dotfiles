-- Build / run / test integration.
--
-- Nothing runs in the background: every command is started on demand and the
-- build goes through Neovim's native :make, so output lands in the quickfix
-- list (:copen, :cnext, :cprev) with no extra plugin.
--
--   :Build   <leader>cb     build the current project
--   :Run     <leader>cr     run it in a terminal (toggleterm if available)
--   :Test    <leader>ct     run the project's tests
--
-- Project type is detected from the current buffer's filetype first, then from
-- marker files walking up from the file. Existing project configuration and
-- lockfiles decide the tool (bun/deno/pnpm/yarn/npm, mvnw/gradlew, generator).

local M = {}

local EFM = table.concat({
  "%f:%l:%c: %m",
  "%f:%l: %m",
  "%f(%l\\,%c): %m",
  "%f(%l): %m",
  "%-G%.%#",
}, ",")

---@param names string[]
---@param start string
---@return string?
local function find_up(names, start)
  for _, name in ipairs(names) do
    local path = vim.fs.find(name, { upward = true, path = start, type = "file" })[1]
    if path then
      return path
    end
  end
end

---@param path string
---@return boolean
local function executable(path)
  return vim.fn.executable(path) == 1
end

---@return string
local function jobs()
  local n = tonumber(vim.fn.system("nproc 2>/dev/null")) or 0
  if n < 1 then
    n = 4
  end
  return tostring(n)
end

---@param start string
---@return "bun"|"pnpm"|"yarn"|"npm"|nil
local function js_package_manager(start)
  if find_up({ "bun.lock", "bun.lockb" }, start) then
    return "bun"
  elseif find_up({ "pnpm-lock.yaml" }, start) then
    return "pnpm"
  elseif find_up({ "yarn.lock" }, start) then
    return "yarn"
  elseif find_up({ "package-lock.json" }, start) then
    return "npm"
  end
  if executable("bun") then
    return "bun"
  end
  return executable("npm") and "npm" or nil
end

---@class Project
---@field kind string
---@field root string
---@field build? string
---@field run? string
---@field test? string
---@field configure? string

---@param bufnr integer
---@return Project?
function M.detect(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr or 0)
  local start = name ~= "" and vim.fs.dirname(name) or vim.uv.cwd()
  local ft = vim.bo[bufnr or 0].filetype

  if ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" or ft == "cuda" or ft == "cmake" then
    local cmake = find_up({ "CMakeLists.txt" }, start)
    if cmake then
      local root = vim.fs.dirname(cmake)
      local build_dir = vim.fs.joinpath(root, "build")
      local configure
      if vim.uv.fs_stat(vim.fs.joinpath(build_dir, "CMakeCache.txt")) == nil then
        local gen = executable("ninja") and " -G Ninja" or ""
        configure = ("cmake -S . -B build%s -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"):format(gen)
      end
      return {
        kind = "cmake",
        root = root,
        configure = configure,
        build = "cmake --build build",
        test = "ctest --test-dir build --output-on-failure",
      }
    end
    local make = find_up({ "GNUmakefile", "Makefile", "makefile" }, start)
    if make then
      return {
        kind = "make",
        root = vim.fs.dirname(make),
        build = "make -j" .. jobs(),
        test = "make -j" .. jobs() .. " test",
      }
    end
    return nil
  end

  if ft == "javascript" or ft == "javascriptreact" or ft == "typescript" or ft == "typescriptreact" or ft == "json" then
    local pkg = find_up({ "package.json" }, start)
    if not pkg then
      return nil
    end
    local root = vim.fs.dirname(pkg)
    local pm = js_package_manager(root)
    if not pm then
      return nil
    end
    local ok, json = pcall(vim.json.decode, table.concat(vim.fn.readfile(pkg), ""))
    local scripts = ok and type(json.scripts) == "table" and json.scripts or {}
    local prefix = pm == "npm" and "npm run " or pm .. " run "
    local function script(name)
      return scripts[name] and (prefix .. name .. " 2>&1") or nil
    end
    return {
      kind = pm .. " (npm scripts)",
      root = root,
      build = script("build") or script("compile"),
      run = script("dev") or script("start"),
      test = script("test") or (pm == "npm" and "npm test 2>&1" or nil),
    }
  end

  if ft == "python" then
    local pyproject = find_up({ "pyproject.toml" }, start)
    local setup = find_up({ "setup.py" }, start)
    local reqs = find_up({ "requirements.txt" }, start)
    local root = pyproject and vim.fs.dirname(pyproject)
      or setup and vim.fs.dirname(setup)
      or reqs and vim.fs.dirname(reqs)
      or nil
    if not root then
      return nil
    end
    return {
      kind = "python",
      root = root,
      -- Ruff is the configured formatter/linter; use it for a cheap build check.
      build = executable("ruff") and "ruff check ." or "python -m compileall -q .",
      test = executable("pytest")
          and "python -m pytest -q"
        or "python -m unittest discover -v",
    }
  end

  if ft == "java" then
    local maven = find_up({ "pom.xml" }, start)
    if maven then
      local root = vim.fs.dirname(maven)
      local mvn = vim.uv.fs_stat(vim.fs.joinpath(root, "mvnw")) and "./mvnw" or "mvn"
      return { kind = "maven", root = root, build = mvn .. " -q -DskipTests package", test = mvn .. " test" }
    end
    local gradle = find_up({ "build.gradle", "build.gradle.kts" }, start)
    if gradle then
      local root = vim.fs.dirname(gradle)
      local gw = vim.uv.fs_stat(vim.fs.joinpath(root, "gradlew")) and "./gradlew" or "gradle"
      return { kind = "gradle", root = root, build = gw .. " build", test = gw .. " test" }
    end
    return nil
  end

  if ft == "rust" then
    local cargo = find_up({ "Cargo.toml" }, start)
    if cargo then
      return {
        kind = "cargo",
        root = vim.fs.dirname(cargo),
        build = "cargo build",
        run = "cargo run",
        test = "cargo test",
      }
    end
  end

  return nil
end

--- Run a command through :make so the output goes to the quickfix list.
---@param cmd string
---@param cwd string
---@param title string
function M.make(cmd, cwd, title)
  -- The window cwd becomes the project root: `:make` parses file paths
  -- relative to it, and quickfix jumps keep working from there.
  vim.cmd.lcd(vim.fn.fnameescape(cwd))
  vim.o.makeprg = cmd
  vim.o.errorformat = EFM
  vim.cmd("silent make")

  local errors = 0
  for _, item in ipairs(vim.fn.getqflist()) do
    if item.valid == 1 then
      errors = errors + 1
    end
  end
  if errors > 0 then
    vim.cmd("botright cwindow")
  end

  vim.notify(
    ("%s: %d error(s) - %s"):format(title, errors, cmd),
    errors > 0 and vim.log.levels.WARN or vim.log.levels.INFO
  )
end

---@param cmd string
---@param cwd string
function M.run_in_terminal(cmd, cwd)
  local ok, toggleterm = pcall(require, "toggleterm")
  if ok then
    toggleterm.exec(cmd, 15, "horizontal", nil, nil, cwd)
    return
  end
  vim.cmd("botright split")
  vim.cmd.lcd(vim.fn.fnameescape(cwd))
  vim.cmd("terminal " .. cmd)
end

---@param project Project
local function ensure_cmake_compile_commands(project)
  local db = vim.fs.joinpath(project.root, "build", "compile_commands.json")
  local link = vim.fs.joinpath(project.root, "compile_commands.json")
  if vim.uv.fs_stat(db) and vim.uv.fs_stat(link) == nil then
    vim.uv.fs_symlink(db, link)
    vim.notify("cmake: linked compile_commands.json for clangd", vim.log.levels.INFO)
  end
end

function M.build()
  local project = M.detect(0)
  if not project then
    vim.notify("Build: no supported project detected", vim.log.levels.WARN)
    return
  end
  if not project.build then
    vim.notify(("Build: %s project has no build command"):format(project.kind), vim.log.levels.WARN)
    return
  end
  if project.kind == "cmake" and project.configure then
    M.make(project.configure, project.root, "CMake configure")
    if not vim.uv.fs_stat(vim.fs.joinpath(project.root, "build", "CMakeCache.txt")) then
      vim.notify("Build: cmake configure failed", vim.log.levels.ERROR)
      return
    end
    ensure_cmake_compile_commands(project)
  end
  M.make(project.build, project.root, "Build")
end

function M.run()
  local project = M.detect(0)
  if not project then
    vim.notify("Run: no supported project detected", vim.log.levels.WARN)
    return
  end
  if not project.run then
    vim.notify(
      ("Run: no run command for %s - use :terminal (toggleterm is available with <C-`>)"):format(project.kind),
      vim.log.levels.WARN
    )
    return
  end
  M.run_in_terminal(project.run, project.root)
end

function M.test()
  local project = M.detect(0)
  if not project or not project.test then
    vim.notify("Test: no test command detected for this project", vim.log.levels.WARN)
    return
  end
  M.make(project.test, project.root, "Test")
end

function M.setup()
  vim.api.nvim_create_user_command("Build", M.build, { desc = "Build current project" })
  vim.api.nvim_create_user_command("Run", M.run, { desc = "Run current project in a terminal" })
  vim.api.nvim_create_user_command("Test", M.test, { desc = "Run current project tests" })

  vim.keymap.set("n", "<leader>cb", M.build, { desc = "Build project" })
  vim.keymap.set("n", "<leader>cr", M.run, { desc = "Run project" })
  vim.keymap.set("n", "<leader>ct", M.test, { desc = "Test project" })
end

M.setup()

return M
