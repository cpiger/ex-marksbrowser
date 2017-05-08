" check if plugin loaded
if exists('loaded_exmarksbrowser') || &cp
    finish
endif
let loaded_exmarksbrowser=1
" default configuration {{{1
if !exists('g:ex_mb_winsize')
    let g:ex_mb_winsize = 20
endif

if !exists('g:ex_mb_winsize_zoom')
    let g:ex_mb_winsize_zoom = 40
endif

" bottom or top
if !exists('g:ex_mb_winpos')
    let g:ex_mb_winpos = 'bottom'
endif

if !exists('g:ex_mb_ignore_case')
    let g:ex_mb_ignore_case = 1
endif

if !exists('g:ex_mb_enable_sort')
    let g:ex_mb_enable_sort = 1
endif

" will not sort the result if result lines more than x 
if !exists('g:ex_mb_sort_lines_threshold')
    let g:ex_mb_sort_lines_threshold = 100
endif

if !exists('g:ex_mb_enable_help')
    let g:ex_mb_enable_help = 1
endif

"/////////////////////////////////////////////////////////////////////////////
" variables
"/////////////////////////////////////////////////////////////////////////////
" go back to edit buffer
if !exists('g:exmb_backto_editbuf')
    let g:exmb_backto_editbuf = 0
endif

" go and close exTagSelect window
if !exists('g:exmb_close_when_selected')
    let g:exmb_close_when_selected = 0
endif

" set edit mode  'none', 'append', 'replace'
if !exists('g:exmb_edit_mode')
    let g:exmb_edit_mode = 'replace'
endif

"/////////////////////////////////////////////////////////////////////////////
" Commands
"/////////////////////////////////////////////////////////////////////////////
command ExmbToggle call exmarksbrowser#toggle_window()
command! EXmbOpen call  exmarksbrowser#open_window()
command! EXmbClose call exmarksbrowser#close_window()

" default key mappings {{{1
call exmarksbrowser#register_hotkey( 1  , 1, '?'            , ":call exmarksbrowser#toggle_help()<CR>"           , 'Toggle help.' )
if has('gui_running')
    call exmarksbrowser#register_hotkey( 2  , 1, '<ESC>'           , ":EXmbClose<CR>"                         , 'Close window.' )
else
    call exmarksbrowser#register_hotkey( 2  , 1, '<leader><ESC>'   , ":EXmbClose<CR>"                         , 'Close window.' )
endif
" call exmarksbrowser#register_hotkey( 3  , 1, '<Space>'         , ":call exmarksbrowser#toggle_zoom()<CR>"           , 'Zoom in/out project window.' )
call exmarksbrowser#register_hotkey( 3  , 1, 'z'               , ":call exmarksbrowser#toggle_zoom()<CR>"           , 'Zoom in/out project window.' )
call exmarksbrowser#register_hotkey( 4  , 1, '<CR>'            , ":call exmarksbrowser#confirm_select('')<CR>"      , 'Go to the select result.' )
call exmarksbrowser#register_hotkey( 5  , 1, '<2-LeftMouse>'   , ":call exmarksbrowser#confirm_select('')<CR>"      , 'Go to the select result.' )
call exmarksbrowser#register_hotkey( 6  , 1, '<S-CR>'          , ":call exmarksbrowser#confirm_select('shift')<CR>" , 'Go to the select result in split window.' )
call exmarksbrowser#register_hotkey( 7  , 1, '<S-2-LeftMouse>' , ":call exmarksbrowser#confirm_select('shift')<CR>" , 'Go to the select result in split window.' )
"}}}

call ex#register_plugin( 'exmarksbrowser', { 'actions': ['autoclose'] } )

" vim:ts=4:sw=4:sts=4 et fdm=marker:
