-- Simple LazyVim-inspired Neovim config
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Active colorscheme (see lua/theme.lua). Switch at runtime with :Theme <name>.
-- onedark_dark | onedark | onedark_vivid | onelight | vaporwave | catppuccin-mocha
vim.g.theme = "onedark_dark"

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.pack")
require("config.build")
require("config.dev")

-- Applies vim.g.theme once the plugins (colorschemes) are loaded.
require("theme").setup()
