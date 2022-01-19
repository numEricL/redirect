if !exists('g:redirect#buffer_name')
    let g:redirect#buffer_name = 'default'
endif

nnoremap <silent> <plug>(redirect-Toggle) :<c-u>call redirect#Toggle()<cr>

command -complete=command -bar ToggleRedirect silent call redirect#Toggle()
command -bang -nargs=1 -complete=command -bar Redirect silent call redirect#Redirect(<q-args>, <bang>0)
