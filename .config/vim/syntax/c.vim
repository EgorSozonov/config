" Vim syntax file
" Language:		C
" Maintainer:		The Vim Project <https://github.com/vim/vim>
" Last Change:		2025 Jan 18
" Former Maintainer:	Bram Moolenaar <Bram@vim.org>

" Quit when a (custom) syntax file was already loaded
if exists("b:current_syntax")
  finish
endif


let s:ft = matchstr(&ft, '^\%([^.]\)\+')

" A bunch of useful C keywords
syn keyword	cKeyword	if for while restrict define typedef goto break return continue asm
syn keyword	cKeyword2	private internal else ei struct enum include const constexpr
syn region cComment start="//" skip="\\$" end="$" keepend
" Define the default highlighting.
" Only used when an item doesn't have highlighting yet
hi def link cKeyword		Keyword
hi def link cKeyword2		Keyword
hi def link cComment		Comment

let b:current_syntax = "c"

unlet s:ft

" vim: ts=8
