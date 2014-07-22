if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

" syntax highlight

" DISABLE
" if g:ex_gsearch_highlight_result
"     " this will load the syntax highlight as cpp for search result
"     silent exec "so $VIM/vimfiles/after/syntax/exUtility.vim"
" endif

syntax match ex_mks_filename '|\S|'
syntax match ex_mks_linenr '(\d\+,\d\+):'
syntax region ex_mks_header start="^--------------------" end="--------------------"
syntax match ex_mks_title '^<<<<<< .* >>>>>>'

syntax match ex_mks_help #^".*# contains=ex_mks_help_key
syntax match ex_mks_help_key '^" \S\+:'hs=s+2,he=e-1 contained contains=ex_mks_help_comma
syntax match ex_mks_help_comma ':' contained



hi default link ex_mks_help Comment
hi default link ex_mks_help_key Label
hi default link ex_mks_help_comma Special

hi default link ex_mks_title SpecialChar
hi default link ex_mks_header SpecialKey
hi default link ex_mks_filename Directory
hi default link ex_mks_linenr Special

let b:current_syntax = "exmarksbrowser"

" vim:ts=4:sw=4:sts=4 et fdm=marker:
