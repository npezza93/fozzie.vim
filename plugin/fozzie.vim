if exists("g:fozzie_loaded")
  finish
endif

let g:fozzie_loaded = 1

if has('nvim')
  function! FozzieCommand(choice_command, vim_command, height, fozzie_args)
    if (float2nr(&columns) < 120)
      let width = float2nr(&columns) - 10
    else
      let width = float2nr(&columns) * 3 / 8
    endif
    let col = float2nr(&columns) * 5 / 16

    let winid = win_getid()
    let s:float_term_padding_win = FozzieFloatingPaddingWindow(width, a:height, a:height, col)

    call CreateFozzieFloatingWindow(width, col, a:height)

    call FozzieFileCommand(a:choice_command, a:vim_command, winid, a:fozzie_args)
    autocmd TermClose * ++once :bd! | call nvim_win_close(s:float_term_padding_win, v:true)
    setlocal
          \ nobuflisted
          \ bufhidden=hide
          \ nonumber
          \ norelativenumber
          \ signcolumn=no
  endfunction

  function! FozzieFileCommand(choice_command, vim_command, winid, fozzie_args)
      let file = tempname()
      let cmd = split(&shell) + split(&shellcmdflag) + [a:choice_command . ' | fozzie ' . a:fozzie_args . ' > ' . file]
      let F = function('s:fozzie_completed', [a:winid, file, a:vim_command])
      call termopen(cmd, {'on_exit': F})
      setlocal nonumber norelativenumber
      startinsert
  endfunction

  function! s:fozzie_completed(winid, filename, action, ...) abort
      call win_gotoid(a:winid)
      if filereadable(a:filename)
        let lines = readfile(a:filename)
        if !empty(lines)
          exe a:action . ' ' . lines[0]
        endif
        call delete(a:filename)
      endif
  endfunction

  function! FozzieFloatingPaddingWindow(width, height, row, col)
    let opts = {
      \ 'relative': 'editor',
      \ 'row': a:row - 1,
      \ 'col': a:col - 2,
      \ 'width': a:width + 4,
      \ 'height': a:height + 2,
      \ 'style': 'minimal'
    \ }

    let buf = nvim_create_buf(v:false, v:true)
    return nvim_open_win(buf, v:true, opts)
  endfunction

  function! CreateFozzieFloatingWindow(width, col, row)
    let row = a:row
    let col = a:col
    let width = a:width
    let height = a:row

    let opts = {
      \ 'relative': 'editor',
      \ 'row': row,
      \ 'col': col,
      \ 'width': width,
      \ 'height': height,
      \ 'style': 'minimal'
      \ }

    let buf = nvim_create_buf(v:false, v:true)
    let win = nvim_open_win(buf, v:true, opts)

    "Set Floating Window Highlighting
    call setwinvar(win, '&winhl', 'Normal:Pmenu')

    return win
  endfunction
else
  function! FozzieCommand(choice_command, vim_command, fozzie_args)
    try
      let output = system(a:choice_command . " | fozzie " . a:fozzie_args)
    catch /Vim:Interrupt/
      " Swallow errors from ^C, allow redraw! below
    endtry
    redraw!
    if v:shell_error == 0 && !empty(output)
      exec a:vim_command . ' ' . output
    endif
  endfunction
endif
