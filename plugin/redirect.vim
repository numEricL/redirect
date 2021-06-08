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
        call s:AppendToRedirectBuffer(s:Redirect_output)
    endif
endfunction

command -nargs=1 -complete=command -bar Redirect silent call Redirect(<q-args>)
function Redirect(cmd) abort
    if a:cmd =~ '^!'
        let l:cmd = (a:cmd =~' %')?
                    \ matchstr(substitute(a:cmd, ' %', ' '.expand('%:p'), ''), '^!\zs.*'):
                    \ matchstr(a:cmd, '^!\zs.*')
        let l:output = system(l:cmd)
    else
        redir => l:output
            execute a:cmd
        redir END
    endif
    call s:AppendToRedirectBuffer(l:output)
endfunction

function s:AppendToRedirectBuffer(string)
    let l:string = substitute(a:string,'\(\n\+\)\n/\','\1','g')
    "vim 7.4.160 split returns type error if same variable is on LHS/RHS
    let l:output = split(l:string, "\n")

    if !s:Redirect_buffer
        vnew
        setlocal buftype=nofile
        let s:Redirect_buffer = bufnr('%')
    endif
    let l:win_nr = bufwinnr(s:Redirect_buffer)
    if l:win_nr == -1
        execute 'vertical sbuffer '.s:Redirect_buffer
        wincmd L
    else
        call s:Win_gotoid(l:win_nr)
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
