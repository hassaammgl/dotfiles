-- Soften huge files before plugins pile on
vim.api.nvim_create_autocmd("BufReadPre", {
  group = vim.api.nvim_create_augroup("bigfile_guard", { clear = true }),
  callback = function(ev)
    local ok, size = pcall(vim.fn.getfsize, ev.file)
    if ok and size > 300 * 1024 then
      vim.b[ev.buf].completion = false
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
    end
  end,
})

-- Keep tmux bar colors in sync with nvim moods
require("utils.moods").setup()
