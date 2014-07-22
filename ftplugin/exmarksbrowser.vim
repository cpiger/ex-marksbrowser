" local settings {{{1
silent! setlocal buftype=nofile
silent! setlocal bufhidden=hide
silent! setlocal noswapfile
silent! setlocal nobuflisted

silent! setlocal cursorline
silent! setlocal number
silent! setlocal nowrap
silent! setlocal statusline=
" }}}1

" Key Mappings {{{1
call exmarksbrowser#bind_mappings()
" }}}1

" auto command {{{1
" }}}1

" vim:ts=4:sw=4:sts=4 et fdm=marker:
