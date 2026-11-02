local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- .h is ambiguous. Neovim 0.12 defaults it to "cpp", which is wrong inside a C
-- project (C parser, C indexer, C flags). Keep the cpp default, but switch to
-- "c" when the header is clearly C: C++-only syntax wins, then the surrounding
-- project decides.
local function header_is_c(path, bufnr)
  local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, 0, 80, false)
  if ok and lines then
    local text = table.concat(lines, "\n")
    if
      text:match("%f[%w]namespace%s+[%w_:]")
      or text:match("%f[%w]class%s+[%u%w_]")
      or text:match("^%s*template%s*<")
      or text:match("%f[%w]std::")
      or text:match('extern%s+"C%+%+"')
    then
      return false
    end
  end

  local dir = vim.fs.dirname(path)

  -- CMake says which languages the project uses
  local cmake = vim.fs.find("CMakeLists.txt", { path = dir, upward = true, type = "file", limit = 1 })[1]
  if cmake then
    local read_ok, content = pcall(vim.fn.readfile, cmake)
    if read_ok then
      local text = table.concat(content, "\n")
      if text:match("%f[%w]LANGUAGES%f[%W][^)]*%f[%w]C%f[%W]") and not text:match("%f[%w]CXX%f[%W]") then
        return true
      end
      if text:match("%f[%w]CXX%f[%W]") then
        return false
      end
    end
  end

  -- sibling sources: .c only means C, anything C++-only means C++
  local cpp_ext = { cpp = true, cc = true, cxx = true, hpp = true, hxx = true, ixx = true, cppm = true, mpp = true }
  local has_c, has_cpp = false, false
  for _, d in ipairs({ dir, vim.fs.dirname(dir) }) do
    local dir_ok, iter = pcall(vim.fs.dir, d)
    if dir_ok and iter then
      for name, kind in iter do
        if kind == "file" then
          local ext = name:match("%.([%w]+)$")
          if ext then
            if cpp_ext[ext] then
              has_cpp = true
            elseif ext == "c" then
              has_c = true
            end
          end
        end
      end
    end
  end
  return has_c and not has_cpp
end

vim.filetype.add({
  extension = {
    h = function(path, bufnr)
      return header_is_c(path, bufnr) and "c" or "cpp"
    end,
    -- C++20 modules
    ixx = "cpp",
    cppm = "cpp",
    mpp = "cpp",
  },
})

-- Resize splits when the window is resized
autocmd("VimResized", {
  group = augroup("resize_splits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Open neo-tree when starting on a directory
autocmd("VimEnter", {
  group = augroup("neotree_start", { clear = true }),
  callback = function(data)
    if vim.fn.isdirectory(data.file) ~= 1 then
      return
    end
    vim.cmd.cd(data.file)
    pcall(function()
      require("neo-tree.command").execute({ action = "show", dir = data.file })
    end)
  end,
})
