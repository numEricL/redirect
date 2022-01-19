let s:output = ""
let s:bufnrs = {}
let s:toggle_state = 0

function redirect#Toggle() abort
    if !exists('s:toggle_state') | let s:toggle_state = 0 | endif
    if s:toggle_state == 0
        redir => s:output
    else
        redir END
        call s:AppendToRedirectBuffer(s:output, 0)
    endif
    let s:toggle_state = !s:toggle_state
endfunction

function redirect#Redirect(cmd, background) abort
    if a:cmd =~ '^!'
        let l:cmd = (a:cmd =~' %')?
                    \ matchstr(substitute(a:cmd, ' %', ' '.expand('%:p'), ''), '^!\zs.*'):
                    \ matchstr(a:cmd, '^!\zs.*')
        let l:output = system(l:cmd)
    else
        if v:version > 704 || v:version == 704 && has("patch2008")
            let l:output = execute(a:cmd)
        else
            redir => l:output
            execute a:cmd
            redir END
        endif
    endif
    call s:AppendToRedirectBuffer(l:output, a:background)
endfunction

function s:AppendToRedirectBuffer(string, background)
    let l:buf_nr = get(s:bufnrs, g:redirect#buffer_name, 0)
    if !l:buf_nr
        if g:redirect#buffer_name == 'default'
            vnew
        else
            execute 'vnew '.g:redirect#buffer_name
        endif
        setlocal buftype=nofile
        let l:buf_nr = bufnr('%')
        let s:bufnrs[g:redirect#buffer_name] = l:buf_nr
    endif

    let l:win_nr = bufwinnr(l:buf_nr)
    if l:win_nr == -1
        execute 'vertical sbuffer '.l:buf_nr
        wincmd L
    else
        call s:Win_gotoid(s:Win_getid(l:win_nr))
    endif

    "vim 7.4.160 split returns type error if same variable is on LHS/RHS
    let l:output = split(a:string, "\n")

    if line('$') == 1 && getline(1) == ""
        call setline(1, l:output)
    else
        call append(line('$'), l:output)
    endif
    if a:background && &hidden
        wincmd q
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
