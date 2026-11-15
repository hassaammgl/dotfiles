-- Read-only floating window used for quick reference output (tldr, cppman).
-- Kept in one place so every popup behaves the same: rounded border, wrapping,
-- `q` / `<Esc>` to close and a buffer that is wiped when the window goes away.
local M = {}

---@param title string
---@param lines string[]
---@param ft? string buffer filetype for highlighting (e.g. "man", "markdown")
---@return integer? buf
function M.open(title, lines, ft)
  if type(lines) ~= "table" or vim.tbl_isempty(lines) then
    return nil
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  if ft then
    vim.bo[buf].filetype = ft
  end
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local width = math.min(math.max(60, math.floor(vim.o.columns * 0.75)), 100)
  local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.8))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
  })
  if win == 0 then
    return nil
  end

  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true

  for _, lhs in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", lhs, function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end, { buffer = buf, desc = "Close popup" })
  end

  return buf
end

return M
