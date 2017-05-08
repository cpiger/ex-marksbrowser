
let s:title = "-Marks-" 
let s:confirm_at = -1

let s:zoom_in = 0
let s:keymap = {}

let s:help_open = 0
let s:help_text_short = [
            \ '" Press ? for help',
            \ '',
            \ ]
let s:help_text = s:help_text_short


let s:help_text_showmarks= [
            \'" for plugin showmarks',
            \'" <leader>mt: ShowMarksToggle',
            \'" <leader>mo: ShowMarksOn',
            \'" <leader>mh: ShowMarksClearMark',
            \'" <leader>mc: ShowMarksClearMark',
            \'" <leader>ma: ShowMarksClearAll',
            \'" <leader>mm: ShowMarksPlaceMark',
            \ '',
            \ ]

function exmarksbrowser#bind_mappings()
    call ex#keymap#bind( s:keymap )
endfunction

function exmarksbrowser#register_hotkey( priority, local, key, action, desc )
    call ex#keymap#register( s:keymap, a:priority, a:local, a:key, a:action, a:desc )
endfunction

function s:update_help_text()
    if s:help_open
        let s:help_text = ex#keymap#helptext(s:keymap)
        let s:help_text += s:help_text_showmarks
    else
        let s:help_text = s:help_text_short
    endif
endfunction

function exmarksbrowser#toggle_help()
    if !g:ex_mb_enable_help
        return
    endif

    silent! setlocal modifiable

    let s:help_open = !s:help_open
    silent exec '1,' . len(s:help_text) . 'd _'
    call s:update_help_text()


    silent call append ( 0, s:help_text )
    silent keepjumps normal! gg
    call ex#hl#clear_confirm()

    silent! setlocal nomodifiable
endfunction

" exmarksbrowser#open_window {{{2
function exmarksbrowser#init_buffer()
    set filetype=exmarksbrowser
    au! BufWinLeave <buffer> call <SID>on_close()

    if line('$') <= 1 && g:ex_mb_enable_help
        silent call append ( 0, s:help_text )
        silent exec '$d _'
    endif
endfunction

function s:on_close()
    let s:zoom_in = 0
    let s:help_open = 0

    " go back to edit buffer
    call ex#window#goto_edit_window()
    call ex#hl#clear_target()
endfunction

function exmarksbrowser#open_window()
    let winnr = winnr()
    if ex#window#check_if_autoclose(winnr)
        call ex#window#close(winnr)
    endif
    call ex#window#goto_edit_window()

    let winnr = bufwinnr(s:title)
    if winnr == -1
        call ex#window#open( 
                    \ s:title, 
                    \ g:ex_mb_winsize,
                    \ g:ex_mb_winpos,
                    \ 1,
                    \ 1,
                    \ function('exmarksbrowser#init_buffer')
                    \ )
        if s:confirm_at != -1
            call ex#hl#confirm_line(s:confirm_at)
        endif
        call g:exmb_update_selectwindow ()
    else
        exe winnr . 'wincmd w'
    endif
endfunction

" exmarksbrowser#toggle_window {{{2
function exmarksbrowser#toggle_window()
    let result = exmarksbrowser#close_window()
    if result == 0
        call exmarksbrowser#open_window()
    endif
endfunction

" exmarksbrowser#close_window {{{2
function exmarksbrowser#close_window()
    let winnr = bufwinnr(s:title)
    if winnr != -1
        call ex#window#close(winnr)
        return 1
    endif
    return 0
endfunction

" exmarksbrowser#toggle_zoom {{{2
function exmarksbrowser#toggle_zoom()
    let winnr = bufwinnr(s:title)
    if winnr != -1
        if s:zoom_in == 0
            let s:zoom_in = 1
            call ex#window#resize( winnr, g:ex_mb_winpos, g:ex_mb_winsize_zoom )
        else
            let s:zoom_in = 0
            call ex#window#resize( winnr, g:ex_mb_winpos, g:ex_mb_winsize )
        endif
    endif
