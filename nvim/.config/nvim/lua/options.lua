-- Let neo-tree take over directory browsing
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt

-- line numbers
opt.number = true
opt.relativenumber = true

-- Tabs and indentations
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Search & System
opt.ignorecase = true
opt.smartcase = true
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.undofile = true -- Persistent undo history
opt.updatetime = 250
opt.timeoutlen = 300

-- Splits & UI
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.scrolloff = 8
