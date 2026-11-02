return {
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
          "markdown",
          "markdown_inline",
        })
      end)

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.diagnostic.config({
        virtual_text = { spacing = 2, source = "if_many" },
        severity_sort = true,
        signs = true,
        underline = true,
        float = { border = "rounded", source = true },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map = function(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = event.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gi", vim.lsp.buf.implementation, "Go to implementation")
          map("K", vim.lsp.buf.hover, "Hover docs")
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("[d", function()
            vim.diagnostic.jump({ count = -1, float = true })
          end, "Prev diagnostic")
          map("]d", function()
            vim.diagnostic.jump({ count = 1, float = true })
          end, "Next diagnostic")
        end,
      })

      -- Server filetypes, project root markers, project-aware activation and
      -- automatic stop-on-last-buffer live in lua/config/lsp.lua.
      --   :LspStatus  running servers + attached buffers
      --   :LspStop    stop this buffer's server (:LspStop! = all)
      require("config.lsp").setup()

      -- Completion stays on blink.cmp (already installed) instead of
      -- vim.lsp.completion.enable(), so the existing completion UX is kept.
      -- Diagnostics above are the native ones (vim.diagnostic.config).
    end,
  },

  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    opts = {
      keymap = { preset = "enter" },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = { border = "rounded" },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "Format buffer",
      },
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
        lua = { "stylua" },
      },
    },
  },
}
