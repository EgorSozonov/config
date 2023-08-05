  
## Plugins 
location
>~/.config/nvim/pack/PluginName/start
>~/.local/share/nvim/site/pack

Install the simple Paq package manager

> git clone --depth=1 https://github.com/savq/paq-nvim.git \
    ~/.local/share/nvim/site/pack/paqs/start/paq-nvim
  
## Subwindows

New 
> Ctrl-w n

Next window
> Ctrl-w j

Previous window
> Ctrl-w k

## Folds

Write in the file
> ${tripleLeftCurlyBrace}1

Toggle fold
> za

### Sessions
Save session
> :mksession! sessionFile.vim

Open session
> nvim -S sessionFile.vim

## Leap

Jump ahead on same screen

> s${letter1}${letter2}

^ it's crucial that there are only two letters

Jump back on same screen

> S${letter1}${letter2}

## Netrw (built-in alternative to NERDTree or nvim-tree)

	let g:netrw_banner = 0	
	let g:netrw_liststyle = 3	
	let g:netrw_browse_split = 4	
	let g:netrw_altv = 1	
	let g:netrw_winsize = 25	
	augroup ProjectDrawer
        autocmd!
        autocmd VimEnter * :Vexplore
    augroup END

  
  

Keep the current directory and the browsing directory synced
This helps you avoid the move files error

>let g:netrw_keepdir = 0

 
Change the size of the Netrw window when it creates a split. I think 30% is fine
>let g:netrw_winsize = 30

  

Hide the banner (if you want). To show it temporarily you can use I inside Netrw
>let g:netrw_banner = 0

  

Hide dotfiles on load.
>let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'

  

Change the copy command. Mostly to enable recursive copy of directories
>let g:netrw_localcopydircmd = 'cp -r'

  

Highlight marked files in the same way search matches are
>hi! link netrwMarkFile Search

 
We begin by changing the way we call Netrw.

We bind :Lexplore to a shortcut so we can toggle it whenever we want.

    nnoremap <leader>dd :Lexplore %:p:h<CR>
    nnoremap <Leader>da :Lexplore<CR>

Leader dd: Will open Netrw in the directory of the current file.
Leader da: Will open Netrw in the current working directory.
  

Netrw is a plugin that defines its own filetype, so we are going to use that to our advantage. # What we are going to do is place our keymaps inside a function and create an autocommand that calls it everytime vim opens a filetype netrw.
	
	function! NetrwMapping()
	
	endfunction
	
	  
	
	augroup netrw_mapping
	
	  autocmd!
	
	  autocmd filetype netrw call NetrwMapping()
	
	augroup END

  
With this in our config all we have to do now is place the keymaps inside NetrwMapping. Like this.

	function! NetrwMapping()	
	  nmap <buffer> H u	
	  nmap <buffer> h -^	
	  nmap <buffer> l <CR>		  
	  nmap <buffer> . gh	
	  nmap <buffer> P <C-w>z		  	
	  nmap <buffer> L <CR>:Lexplore<CR>	
	  nmap <buffer> <Leader>dd :Lexplore<CR>	
	endfunction

  
Since we don't have access to the functions Netrw uses internally (at least not all of them), we use nmap to make our keymaps. 

For example, H will be the same thing as pressing u, and u will trigger the command we want to execute. So this is what we have:

-   H Will "go back" in history.
    
-   h Will "go up" a directory.
    
-   l Will open a directory or a file.
    
-   . Will toggle the dotfiles.
    
-   P Will close the preview window.
    
-   L Will open a file and close Netrw.
    
-   Leader dd: Will just close Netrw.
    

Let's find a better way to manage the marks on files. I suggest using Tab.
		nmap <buffer> <TAB> mf	
		nmap <buffer> <S-TAB> mF		
		nmap <buffer> <Leader><TAB> mu

-  Tab: Toggles the mark on a file or directory.    
-  Shift Tab: Will unmark all the files in the current buffer.    
-   Leader Tab: Will remove all the marks on all files.
    

Since there are quite a few commands related to files we are going to use the f key as a prefix to group these together.

	nmap <buffer> ff %:w<CR>:buffer #<CR>	
	nmap <buffer> fe R	
	nmap <buffer> fc mc	
	nmap <buffer> fC mtmc	
	nmap <buffer> fx mm	
	nmap <buffer> fX mtmm	
	nmap <buffer> f; mx
  

-   ff: Will create a file. But like create it for real. This time, after doing % we use :w<CR> to save the empty file and :buffer #<CR> to go back to Netrw.
    
-   fe: Will rename a file.
    
-   fc: Will copy the marked files.
    
-   fC: We will use this to "skip" a step. After you mark your files you can put the cursor in a directory and this will assign the target directory and copy in one step.
    
-   fx: Will move marked files.
    
-   fX: Same thing as fC but for moving files.
    
-   f;: Will be for running external commands on the marked files.
    

# Show a list of marked files.

nmap <buffer> fl :echo join(netrw#Expose("netrwmarkfilelist"), "\n")<CR>

  

# Show the target directory, just in case we want to avoid the banner.

nmap <buffer> fq :echo 'Target:' . netrw#Expose("netrwmftgt")<CR>

  

# Now we can use that along side mt.

nmap <buffer> fd mtfq

  

# In the same way we grouped the file related actions, we do it for bookmarks.
nmap <buffer> bb mb
nmap <buffer> bd mB
nmap <buffer> bl gb



-   bb: To create a bookmark.
    
-   bd: To remove the most recent bookmark.
    
-   bl: To jump to the most recent bookmark.
    

# Last thing we will do is "automate" that process we did to remove nonempty directories. For this we will need a function.

function! NetrwRemoveRecursive()
  if &filetype ==# 'netrw'
    cnoremap <buffer> <CR> rm -r<CR>
    normal mu
    normal mf

    try
      normal mx
    catch
      echo "Canceled"
    endtry

    cunmap <buffer> <CR>
  endif
endfunction
 
nmap <buffer> FF :call NetrwRemoveRecursive()<CR>
