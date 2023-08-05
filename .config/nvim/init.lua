--{{{ Utils
function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end
local g = vim.g -- global variables
local o = vim.o -- get or set options
local go = vim.go -- get or set global options
local wo = vim.wo -- window-scoped options
local bo = vim.bo -- buffer-scoped options
--}}}

--{{{Settings
vim.opt.foldmethod = "marker"
vim.opt.wrap = true
vim.opt.linebreak = true -- Stop words from being broken on wrap
vim.opt.showmode = false -- Don't display current mode

vim.o.shada = nil -- turn off the useless saving of every piece of state

-- Tab stuff
o.tabstop = 4
o.softtabstop = 0
o.shiftwidth = 4
o.smarttab = true
o.expandtab = true
o.smartindent = true
vim.opt.clipboard = "unnamedplus" -- normal copy and paste via X clipboard

g.mapleader=','
g.maplocalleader = ','

wo.nu = true -- line numbers
wo.rnu = true -- relative line numbers
vim.cmd(":hi LineNr guibg=#000000 guifg=#ffffff") -- gutter colors ?
vim.api.nvim_set_hl(0, "NormalFloat", {link = "Normal"}) -- Fix hideous pink menus
vim.o.runtimepath = "~/.config/nvim,~/.local/share/nvim/site,~/.local/share/nvim/site/pack/*/start/*,/usr/share/nvim/site,/usr/share/nvim/runtime"
--}}}

--{{{ Core keybindings
map("i", "jk", "<Esc>", { silent = true })
map("i", "kj", "<Esc>", { silent = true })
map("i", "<C-s>", "<C-o>:Update<CR>", { silent = true })
map("v", "<C-c>", "\"+y", { silent = true })
map("n", "<C-v>", "\"*p", { silent = true })
map("n", "<C-j>", "<C-f>", { silent = true })
map("n", "<C-k>", "<C-b>", { silent = true })
map("n", "<C-n>", ":bn<CR>", { silent = true }) -- next buffer in order
map("n", "<C-p>", ":bp<CR>", { silent = true }) -- preceding buffer in order
map("n", "<C-3>", ":b#<CR>", { silent = true }) -- previous visited buffer
map("n", "<M-e>", ":Explore<CR>", { silent = true })
--}}}

--{{{ Packages

require "paq" {
    "savq/paq-nvim", -- Let Paq manage itself
    "nvim-lua/plenary.nvim",
    { "ggandor/leap.nvim" },
    "nvim-telescope/telescope.nvim"
}
require("leap").add_default_mappings()
local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", telescope.find_files, {silent = true})
vim.keymap.set("n", "<leader>fg", telescope.live_grep, {silent = true})
vim.keymap.set("n", "<leader>fb", telescope.buffers, {silent = true})
vim.keymap.set("n", "<leader>fh", telescope.help_tags, {silent = true})
--}}}
--{{{ My custom functions
vim.keymap.set("n", "o",
    function()
        vim.fn.append(vim.fn.line("."), "")
    end,
    { silent = true })
vim.keymap.set("n", "O",
    function()
        vim.fn.append(vim.fn.line(".") - 1, "")
    end,
    { silent = true })

--}}}

