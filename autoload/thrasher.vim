" Location: autoload/thrasher.vim
" Author:   Paul Meinhardt <https://github.com/pmeinhardt>

if exists("g:autoloaded_thrasher")
  finish
endif
let g:autoloaded_thrasher = 1

" Configuration

let s:bufname = "thrasher"

let s:state = {
  \   "player": "itunes",
  \   "input": ""
  \ }

" Actions

function! thrasher#play(...)
  let query = {}

  if a:0 > 0
    let query.artist = "metallica"
    let query.album = ""
    let query.track = ""
  endif

  return thrasher#itunes#play(query)
endfunction

function! thrasher#pause()
  return thrasher#itunes#pause()
endfunction

function! thrasher#toggle()
  return thrasher#itunes#toggle()
endfunction

function! thrasher#stop()
  return thrasher#itunes#stop()
endfunction

function! thrasher#next()
  return thrasher#itunes#next()
endfunction

function! thrasher#prev()
  return thrasher#itunes#prev()
endfunction

function! thrasher#status()
  let status = thrasher#itunes#status()
  " format and display status information
  echo status
endfunction

" Interface

function! thrasher#run(...)
  if exists("s:active") | return 0 | endif
  let s:active = 1

  noautocmd call s:open()
  call s:render({})

  return 1
endfunction

function! thrasher#exit()
  if bufnr("%") ==# s:bufnr && bufname("%") ==# "thrasher"
    noautocmd call s:close()
  endif
endfunction

function! s:open()
  " open new window (bottom)
  silent! execute "keepa botright 1new " . s:bufname

  let s:bufnr = bufnr("%")
  let s:winw = winwidth(0)

  " remove all abbreviations
  abclear <buffer>

  " setup buffer
  setlocal bufhidden=unload
  setlocal buftype=nofile
  setlocal foldcolumn=0
  setlocal foldlevel=99
  setlocal foldmethod=manual
  setlocal nobuflisted
  setlocal nocursorcolumn
  setlocal nofoldenable
  setlocal nolist
  setlocal nonumber
  setlocal norelativenumber
  setlocal nospell
  setlocal noswapfile
  setlocal noundofile
  setlocal nowrap
  setlocal textwidth=0
  setlocal winfixheight

  " set custom filetype
  setlocal filetype=thrasher

  " install key mappings
  nnoremap <buffer> <silent> <esc> :call <SID>close()<cr>
  nnoremap <buffer> <silent> <c-c> :call <SID>close()<cr>

  " nnoremap <buffer> <silent> <cr> :call thrasher#play({})<cr>

  " accept input
  call s:keyloop()
endfunction

function! s:close()
  bunload! "" . s:bufname
  unlet! s:active s:bufnr s:winw
  echo
endfunction

" Rendering

function! s:render(state)
  setlocal modifiable

  " render track list
  let tracks = ["Whiplash", "Hit The Lights", "No Remorse"]
  let length = len(tracks)

  silent! execute "%d _ | res" length

  if empty(tracks)
    "
  else
    let i = 1
    for t in tracks
      call setline(i, t)
      let i += 1
    endfor
  endif

  " adapt status line
  let &l:statusline = "library search"

  " render prompt
  echon ">>> "
  echon a:state.input
  echon "_"

  setlocal nomodifiable
endfunction

" Prompt

function! s:keyloop()
  let [tve, guicursor] = [&t_ve, &guicursor]
  while exists("s:active")
    try
      set t_ve=
      set guicursor=a:NONE
      let nr = getchar()
    finally
      let &t_ve = tve
      let &guicursor = guicursor
    endtry
    let char = !type(nr) ? nr2char(nr) : nr
    if nr >=# 0x20
      call s:promptadd(char)
    else
    endif
  endwhile
endfunction

function! s:promptadd(char)
  let s:state.input .= a:char
  echo s:state
  call s:render(s:state)
endfunction
