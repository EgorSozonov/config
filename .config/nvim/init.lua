--{{{ Utils

--vim.treesitter.language.add('lua', { path = "/usr/lib/libtree-sitter-lua.so" })
--vim.treesitter.language.add('vimdoc', { path = "/usr/lib/libtree-sitter-vimdoc.so" })

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
--{{{ Settings

vim.o.runtimepath = "~/.local/share/nvim/site,~/.config/nvim"
vim.opt.foldmethod = "marker"
vim.opt.wrap = true
vim.opt.linebreak = true -- Stop words from being broken on wrap
vim.opt.showmode = false -- Don't display current mode
vim.g.loaded_matchparen = true
vim.g.loaded_matchparen = true
vim.g.loaded_matchbracket = true 

vim.o.shada = nil -- turn off the useless saving of every piece of state

-- Tab stuff
o.tabstop = 3
o.softtabstop = 0
o.shiftwidth = 3
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

-- Syntax coloring: run ":syntax" to see which ones are active, edit syntax/..vim to change them
vim.api.nvim_set_hl(0, "Search", { ctermbg = 8 })
vim.api.nvim_set_hl(0, "String", { fg = "#00FF00" })
vim.api.nvim_set_hl(0, "cStatement", { fg = "Yellow" })
vim.api.nvim_set_hl(0, "Comment", { fg = "#00FF00" })
vim.api.nvim_set_hl(0, "Folded", { bg = "#303030" })

--}}}
--{{{ Core keybindings


map("i", "<C-;>", "<Esc>")
map("i", "<Tab>", "<Esc>")
map("i", "<C-space>", "<space><space><space>") -- indentation insert
map("i", "<C-w>", "<Esc>:wa<CR>") -- save all and enter normal mode
map("n", "<C-w>", "<Esc>:wa<CR>") -- save all and enter normal mode
map("v", "<C-c>", "\"+y")
map("n", "<C-v>", "\"*p")
map("i", "<C-v>", "\"*p")
map("n", "<C-/>", ":set hlsearch!<CR>") -- toggle coloring of searches
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
map("n", "H", "21h")
map("n", "L", "21l")
map("n", "<C-h>", "21h")
map("n", "<C-l>", "21l")
map("n", "<M-c>", ":q<CR>")

map("n", "x", '"_x') -- don't clobber the register

--}}}
--{{{ Packages

require "paq" {
    "savq/paq-nvim", -- Let Paq manage itself
--    "nvim-lua/plenary.nvim",
--    "nvim-telescope/telescope.nvim",
--    "nvim-telescope/telescope-file-browser.nvim",
--    "L3MON4D3/LuaSnip",
--    "kylechui/nvim-surround"
}
local sil = { silent = true }
--	local ls = require("luasnip")
--	ls.snippets = require("snippets")
--	vim.keymap.set({"i"}, "<C-k>", function() ls.expand() end, sil)
--	vim.keymap.set({"i", "s"}, "<C-L>", function() ls.jump(1) end, sil)
--	vim.keymap.set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, sil)
--	vim.keymap.set({"i", "s"}, "<C-E>",
--	    function()
--	        if ls.choice_active() then
--	            ls.change_choice(1)
--	        end
--	    end,
--	    sil)

--}}}
--{{{ Telescope

local telescope = require("telescope")
local telescopeBuiltin = require("telescope.builtin")
telescope.setup {
   extensions = {
      file_browser = {
        theme = "ivy",
        -- disables netrw and use telescope-file-browser in its place
        hijack_netrw = true,
        previewer = false,
        mappings = {
           ["i"] = {
             -- your custom insert mode mappings
           },
           ["n"] = {
             -- your custom normal mode mappings
           },
        },
     },
  },
}
telescope.load_extension("file_browser")
vim.keymap.set("n", "<leader>ff", telescopeBuiltin.find_files, sil)
vim.keymap.set("n", "<leader>fg", telescopeBuiltin.live_grep, sil)
vim.keymap.set("n", "<leader>fb", telescopeBuiltin.buffers, sil)
vim.keymap.set("n", "<leader>fh", telescopeBuiltin.help_tags, sil)
vim.keymap.set("n", "<leader>e", function()
	telescope.extensions.file_browser.file_browser()
end)

--}}}
--{{{ My custom functions
--{{{ Utils

local function countIndentation(currentLine)
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
    vim.api.nvim_buf_set_lines(0, lineNum, lineNum, false, {spaces .. "   "})
    vim.api.nvim_win_set_cursor(0, { lineNum + 1, #spaces + 4 })
end

local function setLine(ind, content)
    vim.api.nvim_buf_set_lines(0, ind - 1, ind, false, {content})
end 


--}}}
--{{{ Commas

local function formatCommas()
-- Add commas to every line (if it doesn't end in a comma yet) and arranges them
-- in groups so that lines are no more than 100 symbols
    local limits = getLimitsOfCurrentBlock()

    local i = limits.start
    local j = i
    local currLen = 0
    local lineBuilder = ""
    while i < limits.endd do
       local existingLine = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
       existingLine = string.gsub(existingLine, "%s+", "")
       if existingLine[-1] ~= "," then
          existingLine = existingLine .. ","
       end
       print(existingLine)
       currLen = currLen + existingLine:len()
       lineBuilder = lineBuilder .. existingLine
       if currLen >= 100 then
          vim.api.nvim_buf_set_lines(0, j - 1, j, false, {lineBuilder})
          j = j + 1
          currLen = 0
          lineBuilder = ""
       end   
       i = i + 1
    end
    if lineBuilder:len() > 0 then
       vim.api.nvim_buf_set_lines(0, j - 1, j, false, {lineBuilder})
       j = j + 1
   end 
   while j < limits.endd do
      vim.api.nvim_buf_set_lines(0, j - 1, j, false, {""})
      j = j + 1
   end
end

local function appendCommas()
    local limits = getLimitsOfCurrentBlock()

    i = limits.start
    while i < limits.endd do
        local existingLine = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        vim.api.nvim_buf_set_lines(0, i - 1, i, false, {existingLine .. ","})
        i = i + 1
    end
end


vim.keymap.set("n", "<C-,>", formatCommas, sil)

--}}}
--{{{ o improvement

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
--{{{ Views (what Vim calls "windows")

local function safeGetTabVar(tabpage, varName)
   s, v = pcall(function() return vim.api.nvim_tab_get_var(tabpage, varName) end)
   if s then return v else return nil end
end

local function safeGetVar(window, varName)
   s, v = pcall(function() return vim.api.nvim_win_get_var(window, varName) end)
   if s then return v else return nil end
end

local function openTerminalAndCleanUpWindows()
   -- Opens up a window for the terminal if there isn't one, and 
   -- leaves only two windows (the current and the terminal). All other windows are closed
   
   local currentState = safeGetTabVar(0, "termState")
   if currentState == "code" then
      local codeWin = vim.api.nvim_get_current_win()
      local termBuf = vim.api.nvim_tabpage_get_var(0, "termBuf")
      local termWin = vim.api.nvim_open_win(termBuf, false, {split = 'left', win = 0})
      
      vim.api.nvim_tabpage_set_win(0, termWin)
      vim.api.nvim_win_hide(codeWin)
      vim.api.set_tabpage_var(0, "termState", "code")
      sendSmth()
   elseif currentState == "terminal" then
      local codeBuf = vim.api.nvim_tabpage_get_var(0, "codeBuf")
      local termWin = vim.api.nvim_get_current_win()
      local codeWin = vim.api.nvim_open_win(codeBuf, false, {split = 'left', win = 0})
      
      vim.api.nvim_tabpage_set_win(0, codeWin)
      vim.api.nvim_win_hide(termWin)
      vim.api.set_tabpage_var(0, "termState", "terminal")
   else
      local codeWin = vim.api.nvim_get_current_win()
      
      local termBuf = vim.api.nvim_create_buf(false, false)
      local termWin = vim.api.nvim_open_win(termBuf, false, {split = 'left', win = 0})
      vim.api.nvim_win_set_buf(termWin, termBuf)
      local chanId = vim.api.nvim_open_term(termBuf, {})
      
      vim.api.nvim_tabpage_set_var(0, "termState", "terminal")
      vim.api.nvim_tabpage_set_var(0, "termChanId", chanId)
      vim.api.nvim_tabpage_set_var(0, "termBuf", termBuf)
      vim.api.nvim_tabpage_set_var(0, "codeBuf", vim.api.nvim_win_get_buf(codeWin))
      vim.api.nvim_tabpage_set_win(0, termWin)
   
      vim.api.nvim_win_hide(codeWin)
      vim.api.set_tabpage_var(0, "termState", "terminal")
      sendSmth()
   end
end


--~local function openTerminalAndCleanUpWindows()
--~   -- Opens up a window for the terminal if there isn't one, and 
--~   -- leaves only two windows (the current and the terminal). All other windows are closed
--~   
--~   local ou = 1
--~   
--~   local mainWin = vim.api.nvim_get_current_win()
--~   setLine(ou, tostring(mainWin))
--~   ou = ou + 1
--~   
--~   
--~   local windowType = safeGetVar(mainWin, "windowType")
--~   if windowType ~= "mainWindow" then
--~      setLine(ou, "setting var")
--~      ou = ou + 1
--~      vim.api.nvim_win_set_var(mainWin, "windowType", "mainWindow")
--~   end
--~   
--~   
--~   -- close extra windows
--~   local windows = vim.api.nvim_tabpage_list_wins(0)
--~   local metTerminal = false
--~   for _, window in ipairs(windows) do
--~   
--~      setLine(ou, "encountered window  " .. tostring(window))
--~      ou = ou + 1
--~      
--~      if window ~= mainWin then
--~      
--~         windowType = vim.api.nvim_win_get_var(window, "windowType")
--~         if windowType == "termWindow" then
--~            if metTerminal then
--~               vim.api.nvim_win_hide(window)
--~            else 
--~               metTerminal = true
--~            end
--~         else
--~            vim.api.nvim_win_close(window, true)
--~         end 
--~      end
--~   end
--~   if not metTerminal then
--~      local termBuf = vim.api.nvim_create_buf(false, false)
--~      local termWin = vim.api.nvim_open_win(termBuf, false, {split = 'left', win = 0})
--~      vim.api.nvim_win_set_buf(termWin, termBuf)
--~      local chanId = vim.api.nvim_open_term(termBuf, {})
--~      vim.api.nvim_win_set_var(termWin, "windowType", "termWindow")
--~      vim.api.nvim_win_set_var(mainWin, "termChanId", chanId)
--~   end
--~end

local function moveWindow(key)
   -- Move to a window (one of hjkl) or create a split if none exist in the direction
   -- @arg key: One of h, j, k, l. A direction to move or create a split
   vim.cmd("wincmd " .. key) -- attempt to move
end

local function moveOrCreateWindow(key)
   -- Move to a window (one of hjkl) or create a split if none exist in the direction
   -- @arg key: One of h, j, k, l. A direction to move or create a split
   local currWin = vim.fn.winnr()
   vim.cmd("wincmd " .. key) -- attempt to move
   if (currWin == vim.fn.winnr()) then
      if key == "h" or key == "l" then
         vim.cmd("wincmd v")
      else
         vim.cmd("wincmd s")
      end

      vim.cmd("wincmd " .. key)
   end
end

local function newTerminal()
   local currWin = vim.api.nvim_get_current_win()
   
   vim.cmd("wincmd v")
   vim.api.nvim_tabpage_set_win(0, currWin)

   local termWin
   local windows = vim.api.nvim_tabpage_list_wins(0)
   for _, window in ipairs(windows) do
      if window ~= currWin then
         termWin = window
         break
      end
   end
   if not termWin then
      return
   end
   local termBuf = vim.api.nvim_create_buf(false, false)
   vim.api.nvim_win_set_buf(termWin, termBuf)
   local chanId = vim.api.nvim_open_term(termBuf, {})
   vim.api.nvim_win_set_var(currWin, "termChanId", chanId)
end

local function sendSmth()
   local currWin = vim.api.nvim_get_current_win()
   local chanId = vim.api.nvim_tabpage_get_var(currWin, "termChanId")
   
   vim.fn.jobstart('ls -al', {
        cwd = '/home/onr/proj',
        on_exit = function(j, d, e)  end,
        on_stdout = 
           function(j, d, e) 
              for i, line in ipairs(d) do
                 vim.api.nvim_chan_send(chanId, line .. "\n")
              end
           end, 
        on_stderr = someFunction
   })
end


vim.keymap.set("n", "<M-a>", function() openTerminalAndCleanUpWindows() end, sil)
vim.keymap.set("n", "<M-r>", function() sendSmth() end, sil)
vim.keymap.set("n", "<M-h>", function() moveWindow("h") end, sil)
vim.keymap.set("n", "<M-j>", function() moveWindow("j") end, sil)
vim.keymap.set("n", "<M-k>", function() moveWindow("k") end, sil)
vim.keymap.set("n", "<M-l>", function() moveWindow("l") end, sil)

--}}}

vim.keymap.set("i", "<C-]>", function() insertBlock("{", "}") end, sil)
vim.keymap.set("i", "<C-9>", "()", sil)
vim.keymap.set("i", "<C-l>", "<Esc>la<space>", sil) --Move beyond the adjacent ")"
vim.api.nvim_create_user_command(
   'ToAscii',
   function ()
      local currentLine = getCurrLineContent()
      local lineN = vim.api.nvim_win_get_cursor(0)[1]
      local cursorCol = vim.api.nvim_win_get_cursor(0)[2] + 1 -- +1 because the Neovim API is stupid
      local startCol
      local endCol
      for j = cursorCol, 1, -1 do
         local charCode = string.byte(currentLine:sub(j, j))
         if charCode < 48 or charCode > 57 then
            startCol = j + 1
            break
         end
      end
      
      for j = cursorCol, #currentLine, 1 do
         local charCode = string.byte(currentLine:sub(j, j))
         if charCode < 48 or charCode > 57 then
            endCol = j
            break
         end
      end
      if startCol == endCol then
         return
      end
      local fullAsciiNumber = currentLine:sub(startCol, endCol)
      local newLine = currentLine:sub(1, startCol - 1) 
         .. string.char(tonumber(fullAsciiNumber)) 
         .. currentLine:sub(endCol, #currentLine)
      vim.api.nvim_buf_set_lines(0, lineN - 1, lineN, false, { newLine})
   end,
   { nargs = 0 }
)


--{{{ Goto (for navigating to source lines from GDB)

function goto(fN, lineNum)
    local cwd = vim.fn.getcwd()
    local searchFor = cwd .. "/" .. fN
    print(searchFor)
    for i, buf in ipairs(vim.api.nvim_list_bufs()) do
        if searchFor == vim.api.nvim_buf_get_name(buf) then
            vim.api.nvim_win_set_buf(0, buf)
            if vim.api.nvim_win_get_height(0) >= lineNum then
                vim.api.nvim_win_set_cursor(0, {lineNum, 4})
            else
                vim.api.nvim_win_set_cursor(0, {1, 4})
            end
        end
    end
end

--}}}
--{{{ Running tests in the right tmux pane

local function runTestShowOutput()
    vim.cmd(":wa")
    os.execute("tmux send-keys -t 1 'make all'")
    os.execute("tmux send-keys -t 1 Enter")
end


vim.keymap.set("n", "<leader>t", runTestShowOutput, sil)
vim.keymap.set("i", "<C-t>", runTestShowOutput, sil)



--}}}
--}}}
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
--{{{ File browsin'

vim.api.nvim_create_user_command(
  'Browse',
  function (opts)
    vim.fn.system { 'xdg-open', opts.fargs[1] }
  end,
  { nargs = 1 }
)

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
--~        on_stdout = function(j, d, e) output = output .. vim.fn.join(d)  end,
--~        on_stderr = someThirdFunction
--~    }
--~)
--}}}
--{{{ Language server protocol

vim.api.nvim_create_autocmd('FileType', {
    -- This handler will fire when the buffer's 'filetype' is C
    pattern = "c",
    callback = function(args)
        vim.lsp.start({
            name = "clangd",
            cmd = {"clangd"},
            -- Set the "root directory" to the parent directory of the file in the
            -- current buffer (`args.buf`) that contains either a "setup.py" or a
            -- "pyproject.toml" file. Files that share a root directory will reuse
            -- the connection to the same LSP server.
            root_dir = vim.fs.root(args.buf, {"Makefile"}),
        })
        
        map('n','gd','<cmd>lua vim.lsp.buf.definition()<CR>')
        map('n','gc','<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
        map('n','<leader>r','<cmd>lua vim.lsp.buf.rename()<CR>')
    end
})

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        client.server_capabilities.semanticTokensProvider = nil
    end
})

--}}}
