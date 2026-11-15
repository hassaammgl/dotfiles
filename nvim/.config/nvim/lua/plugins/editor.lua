-- tldr cheatsheets (shell `tf` equivalent) -----------------------------------
-- `tldr --list` is a bit slow, so the list is read once and cached; a page is
-- shown in a scratch floating buffer rendered as markdown (treesitter is set
-- up for markdown already, so it gets highlighted).
local tldr_cache ---@type string[]?

local function tldr_list()
  if tldr_cache then
    return tldr_cache
  end
  tldr_cache = vim.fn.systemlist({ "tldr", "--list" })
  if vim.v.shell_error ~= 0 or vim.tbl_isempty(tldr_cache) then
    tldr_cache = nil
    vim.notify(
      "tldr: cache is empty or tldr is missing — run `tldr -u` once",
      vim.log.levels.WARN
    )
    return {}
  end
  return tldr_cache
end

---@param cmd string
local function tldr_float(cmd)
  local lines = vim.fn.systemlist({ "tldr", "--markdown", cmd })
  if vim.v.shell_error ~= 0 or vim.tbl_isempty(lines) then
    vim.notify(("tldr: no page for %q"):format(cmd), vim.log.levels.WARN)
    return
  end
  require("config.float").open("tldr " .. cmd, lines, "markdown")
end

local function tldr_pick()
  local cmds = tldr_list()
  if vim.tbl_isempty(cmds) then
    return
  end
  require("fzf-lua").fzf_exec(cmds, {
    prompt = "tldr> ",
    -- --color: tldr strips colors whenever its output is a pipe (fzf preview)
    preview = "tldr --color {} 2>&1",
    preview_window = "right:60%:wrap",
    winopts = { height = 0.85, width = 0.85 },
    actions = {
      default = function(selected)
        if selected and selected[1] then
          tldr_float(selected[1])
        end
      end,
    },
  })
end

return {
  {
    "numToStr/Comment.nvim",
    opts = {},
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
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
      -- Keep heavy dependency/build dirs out of the file picker even when the
      -- project is not a git repo (fd/rg only honor .gitignore inside one).
      -- To narrow this down, just drop the unwanted `--exclude`/`-g` entries.
      files = {
        fd_opts = "--color=never --type f --type l --exclude .git --exclude .jj"
          .. " --exclude node_modules --exclude __pycache__ --exclude .venv --exclude venv"
          .. " --exclude env --exclude .tox --exclude dist --exclude build --exclude target"
          .. " --exclude .gradle --exclude .idea --exclude .next --exclude vendor",
        rg_opts = "--color=never --files -g '!.git' -g '!.jj' -g '!node_modules'"
          .. " -g '!__pycache__' -g '!.venv' -g '!venv' -g '!env' -g '!.tox'"
          .. " -g '!dist' -g '!build' -g '!target' -g '!.gradle' -g '!.idea'"
          .. " -g '!.next' -g '!vendor'",
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
      { "<leader>ft", tldr_pick, desc = "tldr cheatsheets" },
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
    config = function(_, opts)
      require("fzf-lua").setup(opts)
      vim.api.nvim_create_user_command("Tldr", function(args)
        if args.args ~= "" then
          tldr_float(args.args)
        else
          tldr_pick()
        end
      end, { nargs = "?", desc = "tldr page or fuzzy picker" })
    end,
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
