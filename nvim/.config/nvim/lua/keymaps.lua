vim.g.mapleader = " "

vim.g.maplocalleader = " "

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map({'n','i'}, "<C-s>", "<cmd>w<CR>",{desc= "Save file.."})
map('n', "<leader>q", "<cmd>q<CR>",{desc= "quit window"})

-- clear search highlight
map('n', "<Esc>", "<cmd>nohlsearch<CR>")

-- Better window navigation
map('n', '<C-h>', '<C-w>h', vim.tbl_extend('force', opts, { desc = "Focus left window" }))
map('n', '<C-j>', '<C-w>j', vim.tbl_extend('force', opts, { desc = "Focus bottom window" }))
map('n', '<C-k>', '<C-w>k', vim.tbl_extend('force', opts, { desc = "Focus top window" }))
map('n', '<C-l>', '<C-w>l', vim.tbl_extend('force', opts, { desc = "Focus right window" }))

-- Navigate windows using Ctrl + Arrow keys
map('n', '<C-Left>',  '<C-w>h', vim.tbl_extend('force', opts, { desc = "Focus left window" }))
map('n', '<C-Down>',  '<C-w>j', vim.tbl_extend('force', opts, { desc = "Focus bottom window" }))
map('n', '<C-Up>',    '<C-w>k', vim.tbl_extend('force', opts, { desc = "Focus top window" }))
map('n', '<C-Right>', '<C-w>l', vim.tbl_extend('force', opts, { desc = "Focus right window" }))

-- Navigate out of Neovim terminal splits using Ctrl + hjkl
map('t', '<C-h>', [[<C-\><C-n><C-w>h]], opts)
map('t', '<C-j>', [[<C-\><C-n><C-w>j]], opts)
map('t', '<C-k>', [[<C-\><C-n><C-w>k]], opts)
map('t', '<C-l>', [[<C-\><C-n><C-w>l]], opts)

-- Resize windows using Alt + Arrow keys
map('n', '<A-Up>', ':resize +2<CR>', opts)
map('n', '<A-Down>', ':resize -2<CR>', opts)
map('n', '<A-Left>', ':vertical resize -2<CR>', opts)
map('n', '<A-Right>', ':vertical resize +2<CR>', opts)

-- Stay in Visual mode after indenting with > or <
map('v', '<', '<gv', opts)
map('v', '>', '>gv', opts)

-- Fast escape from Insert mode using 'jk'
map('i', 'jk', '<Esc>', opts)

map('n', '<leader>r', function()
  if vim.fn.reg_recording() == '' then
    vim.cmd('normal! qa')
    print("Recording @a...")
  else
    vim.cmd('normal! q')
    print("Macro @a saved!")
  end
end, opts)

map('n', '<leader>a', '@a', opts)

map('v', '<leader>a', ':norm @a<CR>', { desc = "Run macro @a on visual range" })

-- Move current line up or down
map('n', '<A-j>', ':m .+1<CR>==', vim.tbl_extend('force', opts, { desc = "Move line down" }))
map('n', '<A-k>', ':m .-2<CR>==', vim.tbl_extend('force', opts, { desc = "Move line up" }))
map('i', '<A-j>', '<Esc>:m .+1<CR>==gi', vim.tbl_extend('force', opts, { desc = "Move line down" }))
map('i', '<A-k>', '<Esc>:m .-2<CR>==gi', vim.tbl_extend('force', opts, { desc = "Move line up" }))
map('v', '<A-j>', ":m '>+1<CR>gv=gv", vim.tbl_extend('force', opts, { desc = "Move selection down" }))
map('v', '<A-k>', ":m '<-2<CR>gv=gv", vim.tbl_extend('force', opts, { desc = "Move selection up" }))
map('n', '<A-Down>', ':m .+1<CR>==', vim.tbl_extend('force', opts, { desc = "Move line down" }))
map('n', '<A-Up>',   ':m .-2<CR>==', vim.tbl_extend('force', opts, { desc = "Move line up" }))
map('i', '<A-Down>', '<Esc>:m .+1<CR>==gi', vim.tbl_extend('force', opts, { desc = "Move line down" }))
map('i', '<A-Up>',   '<Esc>:m .-2<CR>==gi', vim.tbl_extend('force', opts, { desc = "Move line up" }))
map('v', '<A-Down>', ":m '>+1<CR>gv=gv", vim.tbl_extend('force', opts, { desc = "Move selection down" }))
map('v', '<A-Up>',   ":m '<-2<CR>gv=gv", vim.tbl_extend('force', opts, { desc = "Move selection up" }))
