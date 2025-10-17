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
--{{{ Settings

vim.o.runtimepath = "~/.local/share/nvim/site,~/.config/nvim"
vim.opt.foldmethod = "marker"
vim.opt.wrap = true
vim.opt.linebreak = true -- Stop words from being broken on wrap
vim.opt.showmode = false -- Don't display current mode
vim.g.loaded_matchparen = true
vim.g.loaded_matchparen = true
vim.g.loaded_matchbracket = true 
vim.opt.termguicolors = true 

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
vim.api.nvim_set_hl(0, "Normal", { ctermbg = 0 })
vim.api.nvim_set_hl(0, "String", { fg = "#00FF00" })
vim.api.nvim_set_hl(0, "Comment", { fg = "#00FF00" })
vim.api.nvim_set_hl(0, "Folded", { bg = "#303030" })
vim.api.nvim_set_hl(0, "Statement", { fg = "#FFFF00" })

--}}}
--{{{ Core keybindings


map("i", "<C-;>", "<Esc>")
map("i", "<Tab>", "<Esc>")
map("i", "<C-space>", "<space><space><space>") -- indentation insert
map("i", "<C-s>", "<Esc>:wa<CR>") -- save all and enter normal mode
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
-- quickfix list navigation
map("n", "[q", ":cprev<CR>")
map("n", "]q", ":cnext<CR>")

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

function windowAtCenter(inputWidth)
	return {
		relative = "win",
		row = vim.api.nvim_win_get_height(0) / 2 - 1,
		col = vim.api.nvim_win_get_width(0) / 2 - inputWidth / 2,
	}
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
   
   vim.api.nvim_win_set_cursor(0, {limits.start, 1})
end

local function appendCommas()
    local limits = getLimitsOfCurrentBlock()

    i = limits.start
    while i < (limits.endd - 1) do
        local existingLine = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        vim.api.nvim_buf_set_lines(0, i - 1, i, false, {existingLine .. ","})
        i = i + 1
    end
end

local function asciiCodeToSymbol()
   local currentLine = getCurrLineContent()
   local lineN = vim.api.nvim_win_get_cursor(0)[1]
   local cursorCol = vim.api.nvim_win_get_cursor(0)[2] + 1 -- +1 because the Neovim API is stupid
   local startCol = -1
   local endCol = -1
   for j = cursorCol, 1, -1 do
      local charCode = string.byte(currentLine:sub(j, j))
      if charCode < 48 or charCode > 57 then
         startCol = j + 1
         break
      end
   end
   if startCol == -1 then
      startCol = 1
   end
   
   for j = cursorCol, #currentLine, 1 do
      local charCode = string.byte(currentLine:sub(j, j))
      if charCode < 48 or charCode > 57 then
         endCol = j - 1
         break
      end
   end
   if endCol == -1 then
      endCol = #currentLine
   end
   
   if startCol == endCol then
      return
   end
   local fullAsciiNumber = currentLine:sub(startCol, endCol)
   print(fullAsciiNumber)
   local newLine = currentLine:sub(1, startCol - 1) 
      .. string.char(tonumber(fullAsciiNumber)) 
      .. currentLine:sub(endCol + 1, #currentLine)
   vim.api.nvim_buf_set_lines(0, lineN - 1, lineN, false, { newLine})
end

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
--{{{ Floating select

function floatingSelect(title, choiceLines, choiceCallbacks)
   local width = 10;
   for i, choice in ipairs(choiceLines) do
      if #choice > width then
         width = #choice
      end
   end
   if width < 70 then
      width = width + 10
   else
      width = 80
   end

	local winConfig = {
		focusable = true,
		style = "minimal",
		border = "rounded",
		width = width,
		height = #choiceLines,
		title = title,
		relative = "win",
		row = vim.api.nvim_win_get_height(0) / 2 - 1,
		col = vim.api.nvim_win_get_width(0) / 2 - width / 2
	}

	-- Create floating window.
	local selectBuffer = vim.api.nvim_create_buf(false, true)
   vim.api.nvim_buf_set_lines(selectBuffer, 0, 0, false, choiceLines)
   vim.api.nvim_set_option_value("readonly", true, {buf = selectBuffer, scope = "local"})
	local window = vim.api.nvim_open_win(selectBuffer, true, winConfig)

	-- Enter to confirm
	vim.keymap.set({ "n" }, "<cr>", function()
      local lineN = vim.api.nvim_win_get_cursor(0)[1]
		vim.api.nvim_win_close(window, true)
		choiceCallbacks[lineN]()
	end, { buffer = buffer })

	-- Esc or q to close
	vim.keymap.set("n", "<esc>", function()
		vim.api.nvim_win_close(window, true)
	end, { buffer = buffer })
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(window, true)
	end, { buffer = buffer })
end

--}}}


--map("n", "<C-m>", "vipk:'<,'>s/$/,/<CR>")
map("n", "<C-,>", 
   [[ :normal vipk<CR> <bar> :s/$/,/<CR> ]]
 --  [[:normal! vipk<CR> <bar> :'<,'>s/$/,/<CR>]]
)
--//~vim.keymap.set("n", "<C-,>",
--//~   function() 
--//~      floatingSelect("Choose action (`q` to quit)", 
--//~         {"Append commas to all lines in block", 
--//~          "Append commas and rectangularize text", 
--//~          "Convert ASCII code under cursor to symbol"
--//~         },
--//~         {appendCommas, formatCommas, asciiCodeToSymbol}
--//~      )
--//~   end 
--//~, sil)

vim.keymap.set("i", "<C-]>", function() insertBlock("{", "}") end, sil)
vim.keymap.set("i", "<C-9>", "()", sil)
vim.keymap.set("i", "<C-l>", "<Esc>la<space>", sil) --Move beyond the adjacent ")"

--{{{ Goto (for navigating to source lines from GDB)

function goto(fN, lineNum)
    local cwd = vim.fn.getcwd()
    local searchFor = cwd .. "/" .. fN
    print(searchFor)
    for i, buf in ipairs(vim.api.nvim_list_bufs()) do
        if searchFor == vim.api.nvim_buf_get_name(buf) then
            vim.api.nvim_win_set_buf(0, buf)
            if vim.api.nvim_win_get_height(0) >= lineNum then
                vim.api.nvim_win_set_cursor(0, {lineNum, 3})
            else
                vim.api.nvim_win_set_cursor(0, {1, 3})
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
--{{{ miniPick
--{{{ setup

local MiniPick = {}
local H = {}

--- Module setup
---
---                                                                              *:Pick*
--- Calling this function creates a `:Pick` user command. It takes picker name
--- from |MiniPick.registry| as mandatory first argument and executes it with
--- following (expanded, |expandcmd()|) |<f-args>| combined in a single table.
--- To add custom pickers, update |MiniPick.registry|.
MiniPick.setup = function(config)
   -- Export module
   _G.MiniPick = MiniPick

   -- Setup config
   config = H.setupConfig(config)

   -- Apply config
   H.applyConfig(config)

   -- Define behavior
   H.createAutocommands()

   -- Create default highlighting
   H.createDefaultHighlighting()

   -- Create user commands
   H.createUserCommands()

   -- Disable terminal emulator's pasting with active picker
   local pasteOrig = vim.paste
   vim.paste = function(...)
      if not MiniPick.isPickerActive() then return pasteOrig(...) end
      H.notify('Use `mappings.paste` (`<C-r>` by default) with "*" or "+" register.', 'HINT')
   end
end

MiniPick.config = {
   -- Delays (in ms; should be at least 1)
   delay = {
      -- Delay between forcing asynchronous behavior
      async = 10,

      -- Delay between computation start and visual feedback about it
      busy = 50,
   },

   -- Keys for performing actions. See `:h MiniPick-actions`.
   mappings = {
      caretLeft   = '<Left>',
      caretRight = '<Right>',

      choose                  = '<CR>',
      chooseInsplit    = '<C-s>',
      chooseIntabpage = '<C-t>',
      chooseInvsplit   = '<C-v>',
      chooseMarked       = '<M-CR>',

      deleteChar          = '<BS>',
      deleteCharRight = '<Del>',
      deleteLeft          = '<C-u>',
      deleteWord          = '<C-w>',

      mark       = '<C-x>',
      markAll = '<C-a>',

      moveDown   = '<C-n>',
      moveStart = '<C-g>',
      moveUp      = '<C-p>',

      paste = '<C-r>',

      refine            = '<C-Space>',
      refineMarked = '<M-Space>',

      scrollDown   = '<C-f>',
      scrollLeft   = '<C-h>',
      scrollRight = '<C-l>',
      scrollUp      = '<C-b>',

      stop = '<Esc>',

      toggleInfo      = '<S-Tab>',
      togglePreview = '<Tab>',
   },

   -- General options
   options = {
      -- Whether to show content from bottom to top
      contentFromBottom = false,

      -- Whether to cache matches (more speed and memory on repeated prompts)
      useCache = false,
   },

   -- Source definition. See `:h MiniPick-source`.
   source = {
      items = nil,
      name   = nil,
      cwd    = nil,

      match    = nil,
      show      = nil,
      preview = nil,

      choose            = nil,
      chooseMarked = nil,
   },

   -- Window related options
   window = {
      -- Float window config (table or callable returning it)
      config = nil,

      -- String to use as caret in prompt
      promptCaret = '▏',

      -- String to use as prefix in prompt
      promptPrefix = '> ',
   },
}
--}}}
--{{{pickers

--- Start picker
---
--- Notes:
--- - If there is currently an active picker, it is properly stopped and new one
---    is started "soon" in the main event-loop (see |vim.schedule()|).
--- - Current window at the moment of this function call is treated as "target".
---    It will be set back as current after |MiniPick.stop()|.
---    See |MiniPick.getPickerState()| and |MiniPick.setPickerTargetWindow()|.
MiniPick.start = function(opts)
   if MiniPick.isPickerActive() then
      -- Try proper 'key query process' stop
      MiniPick.stop()
      -- NOTE: Needs `defer_fn()` for `stop()` to properly finish code flow and
      -- not be executed before it
      return vim.defer_fn(function()
         -- NOTE: if `MiniPick.stop()` still didn't stop, force abort
         if MiniPick.isPickerActive() then H.pickerStop(H.pickers.active, true) end
         MiniPick.start(opts)
      end, 0.5)
   end

   H.cache = {}
   opts = H.validatePickerOpts(opts)
   local picker = H.pickerNew(opts)
   H.pickers.active = picker

   H.pickerSetBusy(picker, true)
   local items = H.expandCallable(opts.source.items)
   -- - Set items on next event loop to not block when computing stritems
   if H.islist(items) then vim.schedule(function() MiniPick.setPickerItems(items) end) end

   H.pickerTrackLostFocus(picker)
   return H.pickerAdvance(picker)
end

--- Stop active picker
MiniPick.stop = function()
   if not MiniPick.isPickerActive() then 
      return
   end
   H.cache.isForceStopAdvance = true
   if H.cache.isInGetCharstr then 
      vim.api.nvim_feedkeys('\3', 't', true) 
   end
end

--- Refresh active picker
MiniPick.refresh = function()
   if not MiniPick.isPickerActive() then return end
   H.pickerUpdate(H.pickers.active, false, true)
end

--}}}
--{{{matches

--- Default match
---
--- Filter target stritems to contain query and sort from best to worst matches.
---
--- Implements default value for |MiniPick-source.match|.
---
--- By default (if no special modes apply) it does the following fuzzy matching:
---
--- - Stritem (= the queried string) contains query if it contains all its elements verbatim 
---   in the same order (yet possibly with gaps, i.e. not strictly one after another).
---  Note: empty query is contained in any string.
---
--- - Sorting is done with the following ordering (same as in |mini.fuzzy|):
---       - The smaller the match width (end column minus start column) the better.
---       - Among same match width, the smaller start column the better.
---       - Among same match width and start column, preserve original order.
---
MiniPick.defaultMatch = function(stritems, inds, query, opts)
   opts = opts or {}
   local isSync = opts.sync or not MiniPick.isPickerActive()
   
   local setMatchInds = function(x) 
      return x 
   end
   if not isSync then
      isSync = MiniPick.setPickerMatchInds
   end 
   local f = function()
      if #query == 0 then 
         return setMatchInds(H.seqAlong(stritems)) 
      end
      local matchData, matchType = H.matchFilter(inds, stritems, query)
      if matchData == nil then 
         return 
      end
      if matchType == 'useall' then
         return setMatchInds(H.seqAlong(stritems)) 
      end
      if opts.preserveOrder then
         return setMatchInds(H.matchNoSort(matchData)) 
      end
      local matchInds = H.matchSort(matchData)
      if matchInds == nil then 
         return 
      end
      return setMatchInds(matchInds)
   end

   if isSync then return f() end
   coroutine.resume(coroutine.create(f))
end

--}}}
--{{{shows

--- Default show
---
--- Show items in a buffer and highlight parts that actually match query (assuming
--- match is done with |MiniPick.default_match()|). Lines are computed based on
--- the |MiniPick-source.items-stritems|.
---
--- Implements default value for |MiniPick-source.show|.
---
--- Uses the following highlight groups (see |MiniPick| for their description):
---
--- * `MiniPickIconDirectory`
--- * `MiniPickIconFile`
--- * `MiniPickMatchCurrent`
--- * `MiniPickMatchMarked`
--- * `MiniPickMatchRanges`
---
MiniPick.defaultShow = function(bufId, items, query, opts)
   local defaultIcons = { directory = ' ', file = ' ', none = '   ' }
   opts = vim.tbl_deep_extend('force', { showIcons = false, icons = defaultIcons }, opts or {})

   -- Compute and set lines. Compute prefix based on the whole items to allow
   -- separate `text` and `path` table fields (preferring second one).
   local getPrefixData = opts.showIcons and 
      function(item) return H.getIcon(item, opts.icons) end
      or function() return { text = '' }
   end
   local prefixData = vim.tbl_map(getPrefixData, items)

   local lines = vim.tbl_map(H.itemToString, items)
   local tabSpaces = string.rep(' ', vim.o.tabstop)
   lines = vim.tbl_map(
      function(l) 
         return l:gsub('%z', '│'):gsub('[\r\n]', ' '):gsub('\t', tabSpaces) 
      end,
      lines
   )

   local linesToShow = {}
   for i, l in ipairs(lines) do
      linesToShow[i] = prefixData[i].text .. l
   end

   H.setBuflines(bufId, linesToShow)

   -- Extract match ranges
   local nsId = H.nsId.ranges
   H.clearNamespace(bufId, nsId)

   if H.queryIsIgnorecase(query) then
      lines, query = vim.tbl_map(H.tolower, lines), vim.tbl_map(H.tolower, query)
   end
   local matchData, matchType, queryAdjusted = H.matchFilter(H.seqAlong(lines), lines, query)
   if matchData == nil then 
      return
   end

   local matchRangesFun = matchType == 'fuzzy' and H.matchRangesFuzzy or H.matchRangesExact
   local matchRanges = matchRangesFun(matchData, queryAdjusted, lines)

   -- Place range highlights accounting for possible shift due to prefixes
   local extmarkOpts = { hlGroup = 'MiniPickMatchRanges', hlMode = 'combine', priority = 200 }
   for i = 1, #matchData do
      local row, ranges = matchData[i][3], matchRanges[i]
      local startOffset = prefixData[row].text:len()
      for _, range in ipairs(ranges) do
         extmarkOpts.endRow, extmarkOpts.endCol = row - 1, startOffset + range[2]
         H.setExtMark(bufId, nsId, row - 1, startOffset + range[1] - 1, extmarkOpts)
      end
   end

   -- Highlight prefixes
   if not opts.showIcons then return end
   local iconExtmarkOpts = { hlMode = 'combine', priority = 200 }
   for i = 1, #prefixData do
      iconExtmarkOpts.hlGroup = prefixData[i].hl
      iconExtmarkOpts.endRow, iconExtmarkOpts.endCol = i - 1, prefixData[i].text:len()
      H.setExtMark(bufId, nsId, i - 1, 0, iconExtmarkOpts)
   end
end

--- Default preview
---
--- Preview item. Logic follows the rules in |MiniPick-source.items-common|:
--- - File and buffer are shown at the start.
--- - Directory has its content listed.
--- - Line/position/region in file or buffer is shown at start.
--- - Others are shown directly with |vim.inspect()|.
---
--- Implements default value for |MiniPick-source.preview|.
---
--- Uses the following highlight groups (see |MiniPick| for their description):
---
--- * `MiniPickPreviewLine`
--- * `MiniPickPreviewRegion`
MiniPick.defaultPreview = function(bufId, item, opts)
   opts = vim.tbl_deep_extend('force', { nContextLines = 2 * vim.o.lines, linePosition = 'top' }, opts or {})
   local itemData = H.parseItem(item)
   if itemData.type == 'file' then return H.previewFile(bufId, itemData, opts) end
   if itemData.type == 'directory' then return H.previewDirectory(bufId, itemData) end
   if itemData.type == 'buffer' then return H.previewBuffer(bufId, itemData, opts) end
   if itemData.type == 'uri' then return H.previewUri(bufId, itemData, opts) end
   H.previewInspect(bufId, item)
end

--}}}
--{{{choosers

--- Default chooser
---
--- Choose item. Logic follows the rules in |MiniPick-source.items-common|:
--- - File uses |bufadd()| and sets cursor at the start of line/position/region.
--- - Buffer is set as current in target window and sets cursor similarly.
--- - Directory is called with |:edit| in the target window.
--- - Others have the output of |vim.inspect()| printed in Command line.
---
--- Implements default value for |MiniPick-source.choose|.
MiniPick.defaultChooser = function(item)
   if item == nil then return end
   local pickerState = MiniPick.getPickerState()
   local winTarget = pickerState ~= nil and pickerState.windows.target 
         or vim.api.nvim_get_current_win()
   if not H.isValidWin(winTarget) then 
      winTarget = H.getFirstValidNormalWindow() 
   end

   local itemData = H.parseItem(item)
   if itemData.type == 'file' or itemData.type == 'directory' or itemData.type == 'uri' then
      return H.choosePath(winTarget, itemData)
   end
   if itemData.type == 'buffer' then 
      return H.chooseBuffer(winTarget, itemData) 
   end
   H.choosePrint(item)
end

--- Default choose marked items
---
--- Choose marked items. Logic follows the rules in |MiniPick-source.items-common|:
--- - If among items there is at least one file or buffer, quickfix list is opened
---    with all file or buffer lines/positions/regions.
--- - Otherwise, picker's `source.choose` is called on the first item.
MiniPick.defaultChooseMarked = function(items, opts)
   if not H.islist(items) then H.error('`items` should be an array') end
   if #items == 0 then return end
   opts = vim.tbl_deep_extend('force', { listType = 'quickfix' }, opts or {})

   -- Construct a potential quickfix/location list
   local list = {}
   for _, item in ipairs(items) do
      local itemData = H.parseItem(item)
      if itemData.type == 'file' or itemData.type == 'buffer' or itemData.type == 'uri' then
         local entry = { 
            bufnr = itemData.bufId, filename = H.parseUri(itemData.path) or itemData.path 
         }
         entry.lnum, entry.col = itemData.lnum or 1, itemData.col or 1
         entry.text = (itemData.text or ''):gsub('%z', '│')
         entry.endLnum, entry.endCol = itemData.endLnum, itemData.endCol
         table.insert(list, entry)
      end
   end

   -- Fall back to choosing first item if no quickfix list was constructed
   local isActive = MiniPick.isPickerActive()
   if #list == 0 then
      if not isActive then return end
      local choose = MiniPick.getPickerOpts().source.choose
      return choose(items[1])
   end

   -- Set as quickfix or location list
   local title = '<No picker>'
   if isActive then
      ---@diagnostic disable:param-type-mismatch
      local sourceName, prompt = 
         MiniPick.getPickerOpts().source.name, table.concat(MiniPick.getPickerQuery())
      title = sourceName .. (prompt == '' and '' or (' : ' .. prompt))
   end
   local listData = { items = list, title = title, nr = '$' }

   if opts.listType == 'location' then
      local winTarget = MiniPick.getPickerState().windows.target
      if not H.isValidWin(winTarget) then winTarget = H.getFirstValidNormalWindow() end
      vim.fn.setloclist(winTarget, {}, ' ', listData)
      vim.schedule(function() vim.cmd('lopen') end)
   else
      vim.fn.setqflist({}, ' ', listData)
      vim.schedule(function() vim.cmd('copen') end)
   end
end

--- Select rewrite
---
--- Function which can be used to directly override |vim.ui.select()| to use
--- 'mini.pick' for any "select" type of tasks.
---
--- Implements required by `vim.ui.select()` signature, with some differencies:
--- - Allows `opts.previewItem` that returns an array of lines for item preview.
--- - Allows fourth `startOpts` argument to customize |MiniPick.start()| call.
---
--- Notes:
--- - `onChoice` is called when target window is current.
MiniPick.uiSelect = function(items, opts, onChoice, startOpts)
   local formatItem = opts.formatItem or H.itemToString
   local itemsExt = {}
   for i = 1, #items do
      table.insert(itemsExt, { text = formatItem(items[i]), item = items[i], index = i })
   end

   local previewItem = vim.isCallable(opts.previewItem) and opts.previewItem
      or function(x) return vim.split(vim.inspect(x), '\n') end
   local preview = function(bufId, item) H.setBuflines(bufId, previewItem(item.item)) end

   local wasAborted = true
   local choose = function(item)
      wasAborted = false
      if item == nil then return end
      local winTarget = MiniPick.getPickerState().windows.target
      if not H.isValidWin(winTarget) then winTarget = H.getFirstValidNormalWindow() end
      vim.api.nvim_win_call(winTarget, function()
         onChoice(items[item.index], item.index)
         MiniPick.setPickerTargetWindow(vim.api.nvim_get_current_win())
      end)
   end

   local source = { 
      items = itemsExt, name = opts.prompt or opts.kind, preview = preview, choose = choose
   }
   startOpts = vim.tbl_deep_extend('force', startOpts or {}, { source = source })
   local item = MiniPick.start(startOpts)
   if item == nil and wasAborted then onChoice(nil) end
end

--}}}
--{{{picker

H.validatePickerOpts = function(opts)
   opts = opts or {}
   if type(opts) ~= 'table' then H.error('Picker options should be table.') end

   opts = vim.deepcopy(H.getConfig(opts))

   local validateCallable = function(x, xName)
      if not vim.isCallable(x) then 
         H.error(string.format('`%s` should be callable.', xName)) 
      end
   end

   -- Source
   local source = opts.source

   local items = source.items or {}
   local isValidItems = H.islist(items) or vim.isCallable(items)
   if not isValidItems then 
      H.error('`source.items` should be array or callable.')
   end

   source.name = tostring(source.name or '<No name>')

   if type(source.cwd) == 'string' then 
      source.cwd = H.fullPath(source.cwd) 
   end
   if source.cwd == nil then 
      source.cwd = vim.fn.getcwd() 
   end
   if vim.fn.isdirectory(source.cwd) == 0 then 
      H.error('`source.cwd` should be a valid directory path.') 
   end

   source.match = source.match or MiniPick.defaultMatch
   validateCallable(source.match, 'source.match')

   source.show = source.show or MiniPick.defaultShow
   validateCallable(source.show, 'source.show')

   source.preview = source.preview or MiniPick.defaultPreview
   validateCallable(source.preview, 'source.preview')

   source.chooser = source.chooser or MiniPick.defaultChooser
   validateCallable(source.chooser, 'source.chooser')

   source.chooseMarked = source.chooseMarked or MiniPick.defaultChooseMarked
   validateCallable(source.chooseMarked, 'source.chooseMarked')

   -- Delay
   for key, value in pairs(opts.delay) do
      if not (type(value) == 'number' and value > 0) then 
         H.error(string.format('`delay.%s` should be a positive number.', key)) 
      end
   end

   -- Mappings
   local defaultMappings = H.defaultConfig.mappings
   for field, x in pairs(opts.mappings) do
      if type(field) ~= 'string' then H.error('`mappings` should have only string fields.') end
      local isBuiltinAction = defaultMappings[field] ~= nil
      if isBuiltinAction and type(x) ~= 'string' then
         H.error(string.format('Mapping for built-in action "%s" should be string.', field))
      end
      if not isBuiltinAction and not 
            (type(x) == 'table' and type(x.char) == 'string' and vim.is_callable(x.func)) then
         H.error(
            string.format(
               'Mapping for custom action "%s" should be table with `char` and `func`.', 
               field
            )
         )
      end
   end

   -- Options
   local options = opts.options
   if type(options.contentFromBottom) ~= 'boolean' then 
      H.error('`options.contentFromBottom` should be boolean.') 
   end
   if type(options.useCache) ~= 'boolean' then 
      H.error('`options.useCache` should be boolean.') 
   end

   -- Window
   local winConfig = opts.window.config
   local isValidWinconfig = winConfig == nil 
      or type(winConfig) == 'table' 
      or vim.is_callable(winConfig)
   if not isValidWinconfig then 
      H.error('`window.config` should be table or callable.') 
   end

   return opts
end

H.pickerNew = function(opts)
   -- Create buffer
   local bufId = H.pickerNewBuf()

   -- Create window
   local winTarget = vim.api.nvim_get_current_win()
   local winId = H.pickerNewWin(bufId, opts.window.config, opts.source.cwd)

   -- Construct and return object
   local picker = {
      -- Permanent data about picker (should not change)
      opts = opts,

      -- Items to pick from
      items = nil,
      stritems = nil,
      stritemsIgnorecase = nil,

      -- Associated Neovim objects
      buffers = { main = bufId, preview = nil, info = nil },
      windows = { main = winId, target = winTarget },

      -- Query data
      query = {},
      -- - Query index at which new entry will be inserted
      caret = 1,
      -- - Array of `stritems` indexes matching current query
      matchInds = nil,
      -- - Map of of currently marked `stritems` indexes (as keys)
      markedIndsMap = {},
      -- - Action keys which should be processed as described in mappings
      actionKeys = H.normalizeMappings(opts.mappings),

      -- Whether picker is currently busy processing data
      isBusy = false,

      -- Cache for `matches` per prompt for more performant querying
      cache = {},

      -- View data
      -- - Which buffer should currently be shown
      viewState = 'main',

      -- - Index range of `matchInds` currently visible. Present for significant
      --    performance increase to render only what is visible.
      visibleRange = { from = nil, to = nil },

      -- - Index of `matchInds` pointing at current item
      currentInd = nil,
      -- - Array of indices of `matchInds` pointing at currently shown items
      showInds = {},
   }

   H.querytick = H.querytick + 1

   return picker
end

H.pickerAdvance = function(picker)
   vim.schedule(function() vim.api.nvim_exec_autocmds('User', { pattern = 'MiniPickStart' }) end)

   local doMatch, isAborted = false, false
   for _ = 1, 1000000 do
      if H.cache.isForceStopAdvance then break end
      H.pickerUpdate(picker, doMatch)

      local char = H.getcharstr(picker.opts.delay.async)
      if H.cache.isForceStopAdvance then break end

      isAborted = char == nil
      if isAborted then break end

      local currAction = picker.actionKeys[char] or {}
      doMatch = currAction.name == nil 
         or vim.startswith(currAction.name, 'delete') 
         or currAction.name == 'paste'
      isAborted = currAction.name == 'stop'

      local shouldStop
      if currAction.isCustom then
         shouldStop = currAction.func()
      else
         shouldStop = (currAction.func or H.pickerQueryAdd)(picker, char)
      end
      if shouldStop then break end
   end

   local item
   if not isAborted then item = H.pickerGetCurrentItem(picker) end
   H.cache.isForceStopAdvance = nil
   H.pickerStop(picker)
   return item
end

H.pickerUpdate = function(picker, doMatch, updateWindow)
   if doMatch then 
      H.pickerMatch(picker) 
   end
   if updateWindow then
      local config = H.pickerComputeWinConfig(picker.opts.window.config)
      vim.api.nvim_win_set_config(picker.windows.main, config)
      H.pickerSetCurrentInd(picker, picker.currentInd, true)
   end
   H.pickerSetBordertext(picker)
   H.pickerSetLines(picker)
   H.redraw()
end

H.pickerNewBuf = function()
   local bufId = H.create_scratch_buf('main')
   vim.bo[bufId].filetype = 'minipick'
   return bufId
end

H.pickerNewWin = function(bufId, win_config, cwd)
   -- Hide cursor while picker is active (to not be visible in the window)
   -- This mostly follows a hack from 'folke/noice.nvim'
   H.cache.guicursor = vim.o.guicursor
   vim.o.guicursor = 'a:MiniPickCursor'

   -- Create window and focus on it
   local winId = vim.api.nvim_open_win(bufId, true, H.pickercompute_win_config(win_config, true))

   -- Set window-local data
   vim.wo[winId].foldenable = false
   vim.wo[winId].foldmethod = 'manual'
   vim.wo[winId].list = true
   vim.wo[winId].listchars = 'extends:…'
   vim.wo[winId].scrolloff = 0
   vim.wo[winId].wrap = false
   H.win_update_hl(winId, 'NormalFloat', 'MiniPickNormal')
   H.win_update_hl(winId, 'FloatBorder', 'MiniPickBorder')
   vim.fn.clearmatches(winId)

   -- Set window's local "current directory" for easier choose/preview/etc.
   H.win_set_cwd(nil, cwd)

   return winId
end

H.pickercompute_win_config = function(win_config, is_for_open)
   local hasTabline = vim.o.showtabline == 2 
         or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1)
   local hasStatusline = vim.o.laststatus > 0
   local maxHeight = vim.o.lines - vim.o.cmdheight 
      - (has_tabline and 1 or 0) - (has_statusline and 1 or 0)
   local maxWidth = vim.o.columns

   local defaultConfig = {
      relative = 'editor',
      anchor = 'SW',
      width = math.floor(0.618 * max_width),
      height = math.floor(0.618 * max_height),
      col = 0,
      row = maxHeight + (hasTabline and 1 or 0),
      border = (vim.fn.exists('+winborder') == 1 and vim.o.winborder ~= '') and vim.o.winborder 
         or 'single',
      style = 'minimal',
      noautocmd = isForOpen,
      -- Use high enough value to be on top of built-in windows (pmenu, etc.)
      zindex = 251,
   }
   local config = vim.tbl_deep_extend('force', defaultConfig, H.expandCallable(winConfig) or {})

   -- Tweak config values to ensure they are proper
   if config.border == 'none' then config.border = { '', ' ', '', '', '', ' ', '', '' } end
   -- - Adjust dimensions accounting for actually present border parts
   local bor, n = config.border, type(config.border) == 'table' and #config.border or 0
   local heightOffset = n == 0 and 2 
      or ((bor[1 % n + 1] == '' and 0 or 1) + (bor[5 % n + 1] == '' and 0 or 1))
   local widthOffset = n == 0 and 2 
      or ((bor[3 % n + 1] == '' and 0 or 1) + (bor[7 % n + 1] == '' and 0 or 1))
   config.height = math.max(math.min(config.height, maxHeight - heightOffset), 1)
   config.width = math.max(math.min(config.width, maxWidth - widthOffset), 1)

   return config
end

H.pickerTrackLostFocus = function(picker)
   local track = vim.schedule_wrap(function()
      local isCurWin = vim.api.nvim_get_current_win() == picker.windows.main
      local isProperFocus = isCurWin and (H.cache.isInGetCharstr or vim.fn.mode() ~= 'n')
      if is_proper_focus then return end
      if H.cache.isInGetCharstr then return vim.api.nvim_feedkeys('\3', 't', true) end
      H.pickerstop(picker, true)
   end)
   H.timers.focus:start(1000, 1000, track)
end

H.pickerSetItems = function(picker, items, opts)
   -- Compute string items to work with (along with their lower variants)
   local stritems, stritemsIgnorecase, tolower = {}, {}, H.tolower
   local pokePicker = H.pokePickerThrottle(opts.querytick)
   for i, x in ipairs(items) do
      if not pokePicker() then return end
      local toAdd = H.itemToString(x)
      table.insert(stritems, to_add)
      table.insert(stritemsIgnorecase, tolower(to_add))
   end

   picker.items, picker.stritems, picker.stritems_ignorecase = items, stritems, stritems_ignorecase
   picker.cache, picker.markedIndsMap = {}, {}
   H.pickerSetBusy(picker, false)

   H.pickerSetMatchInds(picker, H.seqAlong(items))
   -- Force update visible range for correct "show" lines computation
   H.pickerSetCurrentInd(picker, picker.currentInd, true)
   H.pickerUpdate(picker, opts.doMatch)
end

H.pickerSetBusy = function(picker, value)
   picker.isBusy = value

   -- NOTE: Don't precompute highlight group to always set a valid one
   local update_border_hl = function()
      H.timers.busy:stop()
      H.winUpdateHl(picker.windows.main, 'FloatBorder', picker.is_busy and 'MiniPickBorderBusy' or 'MiniPickBorder')
   end

   if value then return H.timers.busy:start(picker.opts.delay.busy, 0, vim.schedule_wrap(update_border_hl)) end
   updateBorder_hl()
end

H.pickerSetMatchInds = function(picker, inds)
   if inds == nil then return end
   H.pickerSetBusy(picker, false)

   picker.matchInds = inds

   local cachePrompt = table.concat(picker.query)
   if picker.opts.options.useCache then picker.cache[cachePrompt] = { inds = inds } end

   -- Always show result of updated matches
   H.pickerShowMain(picker)

   -- Reset current index if match indexes are updated
   H.pickerSetCurrentInd(picker, 1)

   -- Trigger relevant event if not already inside it
   if not H.insideMinipickMatch then
      H.insideMinipickMatch = true
      vim.api.nvim_exec_autocmds('User', { pattern = 'MiniPickMatch' })
      H.insideMinipickMatch = nil
   end
end

H.pickerSetCurrentInd = function(picker, ind, forceUpdate)
   if picker.items == nil or #picker.matchInds == 0 then
      picker.currentInd, picker.visibleRange = nil, {}
      return
   end

   -- Wrap index around edges
   local nMatches = #picker.matchInds
   ind = (ind - 1) % nMatches + 1

   -- (Re)Compute visible range (centers current index if it is currently outside)
   local from, to, querytick = 
      picker.visibleRange.from, picker.visibleRange.to, picker.visibleRange.querytick
   local needsUpdate = H.querytick ~= querytick 
      or from == nil or to == nil 
      or not (from <= ind and ind <= to)
   if (force_update or needs_update) and H.isValidWin(picker.windows.main) then
      local win_height = vim.api.nvim_win_get_height(picker.windows.main)
      to = math.min(nMatches, math.floor(ind + 0.5 * win_height))
      from = math.max(1, to - win_height + 1)
      to = from + math.min(win_height, nMatches) - 1
   end

   -- Set data
   picker.currentInd = ind
   picker.visibleRange = { from = from, to = to, querytick = H.querytick }
end

H.pickerSetInds = {
   all = function(picker, inds) H.pickerSetMatchInds(H.pickers.active, inds) end,
   current = function(picker, inds)
      if inds[1] == nil or picker.matchInds == nil then 
         return 
      end
      local currentMatchInd, currentAbsInd = nil, inds[1]
      for i, matchAbsInd in ipairs(picker.matchInds) do
         if matchAbsInd == currentAbsInd then 
            currentMatchInd = i 
         end
      end
      if currentMatchInd == nil then 
         H.error('Current match index should be present among all current matches') 
      end
      H.pickerSetCurrentInd(picker, currentMatchInd, true)
   end,
   marked = function(picker, inds)
      if picker.items == nil then return end
      local markedIndsMap, nItems = {}, #picker.items
      for _, ind in ipairs(inds) do
         if not (1 <= ind and ind <= nItems) then 
            H.error('Marked indexes should be from 1 to number of items') 
         end
         markedIndsMap[ind] = true
      end
      picker.markedIndsMap = markedIndsMap
   end,
}

H.pickerSetLines = function(picker)
   local bufId, winId = picker.buffers.main, picker.windows.main
   if not (H.isValidBuf(bufId) and H.isValidWin(winId)) then return end

   if picker.is_busy then return end

   local visibleRange, query = picker.visibleRange, picker.query
   if picker.items == nil or visibleRange.from == nil or visibleRange.to == nil then
      picker.shownInds = {}
      picker.opts.source.show(bufId, {}, query)
      H.clearNamespace(bufId, H.ns_id.matches)
      return
   end

   -- Construct target items
   local itemsToShow, items, shownInds, matchInds = {}, picker.items, {}, picker.matchInds
   local currInd, currLine = picker.currentInd, nil
   local markedIndsMap, markedLnums = picker.markedIndsMap, {}
   local isFromBottom = picker.opts.options.contentFromBottom
   local from = is_from_bottom and visibleRange.to or visibleRange.from
   local to = is_from_bottom and visibleRange.from or visibleRange.to
   for i = from, to, (from <= to and 1 or -1) do
      table.insert(shown_inds, i)
      table.insert(items_to_show, items[matchInds[i]])
      if i == curInd then curLine = #items_to_show end
      if marked_inds_map[matchInds[i]] then table.insert(marked_lnums, #items_to_show) end
   end

   local nEmptyTopLines = isFromBottom and (vim.api.nvim_win_get_height(winId) - #itemsToShow) or 0
   currLine = currLine + nEmptyTopLines
   markedLnums = vim.tbl_map(function(x) return x + n_empty_top_lines end, marked_lnums)

   -- Update visible lines accounting for "from_bottom" direction
   picker.shown_inds = shownInds
   picker.opts.source.show(bufId, items_to_show, query)
   if nEmptyTopLines > 0 then
      local emptyLines = vim.fn['repeat']({ '' }, nEmptyTopLines)
      vim.api.nvim_buf_set_lines(bufId, 0, 0, true, emptyLines)
   end

   local nsId = H.ns_id.matches
   H.clearNamespace(bufId, ns_id)

   -- Add highlighting for marked lines
   local markedOpts = { endCol = 0, hlGroup = 'MiniPickMatchMarked', priority = 202 }
   for _, lnum in ipairs(markedLnums) do
      markedOpts.endRow = lnum
      H.setExtMark(bufId, nsId, lnum - 1, 0, markedOpts)
   end

   -- Update current item
   if currLine > vim.api.nvim_buf_line_count(bufId) then return end

   local currOpts = { 
      endRow = currLine, endCol = 0, 
      hlEol = true, hlGroup = 'MiniPickMatchCurrent', priority = 201 
   }
   H.setExtMark(bufId, nsId, currLine - 1, 0, currOpts)

   -- - Update cursor if showing item matches (needed for 'scroll_{left,right}')
   local cursor = vim.api.nvim_win_get_cursor(winId)
   if picker.viewState == 'main' and cursor[1] ~= currLine then 
      H.setCursor(winId, currLine, cursor[2] + 1) 
   end
end

H.pickerMatch = function(picker)
   if picker.items == nil then return end

   -- Try to use cache first
   local promptCache
   if picker.opts.options.useCache then 
      promptCache = picker.cache[table.concat(picker.query)] 
   end
   if promptCache ~= nil then 
      return H.pickerSetMatchInds(picker, promptCache.inds) 
   end

   local isIgnorecase = H.queryIsIgnorecase(picker.query)
   local stritems = isIgnorecase and picker.stritemsIgnorecase or picker.stritems
   local query = isIgnorecase and vim.tbl_map(H.tolower, picker.query) or picker.query

   H.pickerSetBusy(picker, true)
   local newInds = picker.opts.source.match(stritems, picker.matchInds, query)
   H.pickerSetMatchInds(picker, newInds)
end

H.pickerQueryAdd = function(picker, char)
   -- Determine if it **is** proper single character
   if vim.fn.strchars(char) > 1 or vim.fn.char2nr(char) <= 31 then return end
   table.insert(picker.query, picker.caret, char)
   picker.caret = picker.caret + 1
   H.querytick = H.querytick + 1

   -- Adding character inside query might not result into narrowing matches, so
   -- reset match indexes. Use cache to speed this up.
   local should_reset = picker.items ~= nil and picker.caret <= #picker.query
   if should_reset then picker.matchInds = H.seq_along(picker.items) end
end

H.pickerQueryDelete = function(picker, n)
   local delete_to_left = n > 0
   local left = delete_to_left and math.max(picker.caret - n, 1) or picker.caret
   local right = delete_to_left and picker.caret - 1 or math.min(picker.caret + n, #picker.query)
   for i = right, left, -1 do
      table.remove(picker.query, i)
   end
   picker.caret = left
   H.querytick = H.querytick + 1

   -- Deleting query character increases number of possible matches, so need to
   -- reset already matched indexes prior deleting. Use cache to speed this up.
   if picker.items ~= nil then picker.matchInds = H.seq_along(picker.items) end
end

H.pickerChoose = function(picker, pre_command)
   local currItem = H.pickergetCurrentItem(picker)
   if currItem == nil then return true end

   local winId_target = picker.windows.target
   if pre_command ~= nil and H.isValidWin(winId_target) then
      -- Work around Neovim not preserving cwd during `nvim_win_call`
      -- See: https://github.com/neovim/neovim/issues/32203
      local picker_cwd, global_cwd = vim.fn.getcwd(0), vim.fn.getcwd(-1, -1)
      vim.fn.chdir(global_cwd)
      vim.api.nvim_win_call(winId_target, function()
         vim.cmd(pre_command)
         picker.windows.target = vim.api.nvim_get_current_win()
      end)
      vim.fn.chdir(picker_cwd)
   end

   local ok, res = pcall(picker.opts.source.chooser, currItem)
   -- Delay error to have time to hide picker window
   if not ok then 
      vim.schedule(function() H.error('Error during chooser:\n' .. res) end) 
   end
   -- Error or returning nothing, `nil`, or `false` should lead to picker stop
   return not (ok and res)
end

H.pickerMarkIndexes = function(picker, range_type)
   if picker.items == nil then return end
   local test_inds = range_type == 'current' and { picker.matchInds[picker.currentInd] } or picker.matchInds

   -- Mark if not all marked, unmark otherwise
   local marked_inds_map, is_all_marked = picker.marked_inds_map, true
   for _, ind in ipairs(test_inds) do
      is_all_marked = is_all_marked and marked_inds_map[ind]
   end

   -- NOTE: Set to `nil` and not `false` for easier counting of present values
   local new_val
   if not is_all_marked then new_val = true end
   for _, ind in ipairs(test_inds) do
      marked_inds_map[ind] = new_val
   end

   if picker.view_state == 'info' then H.pickerShowInfo(picker) end
end

H.pickerMoveCaret = function(picker, n) 
   picker.caret = math.min(math.max(picker.caret + n, 1), #picker.query + 1) 
end

H.pickerMoveCurrent = function(picker, by, to)
   if picker.items == nil then return end
   local nMatches = #picker.matchInds
   if nMatches == 0 then return end

   if to == nil then
      -- Account for content direction
      by = (picker.opts.options.content_from_bottom and -1 or 1) * by

      -- Wrap around edges only if current index is at edge
      to = picker.currentInd
      if to == 1 and by < 0 then
         to = nMatches
      elseif to == nMatches and by > 0 then
         to = 1
      else
         to = to + by
      end
      to = math.min(math.max(to, 1), nMatches)
   end

   H.pickerSetCurrentInd(picker, to)

   -- Update not main buffer(s)
   if picker.view_state == 'info' then H.pickerShowInfo(picker) end
   if picker.view_state == 'preview' then H.pickershow_preview(picker) end
end

H.pickerRefine = function(picker, refine_type)
   if picker.items == nil then return end

   -- Make current matches be new items to be matched with default match
   picker.opts.source.match = H.getConfig().source.match or MiniPick.defaultMatch
   picker.query, picker.caret = {}, 1
   MiniPick.setPickerItems(MiniPick.getPickerMatches()[refineType] or {})

   picker._refine = picker._refine or { orig_name = picker.opts.source.name, count = 0 }
   picker._refine.count = picker._refine.count + 1
   local count_suffix = picker._refine.count == 1 and '' or (' ' .. picker._refine.count)
   picker.opts.source.name = string.format('%s (Refine%s)', picker._refine.orig_name, count_suffix)
end

H.pickerscroll = function(picker, direction)
   local winId = picker.windows.main
   if picker.view_state == 'main' and (direction == 'down' or direction == 'up') then
      local n = (direction == 'down' and 1 or -1) * vim.api.nvim_win_get_height(winId)
      H.pickerMoveCurrent(picker, n)
   else
      local keys = ({ down = '<C-f>', up = '<C-b>', left = 'zH', right = 'zL' })[direction]
      vim.api.nvim_win_call(winId, function() vim.cmd('normal! ' .. H.replace_termcodes(keys)) end)
   end
end

H.pickerGetCurrentItem = function(picker)
   if picker.items == nil then return nil end
   return picker.items[picker.matchInds[picker.currentInd]]
end

H.pickerGetRegisterContents = function(picker)
   local register = H.getcharstr(picker.opts.delay.async)
   -- Mimic some "insert object under cursor" behavior of Command-line mode
   local expand_var = ({ ['\1'] = '<cWORD>', ['\6'] = '<cfile>', ['\23'] = '<cword>' })[register]
   if expand_var then
      return vim.api.nvim_win_call(picker.windows.target, function() return vim.fn.expand(expand_var) end)
   end
   if register == '\f' then
      return vim.api.nvim_win_call(picker.windows.target, function() return vim.fn.getline('.') end)
   end
   local has_register, res = pcall(vim.fn.getreg, register)
   return has_register and res or ''
end

H.pickerShowMain = function(picker)
   H.setWinbuf(picker.windows.main, picker.buffers.main)
   picker.view_state = 'main'
end

H.pickerShowInfo = function(picker)
   -- General information
   local info = H.pickerGetGeneralInfo(picker)
   local lines = {
      'General',
      'Source name    │ ' .. info.source_name,
      'Source cwd      │ ' .. info.source_cwd,
      'Total items    │ ' .. info.n_total,
      'Matched items │ ' .. info.n_matched,
      'Marked items   │ ' .. info.n_marked,
      'Current index │ ' .. info.relativeCurrentInd,
   }
   local hl_lines = { 1 }

   local append_char_data = function(data, header)
      if #data == 0 then return end
      table.insert(lines, '')
      table.insert(lines, header)
      table.insert(hl_lines, #lines)

      local width_max = 0
      for _, t in ipairs(data) do
         local desc = t.name:gsub('[%s%p]', ' ')
         t.desc = vim.fn.toupper(desc:sub(1, 1)) .. desc:sub(2)
         t.width = vim.fn.strchars(t.desc)
         width_max = math.max(width_max, t.width)
      end
      table.sort(data, function(a, b) return a.desc < b.desc end)

      for _, t in ipairs(data) do
         table.insert(lines, string.format('%s%s │ %s', t.desc, string.rep(' ', width_max - t.width), t.char))
      end
   end

   local action_keys = H.normalize_mappings(picker.opts.mappings, true)
   append_char_data(vim.tbl_filter(function(x) return x.isCustom end, action_keys), 
      'Mappings (custom)'
   )
   append_char_data(vim.tbl_filter(function(x) return not x.is_custom end, action_keys), 
      'Mappings (built-in)'
   )

   -- Manage buffer/window/state
   local bufId_info = picker.buffers.info
   if not H.isValidBuf(bufId_info) then bufId_info = H.create_scratch_buf('info') end
   picker.buffers.info = bufId_info

   H.setBuflines(bufId_info, lines)
   H.setWinbuf(picker.windows.main, bufId_info)
   picker.view_state = 'info'

   local nsId = H.ns_id.headers
   H.clearNamespace(bufId_info, ns_id)
   for _, lnum in ipairs(hl_lines) do
      H.setExtMark(bufId_info, ns_id, lnum - 1, 0, { end_row = lnum, end_col = 0, hl_group = 'MiniPickHeader' })
   end
end

H.pickerGetGeneralInfo = function(picker)
   local hasItems = picker.items ~= nil
   return {
      sourceName = picker.opts.source.name or '---',
      sourceCwd = vim.fn.fnamemodify(picker.opts.source.cwd, ':~') or '---',
      nTotal = hasItems and #picker.items or '-',
      nMatched = hasItems and #picker.matchInds or '-',
      nMarked = hasItems and vim.tbl_count(picker.markedIndsMap) or '-',
      relativeCurrentInd = hasItems and picker.currentInd or '-',
   }
end

H.pickerShowPreview = function(picker)
   local preview = picker.opts.source.preview
   local item = H.pickerGetCurrentItem(picker)
   if item == nil then 
      return 
   end

   local winId, bufId = picker.windows.main, H.createScratchBuf('preview')
   vim.bo[bufId].bufhidden = 'wipe'
   H.setWinbuf(winId, bufId)
   preview(bufId, item)
   picker.buffers.preview = bufId
   picker.viewState = 'preview'
end

H.pickerSetBordertext = function(picker)
   local opts = picker.opts
   local winId = picker.windows.main
   if not H.isValidWin(winId) then return end

   -- Compute main text managing views separately and truncating from left
   local view_state, win_width = picker.view_state, vim.api.nvim_win_get_width(winId)
   local config
   if view_state == 'main' then
      local caret, query = picker.caret, picker.query
      local promptPrefix, promptCaret = opts.window.promptPrefix, opts.window.promptCaret
      local maxWidth = math.max(1, 
         winWidth - vim.fn.strchars(promptPrefix) - vim.fn.strchars(promptCaret)
      )

      -- Try to put caret in the center if there is not enough room to show the
      -- whole query (as in 'mini.tabline'). Do that after concatenating query
      -- parts as (after `set_picker_query()`) they can have multiple characters.
      local before_caret = table.concat(vim.list_slice(query, 1, caret - 1))
      local after_caret = table.concat(vim.list_slice(query, caret, #query))
      local w_before, w_after = vim.fn.strchars(before_caret), vim.fn.strchars(after_caret)

      local w_right = math.min(math.floor(0.5 * max_width), w_after)
      local w_left = math.min(math.max(max_width - w_right, 0), w_before)
      w_right = math.min(math.max(max_width - w_left, 0), w_after)

      -- Show standard "there is more" padding symbols if needed
      local pad_left, pad_right = w_left == w_before and '' or '…', w_right == w_after and '' or '…'
      w_left, w_right = w_left - (pad_left == '' and 0 or 1), w_right - (pad_right == '' and 0 or 1)

      before_caret = vim.fn.strcharpart(before_caret, w_before - w_left, w_left)
      after_caret = vim.fn.strcharpart(after_caret, 0, w_right)

      local prompt = { { prompt_prefix, 'MiniPickPromptPrefix' }, { prompt_caret, 'MiniPickPromptCaret' } }
      if after_caret ~= '' then table.insert(prompt, 3, { after_caret .. pad_right, 'MiniPickPrompt' }) end
      if before_caret ~= '' then table.insert(prompt, 2, { pad_left .. before_caret, 'MiniPickPrompt' }) end
      config = { title = prompt }
   end

   local hasItems = picker.items ~= nil
   if view_state == 'preview' and hasItems then
      local stritem_cur = picker.stritems[picker.matchInds[picker.currentInd]] or ''
      -- Sanitize title
      stritem_cur = stritem_cur:gsub('%z', '│'):gsub('%s', ' ')
      config = { title = { { H.fitToWidth(' ' .. stritem_cur .. ' ', win_width), 'MiniPickBorderText' } } }
   end

   if view_state == 'info' then
      config = { title = { { H.fitToWidth(' Info ', win_width), 'MiniPickBorderText' } } }
   end

   -- Compute helper footer only if Neovim version permits and not in busy
   -- picker (otherwise it will flicker number of matches data on char delete)
   local neovimHasWindowFooter = vim.fn.has('nvim-0.10') == 1
   if neovimHasWindowFooter and not picker.isBusy then
      config.footer, config.footerPos = H.pickerComputeFooter(picker, winId), 'left'
   end

   -- Respect `options.content_from_bottom`
   if neovimHasWindowFooter and opts.options.contentFromBottom then
      config.title, config.footer = config.footer, config.title
   end

   vim.api.nvim_win_set_config(winId, config)
   vim.wo[winId].list = true
end

H.pickerComputeFooter = function(picker, winId)
   local info = H.pickerGetGeneralInfo(picker)
   local sourceName = string.format(' %s ', info.source_name):gsub('[%z%s]', ' ')
   local nMarkedText = info.n_marked == 0 and '' or (info.n_marked .. '/')
   local inds = string.format(' %s|%s|%s%s ', info.relativeCurrentInd, 
         info.n_matched, n_marked_text, info.n_total
   )
   local winWidth, sourceWidth, indsWidth =
      vim.api.nvim_win_get_width(winId), vim.fn.strchars(source_name), vim.fn.strchars(inds)

   local footer = { { H.fitToWidth(source_name, win_width), 'MiniPickBorderText' } }
   local nSpacesBetween = winWidth - (sourceWidth + indsWidth)
   if nSpacesBetween > 0 then
      local borderHl = picker.isBusy and 'MiniPickBorderBusy' or 'MiniPickBorder'
      footer[2] = { H.winGetBottomBorder(winId):rep(nSpacesBetween), borderHl }
      footer[3] = { inds, 'MiniPickBorderText' }
   end
   return footer
end

H.pickerStop = function(picker, abort)
   vim.tbl_map(function(timer) pcall(vim.loop.timer_stop, timer) end, H.timers)

   -- Show cursor (work around `guicursor=''` actually leaving cursor hidden)
   if H.cache.guicursor == '' then vim.cmd('set guicursor=a: | redraw') end
   pcall(function() vim.o.guicursor = H.cache.guicursor end)

   if picker == nil then return end

   vim.api.nvim_exec_autocmds('User', { pattern = 'MiniPickStop' })

   if abort then
      H.pickers = {}
   else
      local newLatest = vim.deepcopy(picker)
      H.pickerFree(H.pickers.latest)
      H.pickers = { active = nil, latest = new_latest }
   end

   H.setCurrwin(picker.windows.target)
   pcall(vim.api.nvim_win_close, picker.windows.main, true)
   pcall(vim.api.nvim_buf_delete, picker.buffers.main, { force = true })
   pcall(vim.api.nvim_buf_delete, picker.buffers.info, { force = true })
   picker.windows, picker.buffers = {}, {}

   H.querytick = H.querytick + 1
end

H.pickerFree = function(picker)
   if picker == nil then return end
   picker.matchInds = nil
   picker.shownInds = {}
   picker.cache = nil
   picker.stritems, picker.stritemsIgnorecase, picker.markedIndsMap = nil, nil, nil
   picker.items = nil
   picker = nil
   vim.schedule(function() collectgarbage('collect') end)
end


--}}}
--{{{built-in pickers

--- Table with built-in pickers
MiniPick.builtin = {}

--- Pick from files
---
--- Lists all files recursively in all subdirectories. Tries to use one of the
--- CLI tools to create items (see |MiniPick-cli-tools|): `rg`, `fd`, `git`.
--- If none is present, uses fallback which utilizes |vim.fs.dir()|.
---
--- To customize CLI tool search, either use tool's global configuration approach
--- or directly |MiniPick.builtin.cli()| with specific command.
MiniPick.builtin.files = function(localOpts, opts)
   localOpts = vim.tbl_deep_extend('force', { tool = nil }, localOpts or {})
   local tool = localOpts.tool or H.filesGetTool()
   local show = H.get_config().source.show or H.show_with_icons
   local defaultOpts = { source = { name = string.format('Files (%s)', tool), show = show } }
   opts = vim.tbl_deep_extend('force', defaultOpts, opts or {})

   if tool == 'fallback' then
      local cwd = H.fullPath(opts.source.cwd or vim.fn.getcwd())
      opts.source.items = function() H.files_fallback_items(cwd) end
      return MiniPick.start(opts)
   end

   return MiniPick.builtin.cli({ command = H.filesGetCommand(tool) }, opts)
end

--- Pick from pattern matches
---
--- Lists all pattern matches recursively in all subdirectories.
--- Tries to use one of the CLI tools to create items (see |MiniPick-cli-tools|):
--- `rg`, `git`. If none is present, uses fallback which utilizes |vim.fs.dir()| and
--- Lua pattern matches (NOT recommended in large directories).
---
--- To customize CLI tool search, either use tool's global configuration approach
--- or directly |MiniPick.builtin.cli()| with specific command.
MiniPick.builtin.grep = function(localOpts, opts)
   localOpts = vim.tbl_extend('force', { tool = nil, pattern = nil, globs = {} }, localOpts or {})
   local tool = localOpts.tool or H.grepGetTool()
   local globs = H.is_array_of(localOpts.globs, 'string') and localOpts.globs or {}
   local name_suffix = #globs == 0 and '' or (' | ' .. table.concat(globs, ', '))
   local show = H.getConfig().source.show or H.showWithIcons
   local defaultOps = { source = { name = string.format('Grep (%s%s)', tool, name_suffix), show = show } }
   opts = vim.tbl_deep_extend('force', defaultOps, opts or {})

   local pattern = type(localOpts.pattern) == 'string' and localOpts.pattern 
      or vim.fn.input('Grep pattern: ')
   if tool == 'fallback' then
      local cwd = H.fullPath(opts.source.cwd or vim.fn.getcwd())
      opts.source.items = function() H.grepFallbackItems(pattern, cwd) end
      return MiniPick.start(opts)
   end

   return MiniPick.builtin.cli({ command = H.grep_get_command(tool, pattern, globs) }, opts)
end

--- Pick from pattern matches with live feedback
---
--- Perform pattern matching treating prompt as pattern. Gives live feedback on
--- which matches are found. Use |MiniPick-actions-refine| to revert to regular
--- matching. Use `<C-o>` to restrict search to files matching glob patterns.
--- Tries to use one of the CLI tools to create items (see |MiniPick-cli-tools|):
--- `rg`, `git`. If none is present, error is thrown (for performance reasons).
---
--- To customize search, use tool's global configuration approach.
MiniPick.builtin.grepLive = function(localOpts, opts)
   localOpts = vim.tbl_extend('force', { tool = nil, globs = {} }, localOpts or {})
   local tool = localOpts.tool or H.grep_get_tool()
   if tool == 'fallback' or not H.isExecutable(tool) then 
      H.error('`grepLive` needs non-fallback executable tool.') 
   end

   local globs = H.is_array_of(localOpts.globs, 'string') and localOpts.globs or {}
   local name_suffix = #globs == 0 and '' or (' | ' .. table.concat(globs, ', '))
   local show = H.get_config().source.show or H.show_with_icons
   local default_source = {
      name = string.format('Grep live (%s%s)', tool, name_suffix), show = show
   }
   opts = vim.tbl_deep_extend('force', { source = default_source }, opts or {})

   local cwd = H.fullPath(opts.source.cwd or vim.fn.getcwd())
   local set_items_opts, spawnOpts = { doMatch = false, querytick = H.querytick }, { cwd = cwd }
   local process
   local match = function(_, _, query)
      pcall(vim.loop.process_kill, process)
      if H.querytick == set_items_opts.querytick then return end
      if #query == 0 then return MiniPick.setPickerItems({}, set_items_opts) end

      set_items_opts.querytick = H.querytick
      local command = H.grepGetCommand(tool, table.concat(query), globs)
      process = MiniPick.setPickerItemsFromCli(command, { set_items_opts = set_items_opts, spawnOpts = spawnOpts })
   end

   local addGlob = function()
      local ok, glob = pcall(vim.fn.input, 'Glob pattern: ')
      if ok then table.insert(globs, glob) end
      name_suffix = #globs == 0 and '' or (' | ' .. table.concat(globs, ', '))
      MiniPick.setPickerOpts({ source = { name = string.format('Grep live (%s%s)', tool, name_suffix) } })
      MiniPick.setPickerQuery(MiniPick.getPickerQuery())
   end
   local mappings = { addGlob = { char = '<C-o>', func = addGlob } }

   opts = vim.tbl_deep_extend(
      'force', 
      opts or {},
      { source = { items = {}, match = match }, mappings = mappings }
   )
   return MiniPick.start(opts)
end

--- Pick from help tags
---
--- Notes:
--- - On choose directly executes |:help| command with appropriate modifier
---    (none, |:vertical|, |:tab|). This is done through custom mappings named
---    `show_helpIn{split,vsplit,tab}`. Not `chooseIn{split,vsplit,tab}` because
---    there is no split guarantee (like if there is already help window opened).
MiniPick.builtin.help = function(localOpts, opts)
   localOpts = vim.tbl_deep_extend('force', { default_split = 'horizontal' }, localOpts or {})
   local defaultModifier = 
      ({ horizontal = '', vertical = 'vert ', tab = 'tab ' })[localOpts.default_split]
   if default_modifier == nil then 
      H.error('`opts.default_split` should be one of "horizontal", "vertical", "tab"') 
   end

   -- Get all tags
   local helpBuf = vim.api.nvim_create_buf(false, true)
   vim.bo[helpBuf].buftype = 'help'
   -- - NOTE: no dedicated buffer name because it is immediately wiped out
   local tags = vim.api.nvim_buf_call(helpBuf, function() return vim.fn.taglist('.*') end)
   vim.api.nvim_buf_delete(helpBuf, { force = true })
   vim.tbl_map(function(t) t.text = t.name end, tags)

   -- NOTE: Choosing is done on next event loop to properly overcome special
   -- nature of `:help {subject}` command. For example, it didn't quite work
   -- when choosing tags in same file consecutively.
   local chooser = function(item, modifier)
      if item == nil then return end
      vim.schedule(function() vim.cmd((modifier or default_modifier) .. 'help ' .. (item.name or '')) end)
   end
   local preview = function(bufId, item)
      -- Take advantage of `taglist` output on how to open tag
      vim.api.nvim_buf_call(bufId, function()
         vim.cmd('noautocmd edit ' .. vim.fn.fnameescape(item.filename))
         vim.bo.buftype, vim.bo.buflisted, vim.bo.bufhidden = 'nofile', false, 'wipe'
         vim.bo.syntax = 'help'

         local cache_hlsearch = vim.v.hlsearch
         -- Make a "very nomagic" search to account for special characters in tag
         local search_cmd = string.gsub(item.cmd, '^/', '/\\V')
         vim.cmd('silent keeppatterns ' .. search_cmd)
         -- Here `vim.v` doesn't work: https://github.com/neovim/neovim/issues/25294
         vim.cmd('let v:hlsearch=' .. cache_hlsearch)
         vim.cmd('normal! zt')
      end)
   end

   -- Modify default mappings to work with special `:help` command
   local mapCustom = function(char, modifier)
      local f = function()
         chooser(MiniPick.getPickerMatches().current, modifier)
         return true
      end
      return { char = char, func = f }
   end

   local configMappings = H.getConfig().mappings
   --stylua: ignore
   local mappings = {
      chooseInSplit    = '',
      showHelpInSplit  = map_custom(config_mappings.chooseInSplit, ''),
      chooseInVsplit   = '',
      showHelpInVsplit = map_custom(config_mappings.chooseInVsplit, 'vertical '),
      chooseInTabpage = '',
      showHelpInTabpage = map_custom(configMappings.chooseInTabpage, 'tab ')
   }

   local source = { items = tags, name = 'Help', choose = choose, preview = preview }
   opts = vim.tbl_deep_extend('force', { source = source, mappings = mappings }, opts or {})
   return MiniPick.start(opts)
end

--- Pick from buffers
MiniPick.builtin.buffers = function(localOpts, opts)
   localOpts = vim.tbl_deep_extend(
      'force', 
      { includeCurrent = true, includeUnlisted = false }, 
      localOpts or {}
   )

   local buffers_output =
      vim.api.nvim_exec('buffers' .. (localOpts.include_unlisted and '!' or ''), true)
   local currBufId, includeCurrent = vim.api.nvim_get_current_buf(), localOpts.includeCurrent
   local items = {}
   for _, l in ipairs(vim.split(buffers_output, '\n')) do
      local buf_str, name = l:match('^%s*%d+'), l:match('"(.*)"')
      local bufId = tonumber(buf_str)
      local item = { text = name, bufnr = bufId }
      if bufId ~= currBufId or includeCurrent then table.insert(items, item) end
   end

   local show = H.get_config().source.show or H.show_with_icons
   local defaultOps = { source = { name = 'Buffers', show = show } }
   opts = vim.tbl_deep_extend('force', defaultOps, opts or {}, { source = { items = items } })
   return MiniPick.start(opts)
end

--- Pick from CLI output
---
--- Executes command line tool and constructs items based on its output.
--- Uses |MiniPick.setPickerItemsFromCli()|.
---
--- Example: `MiniPick.builtin.cli({ command = { 'echo', 'a\nb\nc' } })`
---
MiniPick.builtin.cli = function(localOpts, opts)
   localOpts = vim.tbl_deep_extend('force', { command = {}, postprocess = nil, spawnOpts = {} }, localOpts or {})
   local name = string.format('CLI (%s)', tostring(localOpts.command[1] or ''))
   opts = vim.tbl_deep_extend('force', { source = { name = name } }, opts or {})
   -- Explicitly use full path to not conflict with `setPickerItemsFromCli`
   -- behavior of treating `spawnOpts.cwd` relative to source's cwd
   localOpts.spawnOpts.cwd = H.fullPath(localOpts.spawnOpts.cwd or opts.source.cwd or vim.fn.getcwd())

   local command = localOpts.command
   local set_from_cli_opts = { postprocess = localOpts.postprocess, spawnOpts = localOpts.spawnOpts }
   opts.source.items = vim.schedule_wrap(
      function() MiniPick.setPickerItemsFromCli(command, set_from_cli_opts) end
   )
   return MiniPick.start(opts)
end

--- Resume latest picker
MiniPick.builtin.resume = function()
   local picker = H.pickers.latest
   if picker == nil then H.error('There is no picker to resume.') end

   H.cache = {}
   local bufId = H.pickerNewBuf()
   local winTarget = vim.api.nvim_get_current_win()
   local winId = H.pickerNewWin(bufId, picker.opts.window.config, picker.opts.source.cwd)
   picker.buffers = { main = bufId }
   picker.windows = { main = winId, target = winTarget }
   picker.view_state = 'main'
   H.pickers.active = picker

   return H.pickerAdvance(picker)
end

--- Picker registry
---
--- Place for users and extensions to manage pickers with their commonly used
--- local options. By default contains all |MiniPick.builtin| pickers.
--- All entries should accept only a single `localOpts` table argument.
MiniPick.registry = {}

for name, f in pairs(MiniPick.builtin) do
   MiniPick.registry[name] = function(localOpts) return f(localOpts) end
end

--- Get items of active picker
MiniPick.getPickerItems = function() return vim.deepcopy((H.pickers.active or {}).items) end

--- Get stritems of active picker
MiniPick.getPickerStritems = function() return vim.deepcopy((H.pickers.active or {}).stritems) end

--- Get matches of active picker
MiniPick.getPickerMatches = function()
   if not MiniPick.isPickerActive() then return end
   local picker = H.pickers.active
   local items = picker.items
   if items == nil or #items == 0 then return {} end

   local matchInds = vim.deepcopy(picker.matchInds)
   local res = { all_inds = matchInds, currentInd = matchInds[picker.currentInd] }
   res.all = vim.tbl_map(function(ind) return items[ind] end, matchInds)
   res.current = picker.items[res.currentInd]
   local marked_inds = vim.tbl_keys(picker.marked_inds_map)
   table.sort(marked_inds)
   res.marked_inds, res.marked = marked_inds,
         vim.tbl_map(function(ind) return items[ind] end, marked_inds)
   res.shown_inds = vim.tbl_map(function(ind) return matchInds[ind] end, picker.shown_inds)
   res.shown = vim.tbl_map(function(ind) return items[ind] end, res.shown_inds)
   return res
end

--- Get config of active picker
---
---@return table|nil Picker config (`start()`'s input `opts` table) or `nil` if
---    no active picker.
MiniPick.getPickerOpts = function() return vim.deepcopy((H.pickers.active or {}).opts) end

--- Get state data of active picker
MiniPick.getPickerState = function()
   if not MiniPick.isPickerActive() then return end
   local picker = H.pickers.active
   --stylua: ignore
   return vim.deepcopy({
      buffers = picker.buffers, windows = picker.windows, caret = picker.caret, is_busy = picker.is_busy
   })
end

--- Get query of active picker
---
---@return table|nil Array of picker query or `nil` if no active picker.
MiniPick.getPickerQuery = function() return vim.deepcopy((H.pickers.active or {}).query) end

--- Set items for active picker
--- Note: sets items asynchronously in non-blocking fashion.
MiniPick.setPickerItems = function(items, opts)
   if not H.islist(items) then H.error('`items` should be an array.') end
   if not MiniPick.isPickerActive() then return end
   opts = vim.tbl_deep_extend('force', { doMatch = true, querytick = nil }, opts or {})

   -- Set items in async because computing lower `stritems` can block much time
   coroutine.wrap(H.pickerSetItems)(H.pickers.active, items, opts)
end

--- Set items for active picker based on CLI output
---
--- Asynchronously executes `command` and sets items to its postprocessed output.
---
MiniPick.setPickerItemsFromCli = function(command, opts)
   if not MiniPick.isPickerActive() then return end
   local isValidCommand = H.isArrayOf(command, 'string') and #command >= 1
   if not isValidCommand then 
      H.error('`command` should be an array of strings.') 
   end
   local defaultOps = { postprocess = H.cliPostprocess, setItemsOpts = {}, spawnOpts = {} }
   opts = vim.tbl_deep_extend('force', defaultOps, opts or {})

   local executable, args = command[1], vim.list_slice(command, 2, #command)
   local process, pid, stdout = nil, nil, vim.loop.new_pipe()
   local spawnOpts = vim.tbl_deep_extend('force',
      opts.spawnOpts, { args = args, stdio = { nil, stdout, nil } }
   )
   if type(spawnOpts.cwd) == 'string' then spawnOpts.cwd = H.fullPath(spawnOpts.cwd) end
   process, pid = vim.loop.spawn(executable, spawnOpts, function()
      if process:is_active() then process:close() end
   end)

   -- Make sure to stop the process if picker is stopped
   local killProcess = function() pcall(vim.loop.process_kill, process) end
   vim.api.nvim_create_autocmd('User',
      { pattern = 'MiniPickStop', once = true, callback = killProcess }
   )

   local dataFeed = {}
   stdout:read_start(function(err, data)
      assert(not err, err)
      if data ~= nil then return table.insert(dataFeed, data) end

      local items = vim.split(table.concat(dataFeed), '\r?\n')
      dataFeed = nil
      stdout:close()
      vim.schedule(
         function() MiniPick.setPickerItems(opts.postprocess(items), opts.setItemsOpts) end
      )
   end)

   return process, pid
end

--- Set match indices for active picker
---
--- There are two intended use cases:
--- - Inside custom asynchronous |MiniPick-source.match| function to set which of
---    picker's stritems match the query. See |MiniPick.pokeIsPickerActive()|.
--- - To programmatically set current match and marked items.
MiniPick.setPickerMatchInds = function(matchInds, matchType)
   if not MiniPick.isPickerActive() then return end
   if not H.isArrayOf(matchInds, 'number') then 
      H.error('`matchInds` should be an array of numbers.') 
   end
   local set = H.pickerSetInds[matchType or 'all']
   if set == nil then H.error('`matchType` should be one of "all", "marked", "current"') end
   set(H.pickers.active, matchInds)
   H.pickerUpdate(H.pickers.active, false)
end

--- Set config for active picker
---
---@param opts table Table overriding initial `opts` input of |MiniPick.start()|.
MiniPick.setPickerOpts = function(opts)
   if not MiniPick.isPickerActive() then 
      return 
   end
   local picker, currCwd = H.pickers.active, H.pickers.active.opts.source.cwd
   picker.opts = vim.tbl_deep_extend('force', picker.opts, opts or {})
   picker.actionKeys = H.normalizeMappings(picker.opts.mappings)
   if currCwd ~= picker.opts.source.cwd then 
      H.winSetCwd(picker.windows.main, picker.opts.source.cwd) 
   end
   H.pickerUpdate(picker, true, true)
end

--- Set target window for active picker
---
---@param winId number Valid window identifier to be used as the new target window.
---
---@seealso |MiniPick.getPickerState()|
MiniPick.setPickerTargetWindow = function(winId)
   if not MiniPick.isPickerActive() then return end
   if not H.isValidWin(winId) 
      then H.error('`winId` is not a valid window identifier.') 
   end
   H.pickers.active.windows.target = winId
end

--- Set query for active picker
---
---@param query table Array of strings to be set as the new picker query.
MiniPick.setPickerQuery = function(query)
   if not MiniPick.isPickerActive() then return end
   if not H.isArrayOf(query, 'string') then H.error('`query` should be an array of strings.') end

   H.pickers.active.query, H.pickers.active.caret = vim.deepcopy(query), #query + 1
   H.querytick = H.querytick + 1
   H.pickers.active.matchInds = H.seqAlong(MiniPick.getPickerItems())
   H.pickerUpdate(H.pickers.active, true)
end

--- Get query tick
---
--- Query tick is a unique query identifier. Intended to be used to detect user
--- activity during and between |MiniPick.start()| calls for efficient non-blocking
--- functionality. Updates after any query change, picker start and stop.
MiniPick.getQuerytick = function() return H.querytick end

--- Check if there is an active picker
MiniPick.isPickerActive = function() return H.pickers.active ~= nil end

--- Poke if picker is active
---
--- Intended to be used for non-blocking implementation of source methods.
--- Returns an output of |MiniPick.isPickerActive()|, but depending on
--- whether there is a coroutine running:
--- - If no, return it immediately.
--- - If yes, return it after `coroutine.yield()` with `coroutine.resume()`
---    called "soon" by the main event-loop (see |vim.schedule()|).
---
MiniPick.pokeIsPickerActive = function()
   local co = coroutine.running()
   if co == nil then return MiniPick.isPickerActive() end
   H.scheduleResumeIsActive(co)
   return coroutine.yield()
end

--}}}
--{{{helper data

-- Module default config
H.defaultConfig = vim.deepcopy(MiniPick.config)

-- Namespaces
H.nsId = {
   matches = vim.api.nvim_create_namespace('MiniPickMatches'),
   headers = vim.api.nvim_create_namespace('MiniPickHeaders'),
   preview = vim.api.nvim_create_namespace('MiniPickPreview'),
   ranges = vim.api.nvim_create_namespace('MiniPickRanges'),
}

-- Timers
H.timers = {
   busy = vim.loop.new_timer(),
   focus = vim.loop.new_timer(),
   getcharstr = vim.loop.new_timer(),
}

-- Pickers
H.pickers = { active = nil, latest = nil }

-- Picker-independent counter of query updates
H.querytick = 0

-- General purpose cache
H.cache = {}

-- Helper functionality =======================================================
-- Settings -------------------------------------------------------------------
H.setupConfig = function(config)
   H.checkType('config', config, 'table', true)
   config = vim.tbl_deep_extend('force', vim.deepcopy(H.defaultConfig), config or {})

   H.checkType('delay', config.delay, 'table')
   H.checkType('delay.async', config.delay.async, 'number')
   H.checkType('delay.busy', config.delay.busy, 'number')

   H.checkType('mappings', config.mappings, 'table')
   H.checkType('mappings.caretLeft', config.mappings.caretLeft, 'string')
   H.checkType('mappings.caretRight', config.mappings.caretRight, 'string')
   H.checkType('mappings.chooser', config.mappings.chooser, 'string')
   H.checkType('mappings.chooseInSplit', config.mappings.chooseInSplit, 'string')
   H.checkType('mappings.chooseInTabpage', config.mappings.chooseInTabpage, 'string')
   H.checkType('mappings.chooseInVsplit', config.mappings.chooseInVsplit, 'string')
   H.checkType('mappings.chooseMarked', config.mappings.chooseMarked, 'string')
   H.checkType('mappings.deleteChar', config.mappings.deleteChar, 'string')
   H.checkType('mappings.deleteCharRight', config.mappings.deleteCharRight, 'string')
   H.checkType('mappings.deleteLeft', config.mappings.deleteLeft, 'string')
   H.checkType('mappings.deleteWord', config.mappings.deleteWord, 'string')
   H.checkType('mappings.mark', config.mappings.mark, 'string')
   H.checkType('mappings.markAll', config.mappings.markAll, 'string')
   H.checkType('mappings.moveDown', config.mappings.moveDown, 'string')
   H.checkType('mappings.moveStart', config.mappings.moveStart, 'string')
   H.checkType('mappings.moveUp', config.mappings.moveUp, 'string')
   H.checkType('mappings.paste', config.mappings.paste, 'string')
   H.checkType('mappings.refine', config.mappings.refine, 'string')
   H.checkType('mappings.refineMarked', config.mappings.refineMarked, 'string')
   H.checkType('mappings.scrollDown', config.mappings.scrollDown, 'string')
   H.checkType('mappings.scrollUp', config.mappings.scrollUp, 'string')
   H.checkType('mappings.scrollLeft', config.mappings.scrollLeft, 'string')
   H.checkType('mappings.scrollRight', config.mappings.scrollRight, 'string')
   H.checkType('mappings.stop', config.mappings.stop, 'string')
   H.checkType('mappings.toggleInfo', config.mappings.toggleInfo, 'string')
   H.checkType('mappings.togglePreview', config.mappings.togglePreview, 'string')

   H.checkType('options', config.options, 'table')
   H.checkType('options.contentFromBottom', config.options.contentFromBottom, 'boolean')
   H.checkType('options.useCache', config.options.useCache, 'boolean')

   H.checkType('source', config.source, 'table')
   H.checkType('source.items', config.source.items, 'table', true)
   H.checkType('source.name', config.source.name, 'string', true)
   H.checkType('source.cwd', config.source.cwd, 'string', true)
   H.checkType('source.match', config.source.match, 'function', true)
   H.checkType('source.show', config.source.show, 'function', true)
   H.checkType('source.preview', config.source.preview, 'function', true)
   H.checkType('source.choose', config.source.choose, 'function', true)
   H.checkType('source.chooseMarked', config.source.chooseMarked, 'function', true)

   H.checkType('window', config.window, 'table')
   
   local isTableOrCallable = function(x) 
      return x == nil or type(x) == 'table' or vim.is_callable(x) 
   end
   if not isTableOrCallable(config.window.config) then
      H.error('`window.config` should be table or callable, not ' .. type(config.window.config))
   end
   
   -- TODO: Remove after releasing 'mini.nvim' 0.16.0
   if config.window.promptCursor ~= nil then
      local msg = '`promptCursor` in `config.window` is renamed to `promptCaret` for better naming'
         .. ' consistency.'
         .. ' It works for now, but will stop in the next release. Sorry for the inconvenience.'
      H.notify(msg, 'WARN')
      config.window.promptCaret = config.window.promptCursor
      config.window.promptCursor = nil
   end
   H.checkType('window.promptCaret', config.window.promptCaret, 'string')
   H.checkType('window.promptPrefix', config.window.promptPrefix, 'string')

   return config
end

H.applyConfig = function(config)
   MiniPick.config = config

   -- Register 'mini.extra' pickers
   if type(_G.MiniExtra) == 'table' then
      for name, f in pairs(_G.MiniExtra.pickers) do
         MiniPick.registry[name] = MiniPick.registry[name] 
               or function(localOpts) return f(localOpts) end
      end
   end
end

H.getConfig = function(config)
   return vim.tbl_deep_extend('force', MiniPick.config, vim.b.minipickConfig or {}, config or {})
end

H.createAutocommands = function()
   local gr = vim.api.nvim_create_augroup('MiniPick', {})

   local au = function(event, pattern, callback, desc)
      vim.api.nvim_create_autocmd(
         event, { group = gr, pattern = pattern, callback = callback, desc = desc }
      )
   end

   au('VimResized', '*', MiniPick.refresh, 'Refresh on resize')
   au('ColorScheme', '*', H.createDefaultHighlighting, 'Ensure colors')
end

H.createDefaultHighlighting = function()
   local hi = function(name, opts)
      opts.default = true
      vim.api.nvim_set_hl(0, name, opts)
   end

   hi('MiniPickBorder',          { link = 'FloatBorder' })
   hi('MiniPickBorderBusy',      { link = 'DiagnosticFloatingWarn' })
   hi('MiniPickBorderText',      { link = 'FloatTitle' })
   hi('MiniPickCursor',          { blend = 100, nocombine = true })
   hi('MiniPickIconDirectory',   { link = 'Directory' })
   hi('MiniPickIconFile',        { link = 'MiniPickNormal' })
   hi('MiniPickHeader',          { link = 'DiagnosticFloatingHint' })
   hi('MiniPickMatchCurrent',    { link = 'CursorLine' })
   hi('MiniPickMatchMarked',     { link = 'Visual' })
   hi('MiniPickMatchRanges',     { link = 'DiagnosticFloatingHint' })
   hi('MiniPickNormal',          { link = 'NormalFloat' })
   hi('MiniPickPreviewLine',     { link = 'CursorLine' })
   hi('MiniPickPreviewRegion',   { link = 'IncSearch' })
   hi('MiniPickPrompt',          { link = 'DiagnosticFloatingInfo' })
   hi('MiniPickPromptCaret',     { link = 'MiniPickPrompt' })
   hi('MiniPickPromptPrefix',    { link = 'MiniPickPrompt' })
end

H.createUserCommands = function()
   local callback = function(input)
      local name, localOpts = H.commandParseFargs(input.fargs)
      local f = MiniPick.registry[name]
      if f == nil then 
         H.error(string.format('There is no picker named "%s" in registry.', name))
      end
      f(localOpts)
   end
   local opts = { 
      nargs = '+', complete = H.commandComplete, desc = "Pick from 'mini.pick' registry" 
   }
   vim.api.nvim_create_user_command('Pick', callback, opts)
end

--}}}
--{{{command

-- Command --------------------------------------------------------------------
H.commandParseFargs = function(fargs)
   local name, optsParts = fargs[1], vim.tbl_map(H.expandcmd, vim.list_slice(fargs, 2, #fargs))
   local tblString = string.format('{ %s }', table.concat(optsParts, ', '))
   local luaLoad = loadstring('return ' .. tblString)
   if luaLoad == nil then 
      H.error('Could not convert extra command arguments to table: ' .. tblString)
   end
   return name, lua_load()
end

H.commandComplete = function(_, line, col)
   local prefixFrom, prefixTo, prefix = string.find(line, '^%S+%s+(%S*)')
   if col < prefixFrom or prefixTo < col then return {} end
   local candidates = vim.tbl_filter(
      function(x) return tostring(x):find(prefix, 1, true) ~= nil end,
      vim.tbl_keys(MiniPick.registry)
   )
   table.sort(candidates)
   return candidates
end


H.itemToString = function(item)
   item = H.expandCallable(item)
   if type(item) == 'string' then return item end
   if type(item) == 'table' and type(item.text) == 'string' then return item.text end
   return vim.inspect(item, { newline = ' ', indent = '' })
end

H.queryIsIgnorecase = function(query)
   if not vim.o.ignorecase then return false end
   if not vim.o.smartcase then return true end
   local prompt = table.concat(query)
   return prompt == vim.fn.tolower(prompt)
end

H.normalizeMappings = function(mappings, skipAlternatives)
   local res = {}
   local addToRes = function(char, data)
      local key = H.replaceTermcodes(char)
      -- Omit disabled keys and prefer custom actions over built-ins
      if (key == nil or key == '') or (res[key] ~= nil and res[key].isCustom) then 
         return
      end
      res[key] = data
   end

   -- Use alternative keys for some common actions
   local altChars = {}
   if not skipAlternatives then 
      altChars = { moveDown = '<Down>', moveStart = '<Home>', moveUp = '<Up>' } 
   end

   -- Process
   for name, rhs in pairs(mappings) do
      local isCustom = type(rhs) == 'table'
      local char = isCustom and rhs.char or rhs
      local data = { 
         char = char, 
         name = name, func = isCustom and rhs.func or H.actions[name], 
         isCustom = isCustom 
      }
      addToRes(char, data)
      addToRes(altChars[name], data)
   end

   return res
end

H.actions = {
   caretLeft   = function(picker, _) H.pickerMoveCaret(picker, -1) end,
   caretRight = function(picker, _) H.pickerMoveCaret(picker, 1)   end,

   choose = function(picker, _) return H.pickerChoose(picker, nil)         end,
   chooseInSplit = function(picker, _) return H.pickerChoose(picker, 'split')   end,
   chooseInTabpage = function(picker, _) return H.pickerchoose(picker, 'tab split') end,
   chooseInVsplit = function(picker, _) return H.pickerChoose(picker, 'vsplit') end,
   chooseMarked = function(picker, _)
      local ok, res = pcall(picker.opts.source.chooseMarked, MiniPick.getPickerMatches().marked)
      if not ok then 
         vim.schedule(function() H.error('Error during choose marked:\n' .. res) end) 
      end
      return not (ok and res)
   end,

   deleteChar = function(picker, _) 
      H.pickerQueryDelete(picker, 1)                        
   end,
   deleteCharRight = function(picker, _) 
      H.pickerQueryDelete(picker, 0)                        
   end,
   deleteLeft = function(picker, _) 
      H.pickerQueryDelete(picker, picker.caret - 1) 
   end,
   deleteWord = function(picker, _)
      local init, nDel = picker.caret - 1, 0
      if init == 0 then return end
      local refIsKeyword = vim.fn.match(picker.query[init], '[[:keyword:]]') >= 0
      for i = init, 1, -1 do
         local curIsKeyword = vim.fn.match(picker.query[i], '[[:keyword:]]') >= 0
         if (refIsKeyword and not curIsKeyword) or (not refIsKeyword and curIsKeyword) then
            break
         end
         nDel = nDel + 1
      end
      H.pickerQueryDelete(picker, nDel)
   end,

   mark    = function(picker, _) H.pickerMarkIndexes(picker, 'current') end,
   markAll = function(picker, _) H.pickerMarkIndexes(picker, 'all') end,

   moveDown  = function(picker, _) H.pickerMoveCurrent(picker, 1)   end,
   moveStart = function(picker, _) H.pickerMoveCurrent(picker, nil, 1)   end,
   moveUp    = function(picker, _) H.pickerMoveCurrent(picker, -1) end,

   paste = function(picker, _)
      local regContents = H.pickergetRegisterContents(picker):gsub('[\n\t]', ' ')
      for i = 1, vim.fn.strchars(regContents) do
         H.pickerQueryAdd(picker, vim.fn.strcharpart(regContents, i - 1, 1))
      end
   end,

   refine            = function(picker, _) H.pickerrefine(picker, 'all') end,
   refineMarked = function(picker, _) H.pickerrefine(picker, 'marked') end,

   scrollDown   = function(picker, _) H.pickerscroll(picker, 'down')   end,
   scrollUp      = function(picker, _) H.pickerscroll(picker, 'up')      end,
   scrollLeft   = function(picker, _) H.pickerscroll(picker, 'left')   end,
   scrollRight = function(picker, _) H.pickerscroll(picker, 'right') end,

   toggleInfo = function(picker, _)
      if picker.viewState == 'info' then return H.pickerShowMain(picker) end
      H.pickerShowInfo(picker)
   end,

   togglePreview = function(picker, _)
      if picker.viewState == 'preview' then return H.pickerShowMain(picker) end
      H.pickershowPreview(picker)
   end,

   stop = function(_, _) return true end,
}

-- Default match --------------------------------------------------------------
H.matchFilter = function(inds, stritems, query)
   -- 'abc' and '*abc' - fuzzy; "'abc" and 'a' - exact substring;
   -- 'ab c' - grouped fuzzy; '^abc' and 'abc$' - exact substring at start/end.
   local isFuzzyForced, isExactPlain, isExactStart, isExactEnd =
      query[1] == '*', query[1] == "'", query[1] == '^', query[#query] == '$'
   local isGrouped, groupedParts = H.matchQueryGroup(query)

   if isFuzzyForced or isExactPlain or isExactStart or isExactEnd then
      local startOffset = (isFuzzyForced or isExactPlain or isExactStart) and 2 or 1
      local endOffset = #query - ((not isFuzzyForced and not isExactPlain and isExactEnd) and 1 or 0)
      query = vim.list_slice(query, startOffset, endOffset)
   elseif isGrouped then
      query = groupedParts
   end

   if #query == 0 then return {}, 'useall', query end

   local isFuzzyPlain = not (isExactPlain or isExactStart or isExactEnd) and #query > 1
   if isFuzzyForced or isFuzzyPlain then 
      return H.matchFilterFuzzy(inds, stritems, query), 'fuzzy', query 
   end

   local prefix = isExactStart and '^' or ''
   local suffix = isExactEnd and '$' or ''
   local pattern = prefix .. vim.pesc(table.concat(query)) .. suffix

   return H.matchFilterExact(inds, stritems, query, pattern), 'exact', query
end

H.matchFilterExact = function(inds, stritems, query, pattern)
   local matchSingle = H.matchFilterExactSingle
   local pokePicker = H.pokePickerThrottle(H.querytick)
   local matchData = {}
   for _, ind in ipairs(inds) do
      if not pokePicker() then return nil end
      local data = matchSingle(stritems[ind], ind, pattern)
      if data ~= nil then table.insert(matchData, data) end
   end

   return matchData
end

H.matchFilterExactSingle = function(candidate, index, pattern)
   local start = string.find(candidate, pattern)
   if start == nil then return nil end

   return { 0, start, index }
end

H.matchRangesExact = function(matchData, query)
   -- All matches have same match ranges relative to match start
   local curStart, relRanges = 0, {}
   for i = 1, #query do
      relRanges[i] = { curStart, curStart + query[i]:len() - 1 }
      currStart = relRanges[i][2] + 1
   end

   local res = {}
   for i = 1, #matchData do
      local start = matchData[i][2]
      res[i] = vim.tbl_map(function(x) return { start + x[1], start + x[2] } end, relRanges)
   end

   return res
end

H.matchFilterFuzzy = function(inds, stritems, query)
   local matchSingle, findQuery = H.matchFilterFuzzySingle, H.matchFindQuery
   local pokePicker = H.pokePickerThrottle(H.querytick)
   local matchData = {}
   for _, ind in ipairs(inds) do
      if not pokePicker() then return nil end
      local data = matchSingle(stritems[ind], ind, query, findQuery)
      if data ~= nil then table.insert(matchData, data) end
   end
   return matchData
end

H.matchFilterFuzzySingle = function(candidate, index, query, findQuery)
   -- Search for query chars match positions with the following properties:
   -- - All are present in `candidate` in the same order.
   -- - Has smallest width among all such match positions.
   -- - Among same width has smallest first match.

   -- Search forward to find matching positions with left-most last char match
   local first, last = findQuery(candidate, query, 1)
   if first == nil then return nil end
   if first == last then return { 0, first, index, { first } } end

   -- NOTE: This approach doesn't iterate **all** query matches. It is fine for
   -- width optimization but maybe not for more (like contiguous groups number).
   -- Example: for query {'a', 'b', 'c'} candidate 'aaxbbbc' will be matched as
   -- having 3 groups (indexes 2, 4, 7) but correct one is 2 groups (2, 6, 7).

   -- Iteratively try to find better matches by advancing last match
   local bestFirst, bestLast, bestWidth = first, last, last - first
   while last do
      local width = last - first
      if width < bestWidth then
         bestFirst, bestLast, bestWidth = first, last, width
      end

      first, last = findQuery(candidate, query, first + 1)
   end

   -- NOTE: No field names is not clear code, but consistently better performant
   return { bestLast - bestFirst, bestFirst, index }
end

H.matchRangesFuzzy = function(matchData, query, stritems)
   local res, nQuery, queryLens = {}, #query, vim.tbl_map(string.len, query)
   for iMatch, data in ipairs(matchData) do
      local s, from, to = stritems[data[3]], data[2], data[2] + queryLens[1] - 1
      local ranges = { { from, to } }
      for jQuery = 2, nQuery do
         from, to = string.find(s, query[jQuery], to + 1, true)
         ranges[jQuery] = { from, to }
      end
      res[iMatch] = ranges
   end
   return res
end

H.matchFindQuery = function(s, query, init)
   local first, to = string.find(s, query[1], init, true)
   if first == nil then return nil, nil end

   -- Both `first` and `last` indicate the start byte of first and last match
   local last = first
   for i = 2, #query do
      last, to = string.find(s, query[i], to + 1, true)
      if not last then return nil, nil end
   end
   return first, last
end

H.matchQueryGroup = function(query)
   local parts = { {} }
   for _, x in ipairs(query) do
      local isWhitespace = x:find('^%s+$') ~= nil
      if isWhitespace then 
         table.insert(parts, {}) 
      else 
         table.insert(parts[#parts], x)
      end
   end
   return #parts > 1, vim.tbl_map(table.concat, parts)
end

H.matchSort = function(matchData)
   -- Spread indexes in width-start buckets
   local buckets, maxWidth, widthMaxStart = {}, 0, {}
   for i = 1, #matchData do
      local data, width, start = matchData[i], matchData[i][1], matchData[i][2]
      local buckWidth = buckets[width] or {}
      local buckStart = buckWidth[start] or {}
      table.insert(buckStart, data[3])
      buckWidth[start] = buckStart
      buckets[width] = buckWidth

      maxWidth = math.max(maxWidth, width)
      widthMaxStart[width] = math.max(widthMaxStart[width] or 0, start)
   end

   -- Sort index in place (to make stable sort) within buckets
   local pokePicker = H.pokePickerThrottle(H.querytick)
   for _, buckWidth in pairs(buckets) do
      for _, buckStart in pairs(buckWidth) do
         if not pokePicker() then return nil end
         table.sort(buckStart)
      end
   end

   -- Gather indexes back in order
   local res = {}
   for width = 0, maxWidth do
      local buckWidth = buckets[width]
      for start = 1, (widthMaxStart[width] or 0) do
         local buckStart = buckWidth[start] or {}
         for i = 1, #buckStart do
            table.insert(res, buckStart[i])
         end
      end
   end

   return res
end

H.matchNoSort = function(matchData)
   return vim.tbl_map(function(x) return x[3] end, matchData)
end

-- Default show ---------------------------------------------------------------
H.getIcon = function(x, icons)
   local itemData = H.parseItem(x)
   local path = itemData.path or itemData.text or ''
   local pathType = H.getFsType(path)
   if pathType == 'none' then return { text = icons.none, hl = 'MiniPickNormal' } end

   -- Prefer 'mini.icons'
   if _G.MiniIcons ~= nil then
      local category = pathType == 'directory' and 'directory' or 'file'
      local icon, hl = _G.MiniIcons.get(category, path)
      return { text = icon .. ' ', hl = hl }
   end

   -- Try falling back to 'nvim-web-devicons'
   if pathType == 'directory' then return { text = icons.directory, hl = 'MiniPickIconDirectory' } end
   local hasDevicons, devicons = pcall(require, 'nvim-web-devicons')
   if not hasDevicons then return { text = icons.file, hl = 'MiniPickIconFile' } end

   local icon, hl = devicons.getIcon(vim.fn.fnamemodify(path, ':t'), nil, { default = false })
   icon = type(icon) == 'string' and (icon .. ' ') or icons.file
   return { text = icon, hl = hl or 'MiniPickIconFile' }
end

H.showWithIcons = function(bufId, items, query) 
   MiniPick.defaultShow(bufId, items, query, { showIcons = true }) 
end

-- Item helpers for default functions
H.parseItem = function(item)
   -- Try parsing table item first
   if type(item) == 'table' then return H.parseItemTable(item) end

   -- Parse item's string representation
   local stritem = H.itemToString(item)

   -- - Buffer
   local ok, numitem = pcall(tonumber, stritem)
   if ok and H.isValidBuf(numitem) then 
      return { type = 'buffer', bufId = numitem } 
   end

   -- File or Directory
   local pathType, path, lnum, col, rest = H.parsePath(stritem)
   if pathType ~= 'none' then 
      return { type = pathType, path = path, lnum = lnum, col = col, text = rest } 
   end

   return {}
end

H.parseItemTable = function(item)
   -- Buffer
   local bufId = item.bufnr or item.bufId or item.buf
   if H.isValidBuf(bufId) then
      --stylua: ignore
      return {
         type = 'buffer',   bufId    = bufId, path = item.path or vim.api.nvim_buf_get_name(bufId),
         lnum = item.lnum, endLnum = item.endLnum,
         col   = item.col,   endCol   = item.endCol,
         text = item.text,
      }
   end

   -- File or Directory
   if type(item.path) == 'string' then
      local pathType = H.getFsType(item.path)
      if pathType == 'file' or pathType == 'uri' then
         --stylua: ignore
         return {
            type = pathType, path       = item.path,
            lnum = item.lnum, endLnum = item.endLnum,
            col   = item.col,   end_col   = item.endCol,
            text = item.text,
         }
      end

      if pathType == 'directory' then return { type = 'directory', path = item.path } end
   end

   return {}
end

H.parsePath = function(x)
   if type(x) ~= 'string' or x == '' then return nil end
   -- Allow inputs like 'aa/bb', 'aa-5'. Also allow inputs for line/position
   -- separated by null character:
   -- - 'aa/bb\00010' (line 10).
   -- - 'aa/bb\00010\0005' (line 10, col 5).
   -- - 'aa/bb\00010\0005\000xx' (line 10, col 5, with "xx" description).
   local locationPattern = '()%z(%d+)%z?(%d*)%z?(.*)$'
   local from, lnum, col, rest = x:match(locationPattern)
   local path = x:sub(1, (from or 0) - 1)
   path = path:sub(1, 1) == '~' and ((vim.loop.os_homedir() or '~') .. path:sub(2)) or path

   -- Verify that path is real
   local pathType = H.getFsType(path)
   if pathType == 'none' and path ~= '' then
      local cwd = H.pickers.active == nil and vim.fn.getcwd() or H.pickers.active.opts.source.cwd
      path = string.format('%s/%s', cwd, path)
      pathType = H.getFsType(path)
   end

   return pathType, path, tonumber(lnum), tonumber(col), rest or ''
end

H.getFsType = function(path)
   if path == '' then 
      return 'none' 
   end
   if vim.fn.filereadable(path) == 1 then 
      return 'file' 
   end
   if vim.fn.isdirectory(path) == 1 then 
      return 'directory' 
   end
   if H.parseUri(path) ~= nil then 
      return 'uri' 
   end
   return 'none'
end

-- Default preview ------------------------------------------------------------
H.previewFile = function(bufId, itemData, opts)
   -- Fully preview only accessible text files
   local isText = H.isFileText(itemData.path)
   if not isText then return H.setBuflines(bufId, { isText == nil and '-No-access-' or '-Non-text-file-' }) end

   -- Compute lines. Limit number of read lines to work better on large files.
   local hasLines, lines = pcall(
      vim.fn.readfile, itemData.path, '', (itemData.lnum or 1) + opts.nContextLines
   )
   if not hasLines then return end

   itemData.linePosition = opts.linePosition
   H.previewSetLines(bufId, lines, itemData)
end

H.previewDirectory = function(bufId, itemData)
   local path = itemData.path
   local format = function(x) 
      return x .. (vim.fn.isdirectory(path .. '/' .. x) == 1 and '/' or '') 
   end
   local lines = vim.tbl_map(format, vim.fn.readdir(path))
   H.setBuflines(bufId, lines)
end

H.previewBuffer = function(bufId, itemData, opts)
   -- NOTE: ideally just setting target buffer to window would be enough, but it
   -- has side effects. See https://github.com/neovim/neovim/issues/24973 .
   -- Reading lines and applying custom styling is a passable alternative.
   local bufIdSource = itemData.bufId

   -- Get lines from buffer ensuring it is loaded without important consequences
   local cacheEventignore = vim.o.eventignore
   vim.o.eventignore = 'BufEnter'
   vim.fn.bufload(bufIdSource)
   vim.o.eventignore = cacheEventignore
   local lines = 
      vim.api.nvim_buf_get_lines(bufIdSource, 0, (itemData.lnum or 1) + opts.nContextLines, false)

   itemData.filetype, itemData.linePosition = vim.bo[bufIdSource].filetype, opts.linePosition
   H.previewSetLines(bufId, lines, itemData)
end

H.previewUri = function(bufId, itemData, opts)
   itemData.bufId = vim.uri_to_bufnr(itemData.path)
   H.previewBuffer(bufId, itemData, opts)
end

H.previewInspect = function(bufId, obj) H.setBuflines(bufId, vim.split(vim.inspect(obj), '\n')) end

H.previewSetLines = function(bufId, lines, extra)
   -- Lines
   H.setBuflines(bufId, lines)

   -- Highlighting
   H.previewHighlightRegion(bufId, extra.lnum, extra.col, extra.endLnum, extra.endCol)

   if H.previewShouldHighlight(bufId) then
      local ft = extra.filetype or vim.filetype.match({ buf = bufId, filename = extra.path })
      vim.bo[bufId].syntax = ft
   end

   -- Cursor position and window view. Find window (and not use picker window)
   -- for "outside window preview" (preview and main are different) to work.
   local winId = vim.fn.bufwinid(bufId)
   if winId == -1 then return end
   H.setCursor(winId, extra.lnum, extra.col)
   local posKeys = ({ top = 'zt', center = 'zz', bottom = 'zb' })[extra.linePosition] or 'zt'
   pcall(vim.api.nvim_win_call, winId, function() vim.cmd('normal! ' .. posKeys) end)
end

H.previewShouldHighlight = function(bufId)
   -- Highlight if buffer size is not too big, both in total and per line
   local bufSize = vim.api.nvim_buf_call(
      bufId, function() return vim.fn.line2byte(vim.fn.line('$') + 1) end
   )
   return bufSize <= 1000000 and bufSize <= 1000 * vim.api.nvim_buf_line_count(bufId)
end

H.previewHighlightRegion = function(bufId, lnum, col, endLnum, endCol)
   -- Highlight line
   if lnum == nil then return end
   local hlLineOpts = { 
      endRow = lnum, endCol = 0, hlEol = true, hlGroup = 'MiniPickPreviewLine', priority = 201 
   }
   H.setExtMark(bufId, H.nsId.preview, lnum - 1, 0, hlLineOpts)

   -- Highlight position/region
   if col == nil then 
      return 
   end

   local extEndRow, extEndCol = lnum - 1, col
   if endLnum ~= nil and endCol ~= nil then
      extEndRow, extEndCol = endLnum - 1, endCol - 1
   end
   extEndCol = H.getNextCharBytecol(vim.fn.getbufline(bufId, extEndRow + 1)[1], extEndCol)

   local hlRegionOpts = { endRow = extEndRow, endCol = extEndCol, priority = 202 }
   hlRegionOpts.hlGroup = 'MiniPickPreviewRegion'
   H.setExtMark(bufId, H.nsId.preview, lnum - 1, col - 1, hlRegionOpts)
end

-- Default choose -------------------------------------------------------------
H.choosePath = function(winTarget, itemData)
   local path = H.parseUri(itemData.path) or itemData.path
   if itemData.type == 'directory' then
      return vim.api.nvim_win_call(
         winTarget, function() vim.cmd('edit ' .. vim.fn.fnameescape(path)) end
      )
   end
   pcall(vim.api.nvim_win_call, winTarget, function() vim.cmd("normal! m'") end)
   H.edit(path, winTarget)
   H.chooseSetCursor(winTarget, itemData.lnum, itemData.col)
end

H.chooseBuffer = function(winTarget, itemData)
   pcall(vim.api.nvim_win_call, winTarget, function() vim.cmd("normal! m'") end)
   H.setWinbuf(winTarget, itemData.bufId)
   H.chooseSetCursor(winTarget, itemData.lnum, itemData.col)
end

H.choosePrint = function(x) print(vim.inspect(x)) end

H.chooseSetCursor = function(winId, lnum, col)
   if lnum == nil then return end
   H.setCursor(winId, lnum, col)
   pcall(vim.api.nvim_win_call, winId, function() vim.cmd('normal! zvzz') end)
end

-- Builtins -------------------------------------------------------------------
H.cliPostprocess = function(items)
   while items[#items] == '' do
      items[#items] = nil
   end
   return items
end

H.isExecutable = function(tool)
   return tool == 'fallback' or vim.fn.executable(tool) == 1
end

H.filesGetTool = function()
   if H.isExecutable('rg') then return 'rg' end
   if H.isExecutable('fd') then return 'fd' end
   if H.isExecutable('git') then return 'git' end
   return 'fallback'
end

H.filesGetCommand = function(tool)
   if tool == 'rg' then return { 'rg', '--files', '--no-follow', '--color=never' } end
   if tool == 'fd' then return { 'fd', '--type=f', '--no-follow', '--color=never' } end
   if tool == 'git' then 
      return { 'git', 'ls-files', '--cached', '--others', '--exclude-standard' } 
   end
   H.error([[Wrong 'tool' for `files` builtin.]])
end

H.filesFallbackItems = function(cwd)
   local pokePicker = H.pokePickerThrottle()
   local f = function()
      local items = {}
      for path, pathType in vim.fs.dir(cwd, { depth = math.huge }) do
         if not pokePicker() then return end
         if pathType == 'file' and H.isFileText(string.format('%s/%s', cwd, path)) then 
            table.insert(items, path) 
         end
      end
      MiniPick.setPickerItems(items)
   end

   vim.schedule(coroutine.wrap(f))
end

H.grepGetTool = function()
   if H.isExecutable('rg') then return 'rg' end
   if H.isExecutable('git') then return 'git' end
   return 'fallback'
end

H.grepGetCommand = function(tool, pattern, globs)
   if tool == 'rg' then
      local res = {
         'rg', '--column', '--line-number', '--no-heading', '--field-match-separator', '\\x00', 
         '--no-follow', '--color=never'
      }
      for _, g in ipairs(globs) do
         table.insert(res, '--glob')
         -- NOTE: no `*` as default is important to not "override" ignoring files
         table.insert(res, g)
      end
      vim.list_extend(res, { '--', pattern })
      return res
   end
   if tool == 'git' then
      local res = { 'git', 'grep', '--column', '--line-number', '--null', '--color=never', '-e', 
         pattern, '--', unpack(globs) }
      if vim.o.ignorecase then 
         table.insert(res, 6, '--ignore-case') 
      end
      return res
   end
   H.error([[Wrong 'tool' for `grep` builtin.]])
end

H.grepFallbackItems = function(pattern, cwd)
   local pokePicker = H.pokePickerThrottle()
   local f = function()
      local files, filesFull = {}, {}
      for path, pathType in vim.fs.dir(cwd, { depth = math.huge }) do
         if not pokePicker() then return end
         local pathFull = string.format('%s/%s', cwd, path)
         if pathType == 'file' and H.isFileText(pathFull) then
            table.insert(files, path)
            table.insert(filesFull, pathFull)
         end
      end

      local items = {}
      for i, path in ipairs(filesFull) do
         local file = files[i]
         if not pokePicker() then return end
         for lnum, l in ipairs(vim.fn.readfile(path)) do
            local col = string.find(l, pattern)
            if col ~= nil then table.insert(items, string.format('%s\0%d\0%d\0%s', file, lnum, col, l)) end
         end
      end

      MiniPick.setPickerItems(items)
   end

   vim.schedule(coroutine.wrap(f))
end

-- Async ----------------------------------------------------------------------
H.scheduleResumeIsActive = vim.schedule_wrap(
   function(co) coroutine.resume(co, MiniPick.isPickerActive()) end
)

H.pokePickerThrottle = function(querytickRef)
   -- Allow calling this even if no picker is active
   if not MiniPick.isPickerActive() then
      return function() return true end
   end

   local latestTime, dontCheckQueryTick = vim.loop.hrtime(), querytickRef == nil
   local threshold = 1000000 * H.getConfig().delay.async
   local hrtime = vim.loop.hrtime
   local pokeIsPickerActive = MiniPick.pokeIsPickerActive
   return function()
      local now = hrtime()
      if (now - latestTime) < threshold then 
         return true 
      end
      latestTime = now
      -- Return positive if picker is active and no query updates (if asked)
      return pokeIsPickerActive() and (dontCheckQueryTick or querytickRef == H.querytick)
   end
end
--}}}
--{{{ Utilities ------------------------------------------------------------------
H.error = function(msg) error('(mini.pick) ' .. msg, 0) end

H.checkType = function(name, val, ref, allowNil)
   if type(val) == ref 
   or (ref == 'callable' and vim.is_callable(val)) 
   or (allowNil and val == nil) then 
      return 
   end
   H.error(string.format('`%s` should be %s, not %s', name, ref, type(val)))
end

H.setBufName = function(bufId, name) 
   vim.api.nvim_buf_set_name(bufId, 'minipick://' .. bufId .. '/' .. name) 
end

H.notify = function(msg, levelName) 
   vim.notify('(mini.pick) ' .. msg, vim.log.levels[levelName]) 
end

H.edit = function(path, winId)
   if type(path) ~= 'string' then return end
   local b = vim.api.nvim_win_get_buf(winId or 0)
   local tryMimicBufReuse = 
      (vim.fn.bufname(b) == '' and vim.bo[b].buftype ~= 'quickfix' and not vim.bo[b].modified)
      and (#vim.fn.win_findbuf(b) == 1 and vim.deep_equal(vim.fn.getbufline(b, 1, '$'), { '' }))
   local bufId = vim.fn.bufadd(vim.fn.fnamemodify(path, ':.'))
   -- Showing in window also loads. Use `pcall` to not error with swap messages.
   pcall(vim.api.nvim_win_set_buf, winId or 0, bufId)
   vim.bo[bufId].buflisted = true
   if tryMimicBufReuse then pcall(vim.api.nvim_buf_delete, b, { unload = false }) end
   return bufId
end

H.isValidBuf = function(bufId) 
   return type(bufId) == 'number' and vim.api.nvim_buf_is_valid(bufId) 
end

H.isValidWin = function(winId) return type(winId) == 'number' and vim.api.nvim_win_is_valid(winId) end

H.isArrayOf = function(x, refType)
   if not H.islist(x) then return false end
   for i = 1, #x do
      if type(x[i]) ~= refType then return false end
   end
   return true
end

H.createScratchBuf = function(name)
   local bufId = vim.api.nvim_create_buf(false, true)
   H.setBufName(bufId, name)
   vim.bo[bufId].matchpairs = ''
   vim.b[bufId].minicursorwordDisable = true
   vim.b[bufId].miniindentscopeDisable = true
   return bufId
end

H.getFirstValidNormalWindow = function()
   for _, winId in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if vim.api.nvim_win_get_config(winId).relative == '' then return winId end
   end
end

H.setBuflines = function(bufId, lines) 
   pcall(vim.api.nvim_buf_set_lines, bufId, 0, -1, false, lines) 
end

H.setWinbuf = function(winId, bufId) vim.api.nvim_win_set_buf(winId, bufId) end

H.setExtMark = function(...) pcall(vim.api.nvim_buf_set_ext_mark, ...) end

H.setCursor = function(winId, lnum, col) 
   pcall(vim.api.nvim_win_set_cursor, winId, { lnum or 1, (col or 1) - 1 }) 
end

H.setCurrwin = function(winId)
   if not H.isValidWin(winId) then return end
   -- Explicitly preserve cursor to fix Neovim<0.10 after choosing position in
   -- already shown buffer
   local cursor = vim.api.nvim_win_get_cursor(winId)
   vim.api.nvim_set_current_win(winId)
   H.setCursor(winId, cursor[1], cursor[2] + 1)
end

H.clearNamespace = function(bufId, nsId) 
   pcall(vim.api.nvim_buf_clear_namespace, bufId, nsId, 0, -1) 
end

H.replaceTermcodes = function(x)
   if x == nil then return nil end
   return vim.api.nvim_replace_termcodes(x, true, true, true)
end

H.expandCallable = function(x, ...)
   if vim.is_callable(x) then return x(...) end
   return x
end

H.expandCmd = function(x)
   local ok, res = pcall(vim.fn.expandcmd, x)
   return ok and res or x
end

H.redraw = function() vim.cmd('redraw') end

H.redrawScheduled = vim.schedule_wrap(H.redraw)

H.getcharStr = function(delayAsync)
   -- Ensure that redraws still happen
   H.timers.getcharstr:start(0, delayAsync, H.redrawScheduled)
   H.cache.isInGetCharstr = true
   local ok, char = pcall(vim.fn.getcharstr)
   H.cache.isInGetcharStr = nil
   H.timers.getcharStr:stop()

   -- Terminate if no input, on hard-coded <C-c>, or outside mouse click
   local mainWinId
   if H.pickers.active ~= nil then 
      mainWinId = H.pickers.active.windows.main 
   end
   local isBadMouseClick = vim.v.mouse_winid ~= 0 and vim.v.mouse_winid ~= mainWinId
   if not ok or char == '' or char == '\3' or isBadMouseClick then 
      return 
   end
   return char
end

H.toLower = (function()
   -- Cache `tolower` for speed
   local tolower = vim.fn.tolower
   return function(x)
      -- `vim.fn.tolower` can throw errors on bad string (like with '\0')
      local ok, res = pcall(tolower, x)
      return ok and res or string.lower(x)
   end
end)()

H.winUpdateHl = function(winId, newFrom, newTo)
   if not H.isValidWin(winId) then return end

   local newEntry = newFrom .. ':' .. newTo
   local replacePattern = string.format('(%s:[^,]*)', vim.pesc(newFrom))
   local newWinhighlight, nReplace = vim.wo[winId].winhighlight:gsub(replacePattern, newEntry)
   if nReplace == 0 then 
      newWinhighlight = newWinhighlight .. ',' .. newEntry 
   end
   vim.wo[winId].winhighlight = newWinhighlight
end

H.fitToWidth = function(text, width)
   local tWidth = vim.fn.strchars(text)
   return tWidth <= width and text 
      or ('…' .. vim.fn.strcharpart(text, tWidth - width + 1, width - 1))
end

H.winGetBottomBorder = function(winId)
   local border = vim.api.nvim_win_get_config(winId).border or {}
   local res = border[6]
   if type(res) == 'table' then res = res[1] end
   return res or ' '
end

H.winSetCwd = function(winId, cwd)
   -- Avoid needlessly setting cwd as it has side effects (like for `:buffers`)
   if cwd == nil or vim.fn.getcwd(winId or 0) == cwd then return end
   local f = function() vim.cmd('lcd ' .. vim.fn.fnameescape(cwd)) end
   if winId == nil or winId == vim.api.nvim_get_current_win() then return f() end
   vim.api.nvim_win_call(winId, f)
end

H.seqAlong = function(arr)
   if arr == nil then return nil end
   local res = {}
   for i = 1, #arr do
      table.insert(res, i)
   end
   return res
end

H.getNextCharBytecol = function(lineStr, col)
   if type(lineStr) ~= 'string' then return col end
   local utfIndex = vim.str_utfindex(lineStr, math.min(lineStr:len(), col))
   return vim.str_byteindex(lineStr, utfIndex)
end

H.isFileText = function(path)
   local fd = vim.loop.fs_open(path, 'r', 1)
   if fd == nil then return nil end
   local isText = vim.loop.fs_read(fd, 1024):find('\0') == nil
   vim.loop.fs_close(fd)
   return isText
end

H.fullPath = function(path) 
   return (vim.fn.fnamemodify(path, ':p'):gsub('(.)/$', '%1')) 
end

H.parseUri = function(x)
   local ok, path = pcall(vim.uri_to_fname, x)
   if not ok then return nil end
   return path
end

-- TODO: Remove after compatibility with Neovim=0.9 is dropped
H.islist = vim.fn.has('nvim-0.10') == 1 and vim.islist or vim.tbl_islist

--}}}

return MiniPick
--}}}
