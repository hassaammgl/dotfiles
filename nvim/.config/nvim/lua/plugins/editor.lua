return {
  {
    "numToStr/Comment.nvim",
    opts = {},
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree filesystem toggle left<CR>", desc = "Explorer" },
      { "<leader>o", "<cmd>Neotree filesystem focus left<CR>", desc = "Focus explorer" },
      { "<leader>be", "<cmd>Neotree buffers toggle float<CR>", desc = "Buffer explorer" },
      { "<leader>ge", "<cmd>Neotree git_status toggle float<CR>", desc = "Git explorer" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      sources = { "filesystem", "buffers", "git_status" },
      source_selector = {
        winbar = false,
        statusline = false,
      },
      default_component_configs = {
        indent = { with_expanders = true, expander_collapsed = "", expander_expanded = "" },
        icon = { folder_closed = "", folder_open = "", folder_empty = "" },
        git_status = {
          symbols = {
            added = "",
            modified = "",
            deleted = "✖",
            renamed = "➜",
            untracked = "★",
            ignored = "◌",
            unstaged = "✗",
            staged = "✓",
            conflict = "",
          },
        },
      },
      filesystem = {
        bind_to_cwd = true,
        hijack_netrw_behavior = "open_default",
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
        },
        follow_current_file = { enabled = true, leave_dirs_open = false },
        use_libuv_file_watcher = true,
        group_empty_dirs = true,
      },
      window = {
        position = "left",
        width = 32,
        mappings = {
          ["<space>"] = "none",
          ["l"] = "open",
          ["h"] = "close_node",
          ["Y"] = {
            function(state)
              local node = state.tree:get_node()
              vim.fn.setreg("+", node:get_id())
              vim.notify("Copied path")
            end,
            desc = "Copy path",
          },
        },
      },
    },
  },

  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      winopts = {
        border = "rounded",
        preview = { border = "rounded" },
      },
    },
    keys = {
      { "<leader><Space>", "<cmd>FzfLua files<CR>", desc = "Find files" },
      { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Grep" },
      { "<leader>fw", "<cmd>FzfLua grep_cword<CR>", desc = "Grep word" },
      { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "Buffers" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent files" },
      { "<leader>fh", "<cmd>FzfLua help_tags<CR>", desc = "Help" },
      { "<leader>fc", "<cmd>FzfLua command_history<CR>", desc = "Command history" },
      { "<leader>ld", "<cmd>FzfLua lsp_definitions<CR>", desc = "Definitions" },
      { "<leader>lr", "<cmd>FzfLua lsp_references<CR>", desc = "References" },
      { "<leader>ls", "<cmd>FzfLua lsp_document_symbols<CR>", desc = "Document symbols" },
      { "<leader>lw", "<cmd>FzfLua lsp_live_workspace_symbols<CR>", desc = "Workspace symbols" },
      { "<leader>lx", "<cmd>FzfLua diagnostics_workspace<CR>", desc = "Diagnostics" },
      { "<leader>gs", "<cmd>FzfLua git_status<CR>", desc = "Git status" },
      { "<leader>gc", "<cmd>FzfLua git_commits<CR>", desc = "Git commits" },
      { "<leader>gb", "<cmd>FzfLua git_branches<CR>", desc = "Git branches" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = function(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next hunk")
        map("[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev hunk")
        map("<leader>gp", gs.preview_hunk, "Preview hunk")
        map("<leader>gr", gs.reset_hunk, "Reset hunk")
        map("<leader>gS", gs.stage_hunk, "Stage hunk")
      end,
    },
  },

  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix" },
    },
    opts = { focus = true },
  },

  { "echasnovski/mini.pairs", version = "*", opts = {} },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact" },
    opts = {},
  },
}
