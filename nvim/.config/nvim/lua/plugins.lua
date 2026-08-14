-- Disable unused legacy providers to remove checkhealth warnings
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "numToStr/Comment.nvim",
        opts = {}
    },
  -- 1. nvim-tree (File Explorer)
{
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup({
      view = {
        width = 35,
        side = "left",
        float = {
          enable = true,
          open_win_config = {
            relative = "editor",
            width = 60,
            height = 30,
            row = 3,
            col = 10,
            border = "rounded",
          },
        },
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = false,
      },
    })

    vim.keymap.set(
      "n",
      "<leader>e",
      "<cmd>NvimTreeToggle<CR>",
      { desc = "Open file explorer" }
    )
  end,
},

  -- 2. fzf-lua (Fuzzy Finder)
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      -- Core & Navigation
      { "<leader><Space>", "<cmd>FzfLua files<CR>", desc = "Find files" },
      { "<leader>ff", "<cmd>FzfLua files<CR>", desc = "Find files (alt)" },
      { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Grep text across project" },
      { "<leader>fw", "<cmd>FzfLua grep_cword<CR>", desc = "Grep word under cursor" },
      { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "Search open buffers" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent files" },
      { "<leader>fh", "<cmd>FzfLua help_tags<CR>", desc = "Search help tags" },
      { "<leader>fc", "<cmd>FzfLua command_history<CR>", desc = "Command history" },

      -- Code & LSP
      { "<leader>ld", "<cmd>FzfLua lsp_definitions<CR>", desc = "LSP Go to definition" },
      { "<leader>lr", "<cmd>FzfLua lsp_references<CR>", desc = "LSP Find references" },
      { "<leader>ls", "<cmd>FzfLua lsp_document_symbols<CR>", desc = "Document symbols" },
      { "<leader>lw", "<cmd>FzfLua lsp_live_workspace_symbols<CR>", desc = "Workspace symbols" },
      { "<leader>lx", "<cmd>FzfLua diagnostics_workspace<CR>", desc = "Workspace diagnostics" },

      -- Git
      { "<leader>gs", "<cmd>FzfLua git_status<CR>", desc = "Git status (changed files)" },
      { "<leader>gc", "<cmd>FzfLua git_commits<CR>", desc = "Git commit history" },
      { "<leader>gb", "<cmd>FzfLua git_branches<CR>", desc = "Git branches" },
    },
  },

  -- 3. Treesitter (Syntax Highlighting & Parsing)
{
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    -- New main API setup
    local configs = require("nvim-treesitter")
    configs.setup({
      ensure_installed = { "c", "cpp", "java", "python", "lua", "vim", "vimdoc", "bash", "json" },
      auto_install = true,
    })

    -- Enable Treesitter highlighting per filetype
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
},
  -- 4. Gitsigns (Git changes in the sign column)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("n", "]c", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(function() gitsigns.next_hunk() end)
          return "<Ignore>"
        end, "Next hunk")
        map("n", "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gitsigns.prev_hunk() end)
          return "<Ignore>"
        end, "Prev hunk")
        map("n", "<leader>gp", gitsigns.preview_hunk, "Preview hunk")
        map("n", "<leader>gr", gitsigns.reset_hunk, "Reset hunk")
        map("n", "<leader>gs", gitsigns.stage_hunk, "Stage hunk")
      end,
    },
  },

  -- 5. Native LSP Configuration (Neovim 0.11+)
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Common Keymaps when LSP attaches to a buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })

      -- Clangd fix for unknown c.doxygen/cpp.doxygen filetypes from checkhealth
      vim.lsp.config("clangd", {
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
      })

      -- Lua LSP Setup
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
            },
          },
        },
      })

      -- Enable Language Servers
      vim.lsp.enable("clangd")   -- C / C++
      vim.lsp.enable("pyright")  -- Python (use "basedpyright" if installed)
      vim.lsp.enable("jdtls")    -- Java
      vim.lsp.enable("jsonls")   -- JSON
      vim.lsp.enable("lua_ls")   -- Lua
    end,
  },
})
