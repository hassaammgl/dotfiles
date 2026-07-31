return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa",
    },
  },

  -- Focus: deep, muted, low distraction
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      theme = "dragon",
      background = { dark = "dragon", light = "lotus" },
    },
  },

  -- Energy: sharp contrast, bright accents (ships with LazyVim)
  { "folke/tokyonight.nvim", lazy = true },

  -- Chill: soft warm tones
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    opts = {
      variant = "moon",
    },
  },
}
