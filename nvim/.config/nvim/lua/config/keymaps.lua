local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map({ "n", "i" }, "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit window" })
map("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit all" })

map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Windows
map("n", "<C-h>", "<C-w>h", { desc = "Focus left" })
map("n", "<C-j>", "<C-w>j", { desc = "Focus bottom" })
map("n", "<C-k>", "<C-w>k", { desc = "Focus top" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right" })
map("n", "<C-Left>", "<C-w>h", { desc = "Focus left" })
map("n", "<C-Down>", "<C-w>j", { desc = "Focus bottom" })
map("n", "<C-Up>", "<C-w>k", { desc = "Focus top" })
map("n", "<C-Right>", "<C-w>l", { desc = "Focus right" })

map("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], opts)
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)
map("t", "<Esc>", [[<C-\><C-n>]], opts)

map("n", "<A-Up>", ":resize +2<CR>", opts)
map("n", "<A-Down>", ":resize -2<CR>", opts)
map("n", "<A-Left>", ":vertical resize -2<CR>", opts)
map("n", "<A-Right>", ":vertical resize +2<CR>", opts)

-- Buffers
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>bprevious<CR>", { desc = "Prev buffer" })

-- Editing
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)
map("i", "jk", "<Esc>", opts)

map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
map("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("n", "<A-Down>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-Up>", ":m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Macros
map("n", "<leader>mr", function()
  if vim.fn.reg_recording() == "" then
    vim.cmd("normal! qa")
    vim.notify("Recording @a...")
  else
    vim.cmd("normal! q")
    vim.notify("Macro @a saved")
  end
end, { desc = "Toggle macro record @a" })
map("n", "<leader>ma", "@a", { desc = "Play macro @a" })
map("v", "<leader>ma", ":norm @a<CR>", { desc = "Play macro @a on range" })
