if !exists('g:Redirect_map_toggle')
    let g:Redirect_map_toggle = '<leader>r'
endif
execute 'nnoremap '.g:Redirect_map_toggle.' :call ToggleRedirect()<cr>'

let s:Redirect_state = 0
let s:Redirect_window = 0
let s:Redirect_buffer = 0
let s:Redirect_output = ""
function ToggleRedirect() abort
    if s:Redirect_state == 0
        let s:Redirect_state = 1
        redir => s:Redirect_output
    else
        redir END
        let s:Redirect_state = 0
        let s:Redirect_output = substitute(s:Redirect_output,'\(\n\+\)\n/\','\1','g')
        "vim 7.4.160 split returns type error if same variable is on LHS/RHS
        let l:output_workaround = split(s:Redirect_output, "\n")
        let s:Redirect_output = l:output_workaround

        if !s:Redirect_buffer
            vnew
            setlocal buftype=nofile bufhidden=hide nobuflisted
            let s:Redirect_buffer = bufnr('%')
        endif
        let l:win_list = win_findbuf(s:Redirect_buffer)
        if !len(l:win_list)
            execute 'vertical sbuffer '.s:Redirect_buffer
            wincmd L
        else
            call s:Win_gotoid(l:win_list[0])
        endif
        if line('$') == 1 && getline(1) == ""
            call setline(1, s:Redirect_output)
        else
            call append(line('$'), "")
            call append(line('$'), s:Redirect_output)
        endif
    endif
endfunction

if v:version > 800 || v:version == 800 && has("patch1089")
    command -nargs=1 -complete=command -bar -range Redirect silent call Redirect(<q-args>, <range>, <line1>, <line2>)
else
    command -nargs=1 -complete=command -bar -range Redirect silent call Redirect(<q-args>, <line2>-<line1>, <line1>, <line2>)
endif

function Redirect(cmd, rangec, range1, range2) abort
    if a:cmd =~ '^!'
        let l:cmd = a:cmd =~' %'
                    \ ? matchstr(substitute(a:cmd, ' %', ' '.expand('%:p'), ''), '^!\zs.*')
                    \ : matchstr(a:cmd, '^!\zs.*')
        if a:rangec == 0
            if v:version > 704 || v:version == 704 && has("patch248")
                let l:output = systemlist(l:cmd)
            else
                let l:output = split(system(l:cmd), '\n')
            endif
        else
            let l:joined_lines = join(getline(a:range1, a:range2), '\n')
            let l:cleaned_lines = substitute(shellescape(l:joined_lines), "'\\\\''", "\\\\'", 'g')
            if v:version > 704 || v:version == 704 && has("patch248")
                let l:output = systemlist(l:cmd." <<< $".l:cleaned_lines)
            else
                let l:output = split(system(l:cmd." <<< $".l:cleaned_lines), '\n')
            endif
        endif
    else
        "vim 7.4.160 split returns type error if l:output is on RHS
        redir => l:output_workaround
        execute a:cmd
        redir END
        "let l:output = substitute(l:output_workaround,'^\n\+\|\n\+$','','g')
        let l:output = split(l:output_workaround, "\n")
    endif

    if !s:Redirect_buffer
        vnew
        setlocal buftype=nofile bufhidden=hide nobuflisted
        let s:Redirect_buffer = bufnr('%')
    endif
    let l:win_list = win_findbuf(s:Redirect_buffer)
    if !len(l:win_list)
        execute 'vertical sbuffer '.s:Redirect_buffer
        wincmd L
    else
        call s:Win_gotoid(l:win_list[0])
    endif
    if line('$') == 1 && getline(1) == ""
        call setline(1, l:output)
    else
        call append(line('$'), "")
        call append(line('$'), l:output)
    endif
endfunction

function s:Win_getid(nr) abort
    if v:version >= 800
        return win_getid(a:nr)
    else
        return a:nr
    endif
endfunction

function s:Win_gotoid(id) abort
    if v:version >= 800
        return win_gotoid(a:id)
    else
        if 0 < a:id && a:id <= winnr('$')
            execute a:id."wincmd w"
            return 1
        else
            return 0
        endif
    endif
endfunction
