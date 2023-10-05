" Vim syntax file
" Language:	C
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last Change:	2022 Mar 17

" A bunch of useful C keywords
syn keyword	Statement	goto break return continue asm const let of type class case default if else switch while for do await function try catch readonly
syntax region Comment start="//" end="\n"
syntax region String start="`" end="`"
let b:current_syntax = "typescript"

