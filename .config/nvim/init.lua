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
o.ignorecase = true
vim.opt.clipboard = "unnamedplus" -- normal copy and paste via X clipboard

g.mapleader=','
g.maplocalleader = ','

wo.nu = true -- line numbers
wo.rnu = true -- relative line numbers
vim.cmd(":hi LineNr guibg=#000000 guifg=#ffffff") -- gutter colors ?
vim.api.nvim_set_hl(0, "NormalFloat", { link = "Normal" }) -- Fix hideous pink menus
vim.o.runtimepath = "~/.config/nvim,~/.local/share/nvim/site,~/.local/share/nvim/site/pack/*/start/*,/usr/share/nvim/site,/usr/share/nvim/runtime"

vim.api.nvim_set_hl(0, "Search", { ctermbg = 8 })
vim.api.nvim_set_hl(0, "Statement", { ctermfg = 11 })
vim.api.nvim_set_hl(0, "String", { ctermfg = "Green" })
vim.api.nvim_set_hl(0, "Comment", { ctermfg = "Green" })
vim.api.nvim_set_hl(0, "Folded", { ctermbg = "DarkGray" })

--}}}
--{{{ Core keybindings
map("i", "<C-;>", "<Esc>")
map("i", "<C-w>", "<Esc>:wa<CR>") -- save all and enter normal mode
map("n", "<C-w>", "<Esc>:wa<CR>") -- save all and enter normal mode
map("v", "<C-c>", "\"+y")
map("n", "<C-v>", "\"*p")
map("n", "<C-/>", ":set hlsearch!<CR>") -- toggle coloring of searches
map("n", "<C-8>", "*")
map("n", "<space>", "i<space><esc>") -- space in normal mode
map("n", "<C-n>", ":bn<CR>") -- next buffer
map("n", "<C-p>", ":bp<CR>") -- preceding buffer
map("n", "<C-3>", ":b#<CR>") -- previous visited buffer
map("n", "<M-e>", ":Explore<CR>") -- open file navigator
vim.keymap.set("n", "<leader>r", 'viw"0p') -- replace word from clipboard
vim.keymap.set("v", "<leader>j", ":m '<-2<CR>gv") -- move line down
vim.keymap.set("v", "<leader>k", ":m '>+1<CR>gv") -- move line up
vim.keymap.set("n", "<leader>j", ":m-2<CR>")
vim.keymap.set("n", "<leader>k", ":m+<CR>")
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
--{{{ Utils

function countIndentation(currentLine)
    local numSpaces = 0
    for i = 1, #currentLine do
        local char = currentLine:sub(i, i)
        if char == ' ' then
            numSpaces = numSpaces + 1
        else
            return numSpaces
        end
    end
    return numSpaces
end


local function isLineEmpty(line)
    local stripped = string.gsub(line, "%s+", "")
    return #stripped == 0
end


local function getLimitsOfCurrentBlock()
    -- returns start and end line of the current block of lines (delimited by empty lines)

    local currLine = vim.api.nvim_win_get_cursor(0)[1] -- current line number
    local i = currLine
    while i > 0 do
        local currLine = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        if not currLine or isLineEmpty(currLine) then
            break
        end
        i = i - 1
    end
    local lineStart = i + 1

    local countLines = vim.api.nvim_buf_line_count(0)
    i = currLine
    while i <= countLines do
        local currLine = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        if not currLine or isLineEmpty(currLine) then
            break
        end
        i = i + 1
    end
    return {start = lineStart, endd = i}
end


local function toNormalMode()
    local ky = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
    vim.api.nvim_feedkeys(ky, 'n', false)
end


local function getLineContent(lineNum)
    return vim.api.nvim_buf_get_lines(0, lineNum - 1, lineNum, false)[1]
end


local function getCurrLineContent()
    local lineNum = vim.api.nvim_win_get_cursor(0)[1]
    return getLineContent(lineNum)
end


local function getCurrentIndentation()
    -- returns string with the same # of spaces as current line has at start
    local currentLine = getCurrLineContent()
    local numSpaces = countIndentation(currentLine)
    return string.sub(currentLine, 1, numSpaces)
end


local function insertBlock(delimiter, closingDelimiter)
    -- inserts a block, with indentation and closing delimiter
    local spaces = getCurrentIndentation()
    local lineNum = vim.api.nvim_win_get_cursor(0)[1]
    local currentLine = vim.api.nvim_buf_get_lines(0, lineNum - 1, lineNum, false)[1]
    vim.api.nvim_buf_set_lines(0, lineNum - 1, lineNum, false, { currentLine .. " " .. delimiter})
    vim.api.nvim_buf_set_lines(0, lineNum, lineNum, false, {spaces .. closingDelimiter})
    vim.api.nvim_buf_set_lines(0, lineNum, lineNum, false, {spaces .. "    "})
    vim.api.nvim_win_set_cursor(0, { lineNum + 1, #spaces + 4 })
end

--}}}
--{{{ Commas
local function appendCommas()
    local limits = getLimitsOfCurrentBlock()

    i = limits.start
    print(limits.endd)
    while i < limits.endd do
        local existingLine = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        vim.api.nvim_buf_set_lines(0, i - 1, i, false, {existingLine .. ","})
        i = i + 1
    end
end


vim.keymap.set("n", "<C-,>",
    appendCommas,
    sil
)
--}}}
--{{{ o
vim.keymap.set("n", "o",
    function()
        local lineNum = vim.api.nvim_win_get_cursor(0)[1] -- current line
        local currentLine = vim.api.nvim_buf_get_lines(0, lineNum - 1, lineNum, false)[1]
        local numSpaces = countIndentation(currentLine)
        vim.fn.append(vim.fn.line("."), string.sub(currentLine, 1, numSpaces))
        vim.cmd("norm! j$")
    end,
    sil
)


vim.keymap.set("n", "O",
    function()
        local lineNum = vim.api.nvim_win_get_cursor(0)[1] -- current line
        local currentLine = vim.api.nvim_buf_get_lines(0, lineNum - 1, lineNum, false)[1]
        local numSpaces = countIndentation(currentLine)
        vim.fn.append(vim.fn.line(".") - 1, string.sub(currentLine, 1, numSpaces))
        vim.cmd("norm! k")
    end,
    sil
)
--}}}
--{{{ Comments

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
    sil
)


local function commentBlock(comm)
    local limits = getLimitsOfCurrentBlock()
    local i = limits.start
    while i < limits.endd do
        local existingLine = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        vim.api.nvim_buf_set_lines(0, i - 1, i, false, {comm .. existingLine})
        i = i + 1
    end
end


local function uncommentBlock(comm)
    -- implying the comment length is 3

    local currLine = vim.api.nvim_win_get_cursor(0)[1] -- current line
    local i = currLine
    while i > 0 do
        local currLine = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        if not currLine or currLine:sub(0, 3) ~= comm then
            break
        end
        i = i - 1
    end
    local lineStart = i + 1

    local countLines = vim.api.nvim_buf_line_count(0)
    i = currLine
    while i <= countLines do
        local currLine = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        print(currLine:sub(0, 3))
        if not currLine or currLine:sub(0, 3) ~= comm then
            break
        end
        i = i + 1
    end
    local lineEnd = i
    i = lineStart
    while i < lineEnd do
        local existingLine = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        vim.api.nvim_buf_set_lines(0, i - 1, i, false, {existingLine:sub(4)})
        i = i + 1
    end
end


vim.keymap.set("n", "<C-e>",
    function()
        local comm = "//~"

        local lineNum = vim.api.nvim_win_get_cursor(0)[1] -- current line
        local currentLine = vim.api.nvim_buf_get_lines(0, lineNum - 1, lineNum, false)[1]
        local alreadyCommented = currentLine:sub(0, 3) == comm

        if alreadyCommented then
            uncommentBlock(comm)
        else
            commentBlock(comm)
        end
    end,
    sil)
    
--}}}
--{{{ "Windows" (What Vim calls views)

local function moveOrCreateWindow(key)
    -- Move to a window (one of hjkl) or create a split if none exist in the direction
    -- @arg key: One of h, j, k, l, a direction to move or create a split
    local currWin = vim.fn.winnr()
    vim.cmd("wincmd " .. key)        -- attempt to move

    if (currWin == vim.fn.winnr()) then -- didn't move, so create a split
        if key == "h" or key == "l" then
            vim.cmd("wincmd v")
        else
            vim.cmd("wincmd s")
        end

        vim.cmd("wincmd " .. key)
    end
end

--}}}

vim.keymap.set("i", "<C-]>", function() insertBlock("{", "}") end, sil)
vim.keymap.set("i", "<C-9>", function() insertBlock("(", ")") end, sil)
vim.keymap.set("n", "<M-h>", function() moveOrCreateWindow("h") end, sil)
vim.keymap.set("n", "<M-j>", function() moveOrCreateWindow("j") end, sil)
vim.keymap.set("n", "<M-k>", function() moveOrCreateWindow("k") end, sil)
vim.keymap.set("n", "<M-l>", function() moveOrCreateWindow("l") end, sil)

--{{{ The anything text object

---@return boolean
local function isVisualMode()
	local modeWithV = vim.fn.mode():find("v")
	return modeWithV ~= nil
end

function runInNormal(cmdStr)
    ---runs a command string in normal mode
    vim.cmd.normal { cmdStr, bang = true }
end

local function setSelection(startPos, endPos)
    ---@alias pos {integer, integer}
    ---sets the selection for the textobj (characterwise)
    ---@param startPos pos
    ---@param endPos pos
	vim.api.nvim_win_set_cursor(0, startPos)
	if isVisualMode() then
	    runInNormal("o")
	else
		runInNormal("v")
	end
	vim.api.nvim_win_set_cursor(0, endPos)
end


local function anyTextObjectFindLeftEnd(pos)
    ---Goes rightward and properly handles opening+closing (), [] and {}, as well as `` and ""
    ---Stops at the first space/newline outside of those delimiters. Is multiline
    
    local levelPar = 0 -- ()
    local levelBra = 0 -- []
    local levelCurl = 0 -- {}
    local inQuo = false -- "
    local inBack = false -- `

    local countLines = vim.api.nvim_buf_line_count(0)
    local i = pos[1]
    local startCol = pos[2]
    while i >= 1 do
        local currentLine = getLineContent(i)
        for j = startCol, 1, -1 do
            local char = currentLine:sub(j, j)
            if inQuo == true then
                if char == "\"" and j - 1 >= 1
                        and currentLine:sub(j - 1, j - 1) == "\\" then
                    j = j - 1
                elseif char == "\"" then
                    inQuo = false
                end
            elseif inBack == true then
                if char == "`" then
                    inBack = false 
                end
            else
                if char == "\"" then
                    inQuo = true 
                elseif char == "`" then
                    inBack = true
                elseif char == "(" then
                    if levelPar == 0 then 
                        return {i, j}
                    end
                    levelPar = levelPar - 1
                elseif char == ")" then
                    levelPar = levelPar + 1
                elseif char == "{" then
                    if levelCurl == 0 then 
                        return {i, j}
                    end
                    levelCurl = levelCurl - 1
                elseif char == "}" then
                    levelCurl = levelCurl + 1
                elseif char == "[" then
                    if levelBra == 0 then 
                        return {i, j}
                    end
                    levelBra = levelBra - 1
                elseif char == "]" then
                    levelBra = levelBra + 1
                elseif char == " " then
                    if levelPar == 0 and levelBra == 0 and levelCurl == 0 then
                        return {i, j} 
                    end
                end
            end
        end
        startCol = #currentLine
    end 
    return {1, 1} 
end 

local function anyTextObjectFindRightEnd(pos)
    ---Goes rightward and properly handles opening+closing (), [] and {}, as well as `` and ""
    ---Stops at the first space/newline outside of those delimiters. Is multiline
    
    local levelPar = 0 -- ()
    local levelBra = 0 -- []
    local levelCurl = 0 -- {}
    local inQuo = false -- "
    local inBack = false -- `

    local countLines = vim.api.nvim_buf_line_count(0)
    local i = pos[1]
    local startCol = pos[2]
    local currentLine 
    while i <= countLines do
        currentLine = getLineContent(i)
        for j = startCol, #currentLine do
            local char = currentLine:sub(j, j)
            if inQuo == true then
                if char == "\\" and j + 1 <= #currentLine
                        and currentLine:sub(j + 1, j + 1) == "\"" then
                    j = j + 1
                elseif char == "\"" then
                    inQuo = false
                end
            elseif inBack == true then
                if char == "`" then
                    inBack = false 
                end
            else
                if char == "\"" then
                    inQuo = true 
                elseif char == "`" then
                    inBack = true
                elseif char == "(" then
                    levelPar = levelPar + 1
                elseif char == ")" then
                    if levelPar == 0 then 
                        return {i, j - 2}
                    end
                    levelPar = levelPar - 1
                elseif char == "{" then
                    levelCurl = levelCurl + 1
                elseif char == "}" then
                    if levelCurl == 0 then 
                        return {i, j - 2}
                    end
                    levelCurl = levelCurl - 1
                elseif char == "[" then
                    levelBra = levelBra + 1
                elseif char == "]" then
                    if levelBra == 0 then 
                        return {i, j - 2}
                    end
                    levelBra = levelBra - 1
                elseif char == "/" and j + 1 <= currentLine
                        and currentLine:sum(j + 1, j + 1) == "/" then
                    break
                elseif char == " " then
                    if levelPar == 0 and levelBra == 0 and levelCurl == 0 then
                        return {i, j - 2} 
                    end
                end
            end
        end
        startCol = 1
    end 
    return {countLines, #currentLine}

--//~    for i = j, #currentLine do
--//~        local char = currentLine:sub(i, i)
--//~        if char == ' ' then
--//~            endInd = i - 2 -- don't ask why -2...
--//~            break
--//~        end
--//~    end
end

local function anyTextObject()
    local currentLine = getCurrLineContent()
    local lineN = vim.api.nvim_win_get_cursor(0)[1]
    local j = vim.api.nvim_win_get_cursor(0)[2] + 1 -- +1 because the Neovim API is stupid
    
    local startPos = anyTextObjectFindLeftEnd({lineN, j})
    local endPos = anyTextObjectFindRightEnd({lineN, j})
    print("row = ", lineN, " col = ", startInd, "to  row = ", endPos[1], " col = ", endPos[2]) 
    setSelection(startPos, endPos)
end

vim.keymap.set("o", "iu", function() anyTextObject() end, sil)

--}}}
--{{{ Snippets
--~ vim.v.this_session - the filename of the session

--~ nvim_create_buf()
--~ nvim_open_win()
--~ nvim_open_term()
--~ nvim_chan_send()

--~local job = vim.fn.jobstart(
--~    'echo hello',
--~    {
--~        cwd = '/path/to/working/dir',
--~        on_exit = someFunction,
--~        on_stdout = someOtherFunction,
--~        on_stderr = someThirdFunction
--~    }
--~)
--}}}
