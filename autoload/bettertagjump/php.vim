function! s:_GetCwordStartPos()
  let cword = expand('<cword>')
  let cword_pattern = '\V' . escape(cword, '\')
  let cword_end_pos = searchpos(cword_pattern, 'ceW', line('.'))
  let cword_start_pos = searchpos(cword_pattern, 'bcW', line('.'))
  return cword_start_pos
endfunction

function! s:GuessClassName()
  let cursor_pos = getpos('.')
  let class_name = s:_GuessClassName()
  call setpos('.', cursor_pos)
  return class_name
endfunction

function! s:_GuessClassName()
  let line = getline('.')
  let prefix_end_index = s:_GetCwordStartPos()[1] - 2
  let prefix = prefix_end_index >= 0 ? line[:prefix_end_index] : ''

  if prefix =~# '\<self::$' || prefix =~# '$this->$'
    return s:_GetCurrentClassName()
  elseif prefix =~# '\<\k\+::$'
    return matchstr(prefix, '\<\zs\k\+\ze::$')
  else
    return ''
  endif
endfunction

function! s:_GetCurrentClassName()
  normal! 999[{
  if search('\<class\>', 'bW') == 0
    return ''
  endif
  normal! W
  return expand('<cword>')
endfunction

function! s:ReorderTags(tags)
  let cword = expand('<cword>')
  let current_filename = expand('%:p')
  let exact_tags_in_current_file = []
  let other_tags = []
  for tag in a:tags
    if tag['name'] ==# cword && fnamemodify(tag['filename'], ':p') ==# current_filename
      call add(exact_tags_in_current_file, tag)
    else
      call add(other_tags, tag)
    endif
  endfor
  return exact_tags_in_current_file + other_tags
endfunction

function! bettertagjump#php#Jump()
  let class_name = s:GuessClassName()
  let jump_count = ''
  if class_name != ''
    let tags = s:ReorderTags(taglist(expand('<cword>')))
    for tag in tags
      if has_key(tag, 'class') && tag['class'] ==# class_name
        let jump_count = index(tags, tag) + 1
        break
      endif
    endfor
  endif
  execute 'normal!' jump_count."\<C-]>"
endfunction
