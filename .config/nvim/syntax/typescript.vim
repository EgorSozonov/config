" Vim syntax file
" Language:	C
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last Change:	2022 Mar 17

" A bunch of useful C keywords
syn keyword	Statement	goto break return continue asm const let of type interface class case default if else switch while for do function try catch readonly async await
syntax region Comment start="//" end="\n"
syntax region String start="`" end="`"
let b:current_syntax = "typescript"

