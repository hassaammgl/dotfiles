-- Disable unused providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Let neo-tree own directory browsing
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.swapfile = false
opt.updatetime = 250
opt.timeoutlen = 300

opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.laststatus = 3
opt.showmode = false
opt.fillchars = { eob = " ", fold = " ", foldopen = "▾", foldclose = "▸" }
pcall(function()
  opt.smoothscroll = true
end)
pcall(function()
  opt.winborder = "rounded"
end)
