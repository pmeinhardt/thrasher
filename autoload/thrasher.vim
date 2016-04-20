" Location: autoload/thrasher.vim
" Author:   Paul Meinhardt <https://github.com/pmeinhardt>

if exists("g:autoloaded_thrasher")
  finish
endif
let g:autoloaded_thrasher = 1

" Configuration

let s:bufname = "thrasher"

" Variables

let s:active = 0

let s:state = {
  \   "player": "itunes",
  \   "mode": "library",
  \   "input": ""
  \ }

" Actions

function! thrasher#play(...)
  let query = {}

  if a:0 > 0
    let query.artist = get(a:000, 0, "")
    let query.album = get(a:000, 1, "")
    let query.track = get(a:000, 2, "")
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

function! thrasher#run()
  if s:active | return 0 | endif
  let s:active = 1

  noautocmd call s:open()
  call s:render(s:state)

  return 1
endfunction

function! thrasher#exit()
  if s:active && bufnr("%") ==# s:bufnr && bufname("%") ==# s:bufname
    noautocmd call s:close()
    call s:resetprompt()
    let s:active = 0
    return 1
  endif

  return 0
endfunction

function! s:open()
  " open new window (bottom)
  silent! execute "keepa botright 1new " . s:bufname

  " store buffer information
  let s:bufnr = bufnr("%")
  let s:winw = winwidth(0)

  " remove all abbreviations
  abclear <buffer>

  " setup buffer config
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
  nnoremap <buffer> <silent> <esc> :call thrasher#exit()<cr>
  nnoremap <buffer> <silent> <c-c> :call thrasher#exit()<cr>

  " nnoremap <buffer> <silent> <cr> :call thrasher#play({ ... })<cr>

  nnoremap <buffer> <silent> . :call thrasher#toggle()<cr>

  nnoremap <buffer> <silent> > :call thrasher#next()<cr>
  nnoremap <buffer> <silent> <c-l> :call thrasher#next()<cr>

  nnoremap <buffer> <silent> < :call thrasher#prev()<cr>
  nnoremap <buffer> <silent> <c-h> :call thrasher#prev()<cr>

  nnoremap <buffer> <silent> <c-j> :call <SID>movedown()<cr>
  nnoremap <buffer> <silent> <down> :call <SID>movedown()<cr>
  nnoremap <buffer> <silent> <c-k> :call <SID>moveup()<cr>
  nnoremap <buffer> <silent> <up> :call <SID>moveup()<cr>

  " accept input (ascii range 32 through 126)
  let mapcmd = 'nnoremap <buffer> <silent> <char-%d> :call <SID>%s("%s")<cr>'
  let keyfn = 'keypress'

  for code in range(32, 33) + range(35, 91) + range(93, 123) + range(125, 126)
    execute printf(mapcmd, code, keyfn, nr2char(code))
  endfor

  for code in [34, 92, 124]
    execute printf(mapcmd, code, keyfn, escape(nr2char(code), '"|\'))
  endfor
endfunction

function! s:close()
  bunload! "" . s:bufname
  unlet! s:bufnr s:winw
  echo
endfunction

" Rendering

function! s:render(state)
  setlocal modifiable

  let tracks = ["Whiplash", "Hit The Lights", "No Remorse"]
  let length = len(tracks)

  " render track list
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

  " adapt status line (show library vs. playlist etc.)
  let &l:statusline = "thrasher"

  " render prompt
  call s:renderprompt(a:state)

  setlocal nomodifiable
endfunction

" Prompt

function! s:renderprompt(state)
  echon ">>> " | echon a:state.input | echon "_"
endfunction

function! s:resetprompt()
  let s:state.input = ""
endfunction

function! s:keypress(char)
  let s:state.input .= a:char
  call s:renderprompt(s:state)
endfunction

function! s:movedown()
endfunction

function! s:moveup()
endfunction

function! s:moveleft()
endfunction

function! s:moveright()
endfunction

function! s:delchar()
endfunction
