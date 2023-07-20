-- Key mapping
local map = require("utils").map
local plugins = require("plugins")

local g = vim.g -- global variables
local o = vim.o -- get or set options
local go = vim.go -- get or set global options
local wo = vim.wo -- window-scoped options
local bo = vim.bo -- buffer-scoped options
vim.opt.foldmethod = "marker"
vim.opt.wrap = true
vim.opt.linebreak = true -- Stop words from being broken on wrap
vim.opt.showmode = false -- Don't display current mode

vim.o.shada = nil -- turn off the useless saving of every piece of state

o.tabstop = 4
o.softtabstop = 0
o.shiftwidth = 4
o.smarttab = true
o.expandtab = true
o.smartindent = true
vim.opt.clipboard = "unnamedplus" -- normal copy and paste via X clipboard

g.mapleader=' '
g.maplocalleader = ' '

wo.nu = true -- line numbers
vim.cmd(":hi LineNr guibg=#000000 guifg=#ffffff")
map("i", "jk", "<Esc>", { silent = true })
map("i", "kj", "<Esc>", { silent = true })
map("i", "<C-s>", "<C-o>:Update<CR>", { silent = true })
map("v", "<C-c>", "\"+y", { silent = true })
map("n", "<C-v>", "\"*p", { silent = true })
map("n", "<C-j>", "<C-f>", { silent = true })
map("n", "<C-k>", "<C-b>", { silent = true })
map("n", "<C-n>", ":bn<CR>", { silent = true }) -- next buffer in order
map("n", "<C-p>", ":bp<CR>", { silent = true }) -- previous buffer in order
map("n", "<C-3>", ":b#<CR>", { silent = true }) -- previous buffer you were in
map("n", "<M-e>", ":Explore<CR>", { silent = true })

--plugins.require("leap").add_default_mappings()
