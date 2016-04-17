" Location: autoload/thrasher.vim
" Author:   Paul Meinhardt <https://github.com/pmeinhardt>

if exists("g:autoloaded_thrasher")
  finish
endif
let g:autoloaded_thrasher = 1

" Configuration

let g:ThrasherBufName = "thrasher"

let g:ThrasherState = {"player": "itunes"}

" Actions

function! thrasher#status()
  return thrasher#itunes#status()
endfunction

function! thrasher#play()
  return thrasher#itunes#play()
endfunction

function! thrasher#pause()
  return thrasher#itunes#pause()
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

function! thrasher#run()
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
  silent! execute "keepa botright 1new " . g:ThrasherBufName

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
endfunction

function! s:close()
  bunload! "" . g:ThrasherBufName
  unlet! s:active s:bufnr s:winw
  echo
endfunction

" Rendering

function! s:render(status)
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
  let &l:stl = "library search"

  " render prompt
  echon ">>> "
  echon "_"

  setlocal nomodifiable
endfunction
