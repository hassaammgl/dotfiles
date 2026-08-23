return {
  -- Catppuccin Mocha — soft, polished dark theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      term_colors = true,
      dim_inactive = { enabled = true, percentage = 0.12 },
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        keywords = { "italic" },
      },
      integrations = {
        alpha = true,
        cmp = true,
        gitsigns = true,
        indent_blankline = { enabled = true, scope_color = "lavender", colored_indent_levels = false },
        lsp_trouble = true,
        markdown = true,
        mason = false,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        neotree = true,
        treesitter = true,
        which_key = true,
        telescope = false,
        notify = false,
      },
      custom_highlights = function(colors)
        return {
          AlphaHeader = { fg = colors.mauve, style = { "bold" } },
          AlphaButtons = { fg = colors.text },
          AlphaShortcut = { fg = colors.peach },
          AlphaFooter = { fg = colors.overlay0, style = { "italic" } },
          FloatBorder = { fg = colors.blue, bg = colors.mantle },
          NormalFloat = { bg = colors.mantle },
          NeoTreeNormal = { bg = colors.mantle },
          NeoTreeNormalNC = { bg = colors.mantle },
          CursorLine = { bg = colors.surface0 },
        }
      end,
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Clean start screen (no snacks)
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        [[███╗   ██╗██╗   ██╗██╗███╗   ███╗]],
        [[████╗  ██║██║   ██║██║████╗ ████║]],
        [[██╔██╗ ██║██║   ██║██║██╔████╔██║]],
        [[██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
        [[██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║]],
        [[╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file", "<cmd>FzfLua files<CR>"),
        dashboard.button("n", "  New file", "<cmd>ene | startinsert<CR>"),
        dashboard.button("g", "  Find text", "<cmd>FzfLua live_grep<CR>"),
        dashboard.button("r", "  Recent files", "<cmd>FzfLua oldfiles<CR>"),
        dashboard.button("e", "  Explorer", "<cmd>Neotree filesystem reveal left<CR>"),
        dashboard.button("c", "  Config", "<cmd>FzfLua files cwd=" .. vim.fn.stdpath("config") .. "<CR>"),
        dashboard.button("s", "  Restore session", [[<cmd>lua require("persistence").load()<CR>]]),
        dashboard.button("l", "󰒲  Lazy", "<cmd>Lazy<CR>"),
        dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
      }

      dashboard.section.footer.val = "catppuccin · mocha"
      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.footer.opts.hl = "AlphaFooter"
      dashboard.config.layout[1].val = 6

      alpha.setup(dashboard.config)

      vim.api.nvim_create_autocmd("User", {
        pattern = "AlphaReady",
        callback = function()
          vim.opt_local.showtabline = 0
        end,
      })
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      delay = 250,
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>l", group = "lsp" },
        { "<leader>g", group = "git" },
        { "<leader>b", group = "buffers" },
        { "<leader>x", group = "diagnostics" },
        { "<leader>t", group = "terminal" },
        { "<leader>u", group = "ui" },
        { "<leader>m", group = "macros" },
        { "<leader>c", group = "code" },
        { "<leader>s", group = "session" },
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin" },
    event = "VeryLazy",
    config = function()
      local ok, palettes = pcall(require, "catppuccin.palettes")
      local c = ok and palettes.get_palette("mocha") or nil

      local theme = "auto"
      if c then
        theme = {
          normal = {
            a = { fg = c.base, bg = c.blue, gui = "bold" },
            b = { fg = c.text, bg = c.surface0 },
            c = { fg = c.text, bg = c.mantle },
          },
          insert = {
            a = { fg = c.base, bg = c.green, gui = "bold" },
            b = { fg = c.text, bg = c.surface0 },
            c = { fg = c.text, bg = c.mantle },
          },
          visual = {
            a = { fg = c.base, bg = c.mauve, gui = "bold" },
            b = { fg = c.text, bg = c.surface0 },
            c = { fg = c.text, bg = c.mantle },
          },
          replace = {
            a = { fg = c.base, bg = c.red, gui = "bold" },
            b = { fg = c.text, bg = c.surface0 },
            c = { fg = c.text, bg = c.mantle },
          },
          command = {
            a = { fg = c.base, bg = c.peach, gui = "bold" },
            b = { fg = c.text, bg = c.surface0 },
            c = { fg = c.text, bg = c.mantle },
          },
          inactive = {
            a = { fg = c.overlay0, bg = c.mantle },
            b = { fg = c.overlay0, bg = c.mantle },
            c = { fg = c.overlay0, bg = c.mantle },
          },
        }
      end

      require("lualine").setup({
        options = {
          theme = theme,
          globalstatus = true,
          icons_enabled = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = { "alpha", "dashboard", "neo-tree" },
            winbar = {},
          },
          always_divide_middle = true,
        },
        sections = {
          lualine_a = { { "mode", icon = "" } },
          lualine_b = {
            { "branch", icon = "" },
            {
              "diff",
              symbols = { added = " ", modified = " ", removed = " " },
            },
            {
              "diagnostics",
              sources = { "nvim_diagnostic" },
              symbols = { error = " ", warn = " ", info = " ", hint = " " },
            },
          },
          lualine_c = {
            {
              "filename",
              path = 1,
              symbols = { modified = " ●", readonly = " ", unnamed = " [No Name]" },
            },
          },
          lualine_x = {
            { "encoding", cond = function() return vim.o.fileencoding ~= "utf-8" end },
            { "filetype", icon_only = false },
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "neo-tree", "lazy", "toggleterm", "trouble" },
      })
    end,
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
      { "<leader>bd", "<cmd>bdelete<CR>", desc = "Close buffer" },
      { "<leader>bp", "<cmd>BufferLineTogglePin<CR>", desc = "Pin buffer" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "Close others" },
    },
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        show_buffer_close_icons = false,
        show_close_icon = false,
        separator_style = "thin",
        offsets = {
          {
            filetype = "neo-tree",
            text = "Explorer",
            highlight = "Directory",
            text_align = "left",
            separator = true,
          },
        },
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = true, show_start = false, show_end = false },
    },
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm direction=float<CR>", desc = "Float terminal" },
      { "<leader>th", "<cmd>ToggleTerm size=15 direction=horizontal<CR>", desc = "Horizontal terminal" },
      { "<leader>tv", "<cmd>ToggleTerm size=60 direction=vertical<CR>", desc = "Vertical terminal" },
      { "<C-`>", "<cmd>ToggleTerm direction=float<CR>", desc = "Toggle terminal", mode = { "n", "t" } },
    },
    opts = {
      open_mapping = false,
      shade_terminals = true,
      float_opts = { border = "rounded" },
    },
  },

  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      {
        "<leader>ss",
        function()
          require("persistence").load()
        end,
        desc = "Restore session",
      },
      {
        "<leader>sl",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore last session",
      },
      {
        "<leader>sd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't save session",
      },
    },
  },
}
