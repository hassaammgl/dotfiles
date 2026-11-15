-- Reference docs inside Neovim: man pages (C, POSIX, syscalls, tools) and the
-- C++ standard library via cppman (cppreference), because C++ has no man pages.
--
--   <leader>fm  pick any installed man page (sections 1-9), fuzzy + preview
--   <leader>fM  C++ reference: cached pages picker, Ctrl-E for a new page
--   gK          doc for the word under the cursor (man 2/3/7, cppman in C++)
--   :CppMan std::map      same page without leaving the keyboard
--   :Man 3 printf / :Man 2 write / :Man 7 socket   built-in, unchanged
local M = {}

-- Sections are probed in this order: syscall first, then libc, then misc.
-- (`man -w -s 3 write` also matches write.3p, hence the explicit order.)
local man_sections = { "2", "3", "7", "1" }
local cpp_ft = { cpp = true, cuda = true, objcpp = true }
local c_ft = { c = true, objc = true }

---@return string?
local function cword()
  local word = vim.fn.expand("<cword>")
  return word ~= "" and word or nil
end

--- `<cword>` stops at `:`, so `std::vector` would become `std`. C++ pages need
--- the whole qualified name: grab the identifier chain around the cursor.
---@return string?
local function cpp_word()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-based byte column
  for start, word, stop in line:gmatch("()([%a_][%w_:]*)()") do
    if start <= col and col <= stop then
      return (word:gsub(":+$", ""))
    end
  end
  return cword()
end

--- Section that actually has this page (`man -w`), cached per word.
local section_cache = {}

---@param word string
---@return string?
local function find_section(word)
  if section_cache[word] ~= nil then
    return section_cache[word] ~= false and section_cache[word] or nil
  end
  for _, section in ipairs(man_sections) do
    local path = vim.fn.systemlist({ "man", "-w", "-s", section, word })
    if vim.v.shell_error == 0 and path[1] and path[1] ~= "" then
      section_cache[word] = section
      return section
    end
  end
  section_cache[word] = false
  return nil
end

--- `:Man` in a vertical split. Without a known section, let man decide.
---@param word string
---@param section? string
function M.man(word, section)
  section = section or find_section(word)
  local cmd = section
      and ("vertical Man %s %s"):format(section, vim.fn.fnameescape(word))
    or ("vertical Man %s"):format(vim.fn.fnameescape(word))
  local ok, err = pcall(vim.cmd, cmd)
  if not ok then
    vim.notify(("man: no page for %q (%s)"):format(word, err), vim.log.levels.WARN)
  end
end

--- Pages already rendered by cppman (~/.cache/cppman/<source>/<page>.3.gz).
---@return string[]
local function cppman_cached()
  local root = vim.fs.joinpath(vim.env.XDG_CACHE_HOME or (vim.env.HOME .. "/.cache"), "cppman")
  local seen, pages = {}, {}
  for _, source in ipairs({ "cppreference.com", "cplusplus.com" }) do
    local ok, iter = pcall(vim.fs.dir, vim.fs.joinpath(root, source))
    if ok then
      for name in iter do
        local page = name:gsub("%.gz$", ""):gsub("%.%d+p?$", "")
        if page ~= "" and not seen[page] then
          seen[page] = true
          pages[#pages + 1] = page
        end
      end
    end
  end
  table.sort(pages)
  return pages
end

--- Render a C++ page. cppman pipes its output through man, so it comes back
--- man-formatted; the call is async because a cold page hits the network.
---@param page string
---@return boolean ok false only when cppman is missing
function M.cppman(page)
  if vim.fn.executable("cppman") == 0 then
    vim.notify("cppman is not installed (sudo pacman -S cppman)", vim.log.levels.WARN)
    return false
  end

  vim.notify("cppman: looking up " .. page, vim.log.levels.INFO)
  vim.system({ "cppman", page }, { text = true }, function(out)
    vim.schedule(function()
      if out.code ~= 0 or not out.stdout or vim.trim(out.stdout) == "" then
        local msg = vim.trim(out.stderr or ""):gsub("%s*\n%s*", " ")
        vim.notify(("cppman: no page for %q%s"):format(page, msg ~= "" and (" - " .. msg) or ""), vim.log.levels.WARN)
        return
      end
      require("config.float").open("cppman " .. page, vim.split(vim.trim(out.stdout, "\n"), "\n"), "man")
    end)
  end)
  return true
end

--- Word under cursor -> best doc for the current filetype.
function M.keyword()
  local is_cpp = cpp_ft[vim.bo.filetype] == true
  local word = is_cpp and cpp_word() or cword()
  if not word then
    vim.notify("No word under cursor", vim.log.levels.INFO)
    return
  end
  if is_cpp and M.cppman(word) then
    return
  end
  M.man(word)
end

--- Fuzzy picker over every installed man page (`man -k .`).
function M.man_picker()
  require("fzf-lua").manpages({
    prompt = "man> ",
    winopts = { height = 0.85, width = 0.85 },
  })
end

--- Ask for a C++ page name and show it.
function M.cppman_prompt()
  vim.ui.input({ prompt = "C++ page (e.g. std::map): ", default = cword() or "" }, function(input)
    if input and vim.trim(input) ~= "" then
      M.cppman(vim.trim(input))
    end
  end)
end

--- Cached C++ pages in a picker; Ctrl-E escapes to a free-form lookup.
function M.cppman_picker()
  if vim.fn.executable("cppman") == 0 then
    vim.notify("cppman is not installed (sudo pacman -S cppman)", vim.log.levels.WARN)
    return
  end

  local pages = cppman_cached()
  if vim.tbl_isempty(pages) then
    -- First run, nothing cached yet: just ask for a page.
    M.cppman_prompt()
    return
  end

  require("fzf-lua").fzf_exec(pages, {
    prompt = "cppman> ",
    preview = "cppman {} 2>/dev/null",
    preview_window = "right:60%:wrap",
    winopts = { height = 0.85, width = 0.85 },
    actions = {
      ["enter"] = function(selected)
        if selected and selected[1] then
          M.cppman(selected[1])
        end
      end,
      ["ctrl-e"] = M.cppman_prompt,
    },
  })
end

function M.setup()
  local map = vim.keymap.set

  map("n", "gK", M.keyword, { desc = "Man page / C++ ref for word" })
  map("n", "<leader>fm", M.man_picker, { desc = "Man pages" })
  map("n", "<leader>fM", M.cppman_picker, { desc = "C++ reference (cppman)" })

  vim.api.nvim_create_user_command("CppMan", function(args)
    if args.args == "" then
      M.cppman_picker()
    else
      M.cppman(args.args)
    end
  end, {
    nargs = "?",
    desc = "C++ reference page (cppman)",
    complete = function(lead)
      return vim.tbl_filter(function(page)
        return vim.startswith(page, lead)
      end, cppman_cached())
    end,
  })

  -- Man pages are read-only and long: wrap them, drop the gutters, close with q.
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "man",
    callback = function(ev)
      vim.wo.number = false
      vim.wo.relativenumber = false
      vim.wo.signcolumn = "no"
      vim.wo.wrap = true
      vim.wo.linebreak = true
      map("n", "q", "<cmd>close<CR>", { buffer = ev.buf, desc = "Close man page" })
    end,
  })
end

return M
