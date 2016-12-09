nnoremap <buffer> <silent> <C-]>  :<C-u>call bettertagjump#php#Jump()<CR>

let b:undo_ftplugin .= '| nunmap <buffer> <C-]>'
