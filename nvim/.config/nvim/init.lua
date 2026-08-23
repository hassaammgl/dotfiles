-- Simple LazyVim-inspired Neovim config
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")

-- Theme is applied by catppuccin in plugins/ui.lua
pcall(require, "theme")