endfunction

" exmarksbrowser#confirm_select {{{2
" modifier: '' or 'shift'
function exmarksbrowser#confirm_select(modifier)
    let select_line = getline('.')
    if match( select_line, '^|\S| (\d\+,\d\+): .*' ) == -1
        call ex#warning ("invalid selection line")
        return
    endif

    " get file name if exisits
    let idx = matchend( select_line, '^|\S| (\d\+,\d\+): ' )
    let text = strpart ( select_line, idx )
    let filename = fnamemodify(text,":p")

    " get line and column
    let idx_start = match( select_line, '(\d\+,\d\+)' )
    let idx_end = matchend( select_line, '(\d\+,\d\+)' )
    let text = strpart ( select_line, idx_start, idx_end-idx_start )
    let line_col = split(text,',')
    let line = line_col[0][1:] 
    let col = line_col[1][0:len(line_col[1])-2] 

    " highlight selected line.
    let s:exmb_select_idx = line('.')
    " call exUtility#HighlightConfirmLine()
    let s:confirm_at = line('.')
    call ex#hl#confirm_line(s:confirm_at)

    " go back to editbuf jump
    call ex#window#goto_edit_window()
    let need_refresh_marks = 0

    if findfile ( filename ) != ''
        silent keepjumps exec 'e '.filename
        let need_refresh_marks = 1
    endif
    silent keepjumps call setpos ( '.', [0,line,col,0] )

    " cause different files have different marks (those lower case marks), so we need to refresh mark browser
    if need_refresh_marks
        call ex#window#goto_plugin_window()
        call g:exmb_update_selectwindow ()
    endif

    " let winnum = bufwinnr(s:title)
    " call ex#window#operate( winnum, g:exmb_close_when_selected, g:exmb_backto_editbuf, 1 )

    " go back to mb window
    exe 'normal! zz'
    call ex#hl#target_line(line('.'))
    call ex#window#goto_plugin_window()

endfunction


let s:exmb_select_idx = 1
let s:exmb_cursor_idx = 1

" TODO: custumize what marks to show
let s:exmb_all_marks = "abcdefghijklmnopqrstuvwxyz.'`^<>\""
"let s:exmb_all_marks = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.'`^<>\""

function g:exmb_update_selectwindow() " <<<
    " we alwasy clear confirmed highlight, every time we open the browse window
    call ex#hl#clear_confirm()

    let results = s:exmb_fetchmarks()
    call sort( results, "s:exmb_sortmarks" )
    call s:exmb_fill( results )
endfunction " >>>

" ------------------------------------------------------------------ 
" Desc: call when cursor moved
" ------------------------------------------------------------------ 
function s:exmb_selectcursormoved()
    let line_num = line('.')

    if line_num == s:exmb_cursor_idx
        " call exUtility#HighlightSelectLine()
        " call ex#hl#select_line()
        let s:confirm_at = line('.')
        call ex#hl#target_line(s:confirm_at)
        return
    endif

    while match(getline('.'), '^|\S| (\d\+,\d\+): .*') == -1
        if line_num > s:exmb_cursor_idx
            if line('.') == line('$')
                break
            endif
            silent exec 'normal! j'
        else
            if line('.') == 1
                silent exec 'normal! 2j'
                let s:exmb_cursor_idx = line_num - 1
            endif
            silent exec 'normal! k'
        endif
    endwhile

    let s:exmb_cursor_idx = line('.')
    " call ex#hl#select_line()
    let s:confirm_at = line('.')
    call ex#hl#target_line(s:confirm_at)
endfunction

