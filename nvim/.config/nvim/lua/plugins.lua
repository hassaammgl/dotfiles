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
    local ts = require("nvim-treesitter")
    pcall(ts.setup)
    pcall(function()
      ts.install({
        "c",
        "cpp",
        "java",
        "javascript",
        "typescript",
        "tsx",
        "python",
        "lua",
        "vim",
        "vimdoc",
        "bash",
        "json",
      })
    end)

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(ev)
        pcall(vim.treesitter.start, ev.buf)
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

  -- 5. LSP — system binaries only (no Mason)
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.diagnostic.config({
        virtual_text = { spacing = 2, source = "if_many" },
        severity_sort = true,
        signs = true,
        underline = true,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        end,
      })

      vim.lsp.config("clangd", {
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
      })

      local function enable_if(bins, server)
        for _, bin in ipairs(bins) do
          if vim.fn.executable(bin) == 1 then
            vim.lsp.enable(server)
            return
          end
        end
      end

      enable_if({ "clangd" }, "clangd")
      if vim.fn.executable("basedpyright") == 1 then
        vim.lsp.enable("basedpyright")
      else
        enable_if({ "pyright", "pyright-langserver" }, "pyright")
      end
      enable_if({ "typescript-language-server" }, "ts_ls")
      enable_if({ "jdtls" }, "jdtls")
    end,
  },

  -- 6. Completion (LSP / path / buffer / snippets)
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    opts = {
      keymap = { preset = "enter" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
  },

  -- 7. Format on save — uses tools already on PATH
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>F",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "Format buffer",
      },
    },
    opts = {
      format_on_save = {
        timeout_ms = 800,
        lsp_fallback = true,
      },
      formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        java = { "google-java-format" },
        python = { "ruff_format", "black", stop_after_first = true },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },

  -- 8. Editing extras
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
})
