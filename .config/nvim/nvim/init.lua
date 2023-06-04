-- Key mapping
local map = require("utils").map

local g = vim.g -- global variables
local o = vim.o -- get or set options
local go = vim.go -- get or set global options
local wo = vim.wo -- window-scoped options
local bo = vim.bo -- buffer-scoped options
vim.opt.foldmethod = "marker"

o.tabstop = 4
o.softtabstop = 0
o.shiftwidth = 4
o.smarttab = true
o.expandtab = true
o.smartindent = true
vim.opt.clipboard = "unnamedplus"

g.mapleader=' '
g.maplocalleader = ' '

wo.nu = true -- line numbers
vim.cmd(":hi LineNr guibg=#000000 guifg=#ffffff")
map("i", "<C-q>", "<Esc>", { silent = true })
map("i", "<C-s>", "<C-o>:Update<CR>", { silent = true })
map("v", "<C-c>", "\"+y", { silent = true })
map("n", "<C-v>", "\"*p", { silent = true })
map("n", "<C-j>", "<C-f>", { silent = true })
map("n", "<C-k>", "<C-b>", { silent = true })
map("n", "<C-n>", ":bn<CR>", { silent = true }) -- next buffer in order
map("n", "<C-p>", ":bp<CR>", { silent = true }) -- previous buffer in order
map("n", "<C-3>", ":b#<CR>", { silent = true }) -- previous buffer you were in

