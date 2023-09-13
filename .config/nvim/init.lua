--{{{ Utils
function map(mode, lhs, rhs)
    local options = { noremap = true }
    options = vim.tbl_extend("force", options, {silent = true})
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
map("i", "<C-;>", "<Esc>")
map("i", "<C-w>", "<Esc>:wa<CR>") -- save all and enter normal mode
map("n", "<C-w>", "<Esc>:wa<CR>") -- save all and enter normal mode
map("v", "<C-c>", "\"+y")
map("n", "<C-v>", "\"*p")
map("n", "<C-8>", "*")
map("n", "w", "W")
map("n", "b", "B")
map("n", "<space>", "i<space><esc>") -- space in normal mode
map("n", "<C-n>", ":bn<CR>") -- next buffer in order
map("n", "<C-p>", ":bp<CR>") -- preceding buffer in order
map("n", "<C-3>", ":b#<CR>") -- previous visited buffer
map("n", "<M-e>", ":Explore<CR>") -- open file navigator
vim.keymap.set("n", "<leader>r", 'viw"0p') -- replace word from clipboard
map("n", "L", "21l")
map("n", "H", "21h")
map("n", "<M-c>", ":q<CR>")
--}}}
--{{{ Packages

require "paq" {
    "savq/paq-nvim", -- Let Paq manage itself
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "kylechui/nvim-surround"
}
local telescope = require("telescope.builtin")
local sil = { silent = true }
vim.keymap.set("n", "<leader>ff", telescope.find_files, sil)
vim.keymap.set("n", "<leader>fg", telescope.live_grep, sil)
vim.keymap.set("n", "<leader>fb", telescope.buffers, sil)
vim.keymap.set("n", "<leader>fh", telescope.help_tags, sil)
--}}}
--{{{ My custom functions

function countIndentation(currentLine)
    local numSpaces = 0
    for i = 1, #currentLine do
        local char = currentLine:sub(i, i)
        if char == ' ' then
            numSpaces = numSpaces + 1
        end
    end
    return numSpaces
end


vim.keymap.set("n", "o",
    function()
        local lineNum = vim.api.nvim_win_get_cursor(0)[1] -- current line
        local currentLine = vim.api.nvim_buf_get_lines(0, lineNum - 1, lineNum, false)[1]
        local numSpaces = countIndentation(currentLine)
        vim.fn.append(vim.fn.line("."), string.sub(currentLine, 1, numSpaces))
        vim.cmd("norm! j$")
    end,
    sil)

vim.keymap.set("n", "O",
    function()
        local lineNum = vim.api.nvim_win_get_cursor(0)[1] -- current line
        local currentLine = vim.api.nvim_buf_get_lines(0, lineNum - 1, lineNum, false)[1]
        local numSpaces = countIndentation(currentLine)
        vim.fn.append(vim.fn.line(".") - 1, string.sub(currentLine, 1, numSpaces))
        vim.cmd("norm! k")
    end,
    sil )


function toNormalMode()
    local ky = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
    vim.api.nvim_feedkeys(ky, 'n', false)
end

vim.keymap.set("v", "<C-e>",
    function()
        local line1 = vim.fn.line('v') -- current visual line
        local line2 = vim.api.nvim_win_get_cursor(0)[1] -- current line
        local lineStart
        local lineEnd
        if (line1 < line2) then
            lineStart = line1
            lineEnd = line2
        else
            lineStart = line2
            lineEnd = line1
        end
        local i = lineStart
        while (i <= lineEnd) do
            local existingLine = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
            vim.api.nvim_buf_set_lines(0, i - 1, i, false, {"//~" .. existingLine})
            i = i + 1
        end
        toNormalMode()
    end,
    sil)

vim.keymap.set("n", "<C-e>",
    function()
        local rw, cl = unpack(vim.api.nvim_win_get_cursor(0))
        rw = rw - 1
        local countLines = vim.api.nvim_buf_line_count(0)
        while (rw < countLines) do
            local linePref = vim.api.nvim_buf_get_text(0, rw, 0, rw, 3, {})[1]
            if (linePref ~= "//~" and linePref ~= "--~") then
                return
            end
            vim.api.nvim_buf_set_text(0, rw, 0, rw, 3, {}) -- deleting the chars
            rw = rw + 1
        end
    end,
    sil)

-- Move to a window (one of hjkl) or create a split if a window does not exist in the direction
-- Example keybinding: vim.keymap("n", "<C-h>", function() moveOrCreateWin("h") end)
-- @arg key: One of h, j, k, l, a direction to move or create a split
local function moveOrCreateWindow(key)
    local fn = vim.fn
    local curr_win = fn.winnr()
    vim.cmd("wincmd " .. key)        -- attempt to move

    if (curr_win == fn.winnr()) then -- didn't move, so create a split
        if key == "h" or key == "l" then
            vim.cmd("wincmd v")
        else
            vim.cmd("wincmd s")
        end

        vim.cmd("wincmd " .. key)
    end
end
vim.keymap.set("n", "<M-h>", function() moveOrCreateWindow("h") end, sil)
vim.keymap.set("n", "<M-j>", function() moveOrCreateWindow("j") end, sil)
vim.keymap.set("n", "<M-k>", function() moveOrCreateWindow("k") end, sil)
vim.keymap.set("n", "<M-l>", function() moveOrCreateWindow("l") end, sil)
