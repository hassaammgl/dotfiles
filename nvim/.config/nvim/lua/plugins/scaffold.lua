return {
  -- Scaffold.nvim: project creation wizard + development environment manager.
  -- No plugin dependencies, native UI (vim.ui), vim.system, JSON registry.
  {
    "git@github.com:hassaammgl/scaffold.nvim",
    main = "scaffold",
    -- Development checkout: prepended to runtimepath, so edits are live and
    -- vim.pack never clones/updates it. Remove this line to use the git copy,
    -- then `:restart` and it installs itself like any other plugin.
    dev = "~/Projects/lua/scaffold.nvim",
    opts = {
      projects_dir = "~/Projects",
      confirm_before_install = true,
      confirm_before_project_commands = true,
      open_after_create = true,
      -- Build/test/run/install logs: centered float over the editor, with its
      -- own scratch buffer (never replaces the file you are editing).
      -- Use "split" (with terminal_split) if you prefer a bottom split.
      command_window = "float",
      float = { width = 0.8, height = 0.5, border = "rounded" },
      -- Scaffold installs no global keymaps unless asked; none of these clash
      -- with keymaps.lua.
      keymaps = {
        dashboard = "<leader>P",
        create = "<leader>pn",
        open = "<leader>po",
        build = "<leader>pb",
        run = "<leader>pr",
        test = "<leader>pt",
      },
    },
  },
}