function s:exmb_fetchmarks() " <<<

    call ex#window#goto_edit_window()
    silent redir =>marks_text
    silent! exec 'marks'
    silent redir END
    call ex#window#goto_plugin_window()

    let marks_list = split (marks_text,'\n')
    let result_list = []
    for item in marks_list[1:]
        let raw_string = item 
        let mark_info = {}

        " get mark name
        let string = raw_string 
        let idx_start = match ( string, '\S' )
        let string = strpart ( string, idx_start )
        let idx_end = match ( string, '\s' )
        let mark_info.name = strpart ( raw_string, idx_start, idx_end )
        let raw_string = strpart ( string, idx_end ) 

        " get mark line
        let string = raw_string
        let idx_start = match ( string, '\S' )
        let string = strpart ( string, idx_start )
        let idx_end = match ( string, '\s' )
        let mark_info.line = strpart ( raw_string, idx_start, idx_end )
        let raw_string = strpart ( string, idx_end ) 

        " get mark col
        let string = raw_string
        let idx_start = match ( string, '\S' )
        let string = strpart ( string, idx_start )
        let idx_end = match ( string, '\s' )
        let mark_info.col = strpart ( raw_string, idx_start, idx_end )
        let raw_string = strpart ( string, idx_end ) 

        " get mark text/file
        let string = raw_string
        let idx_start = match ( string, '\S' )
        let string = strpart ( string, idx_start )
        let mark_info.text = strpart ( raw_string, idx_start )

        silent call add ( result_list, mark_info )
    endfor

    return result_list
endfunction " >>>


function s:exmb_sortmarks( i1, i2 ) " <<<
    let name1 = a:i1.name
    let name2 = a:i2.name

    " lowercase:0, uppercase:1, special:2, digital:3 
    " init as special
    let type_order1 = 2 
    let type_order2 = 2 

    " get order1
    if name1 =~# '[a-z]'
        let type_order1 = 0
    elseif name1 =~# '[A-Z]'
        let type_order1 = 1
    elseif name1 =~# '[0-9]'
        let type_order1 = 3
    endif

    " get order2
    if name2 =~# '[a-z]'
        let type_order2 = 0
    elseif name2 =~# '[A-Z]'
        let type_order2 = 1
    elseif name2 =~# '[0-9]'
        let type_order2 = 3
    endif

    if type_order1 !=# type_order2
        return type_order1 ==# type_order2 ? 0 : type_order1 ># type_order2 ? 1 : -1
    else
        " return name1 ==# name2 ? 0 : name1 ># name2 ?  1 : -1
        return name1 ==# name2 ? 0 : name1 ># name2 ? -1 : 1
    endif
endfunction " >>>


function s:exmb_fill( results ) " <<<
    silent! setlocal modifiable

    " clear window
    silent exec '1,$d _'

    " add online help 
    if g:ex_mb_enable_help
        silent call append ( 0, s:help_text )
        silent exec '$d _'
        let start_line = len(s:help_text)
    else
        let start_line = 0
    endif

    " put the result
    silent exec 'normal ' . start_line . 'g'

    " put header
    put = '<<<<<< \|mark\| (line,col): file/text >>>>>>'
    let did_special_sep = 0
    let did_digital_sep = 0
    let did_lowercase_sep = 0
    let did_uppercase_sep = 0

    let save_pos = getpos('.')

    "
    for item in a:results
        if did_special_sep == 0 && item.name !~# '[0-9a-zA-Z]'  
            let did_special_sep = 1
            silent put =''
            silent put ='-------------------- special marks --------------------'
        elseif did_lowercase_sep == 0 && item.name =~# '[a-z]'  
            let did_lowercase_sep = 1
            silent put =''
            silent put ='-------------------- lowercase marks --------------------'
        elseif did_uppercase_sep == 0 && item.name =~# '[A-Z]'  
            let did_uppercase_sep = 1
            silent put =''
            silent put ='-------------------- uppercase marks --------------------'
        elseif did_digital_sep == 0 && item.name =~# '[0-9]'  
            let did_digital_sep = 1
            silent put =''
            silent put ='-------------------- number marks --------------------'
        endif

        silent put = '\|'.item.name.'\| '.'('.item.line.','.item.col.'): '.item.text
    endfor

    silent call setpos('.', save_pos)
    silent! setlocal nomodifiable
endf
