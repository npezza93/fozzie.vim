if exists("g:fozzie_loaded")
  finish
endif

let g:fozzie_loaded = 1

if has('nvim')
  function! FozzieCommand(choice_command, vim_command, height, fozzie_args, border, background_color, border_color, text_color)
    if (float2nr(&columns) < 120)
      let width = float2nr(&columns) - 10
    else
      let width = float2nr(&columns) * 3 / 8
    endif

    execute 'hi FloatBorder guibg=' . a:background_color . ' guifg=' . a:border_color
    execute 'hi FozziePaddingWindow guibg=' . a:background_color . ' guifg=' . a:border_color
    execute 'hi FozzieWindow guibg=' . a:background_color . ' guifg=' . a:text_color

    let winid = win_getid()
    let s:float_term_padding_win = FozzieFloatingPaddingWindow(width, a:height, a:border)

    call CreateFozzieFloatingWindow(width, a:height)

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
      let cmd = a:choice_command . ' | fozzie ' . a:fozzie_args . ' > ' . file
      echom "Fozzie"
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

  function! FozzieFloatingPaddingWindow(width, height, border)
    let width = a:width + 4
    let height = a:height + 2
    let row = (&lines - height)/2
    let col = (&columns - width)/2

    let opts = {
      \ 'relative': 'editor',
      \ 'anchor': 'NW',
      \ 'row': row + 1,
      \ 'col': col + 1,
      \ 'width': width,
      \ 'height': height - 2,
      \ 'border': 'single',
      \ 'style': 'minimal'
    \ }

    let s:buf = nvim_create_buf(v:false, v:true)
    let win = nvim_open_win(s:buf, v:true, opts)
    call setwinvar(win, '&winhl', 'Normal:FozziePaddingWindow')

    return win
  endfunction

  function! CreateFozzieFloatingWindow(width, height)
    let row = (&lines - a:height)/2
    let col = (&columns - a:width)/2

    let opts = {
      \ 'relative': 'editor',
      \ 'anchor': 'NW',
      \ 'row': row + 1,
      \ 'col': col + 1,
      \ 'width': a:width,
      \ 'height': a:height,
      \ 'style': 'minimal'
      \ }

    let buf = nvim_create_buf(v:false, v:true)
    let win = nvim_open_win(buf, v:true, opts)

    "Set Floating Window Highlighting
    call setwinvar(win, '&winhl', 'Normal:FozzieWindow')

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
