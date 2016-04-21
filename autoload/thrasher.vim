" Location: autoload/thrasher.vim
" Author:   Paul Meinhardt <https://github.com/pmeinhardt>

if exists("g:autoloaded_thrasher")
  finish
endif
let g:autoloaded_thrasher = 1

" Configuration

let s:bufname = "thrasher"

let s:hl = {
  \   "base":    "Comment",
  \   "cursor":  "Constant",
  \   "default": "Normal"
  \ }

" Variables

let s:active = 0

let s:state = {
  \   "player": "itunes",
  \   "input": ["", "", ""],
  \   "mode": "library"
  \ }

" Commands

function! s:dispatch(player, fname, ...)
  return call("thrasher#" . a:player . "#" . a:fname, a:000)
endfunction

function! thrasher#play(...)
  let query = {}

  if a:0 > 0
    let query.artist = get(a:000, 0, "")
    let query.album = get(a:000, 1, "")
    let query.track = get(a:000, 2, "")
  endif

  return s:dispatch(s:state.player, "play", query)
endfunction

function! thrasher#pause()
  return s:dispatch(s:state.player, "pause")
endfunction

function! thrasher#toggle()
  return s:dispatch(s:state.player, "toggle")
endfunction

function! thrasher#stop()
  return s:dispatch(s:state.player, "stop")
endfunction

function! thrasher#next()
  return s:dispatch(s:state.player, "next")
endfunction

function! thrasher#prev()
  return s:dispatch(s:state.player, "prev")
endfunction

function! thrasher#status()
  let status = s:dispatch(s:state.player, "status")
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
  nnoremap <buffer> <silent> <esc>    :call thrasher#exit()<cr>
  nnoremap <buffer> <silent> <c-c>    :call thrasher#exit()<cr>

  " nnoremap <buffer> <silent> <cr>     :call thrasher#play({ ... })<cr>

  nnoremap <buffer> <silent> <c-g>    :call thrasher#toggle()<cr>
  nnoremap <buffer> <silent> <c-f>    :call thrasher#next()<cr>
  nnoremap <buffer> <silent> <c-b>    :call thrasher#prev()<cr>

  nnoremap <buffer> <silent> <c-j>    :call <SID>movedown()<cr>
  nnoremap <buffer> <silent> <down>   :call <SID>movedown()<cr>
  nnoremap <buffer> <silent> <c-k>    :call <SID>moveup()<cr>
  nnoremap <buffer> <silent> <up>     :call <SID>moveup()<cr>
  nnoremap <buffer> <silent> <c-h>    :call <SID>moveleft()<cr>
  nnoremap <buffer> <silent> <left>   :call <SID>moveleft()<cr>
  nnoremap <buffer> <silent> <c-l>    :call <SID>moveright()<cr>
  nnoremap <buffer> <silent> <right>  :call <SID>moveright()<cr>
  nnoremap <buffer> <silent> <c-a>    :call <SID>movestart()<cr>
  nnoremap <buffer> <silent> <c-e>    :call <SID>moveend()<cr>
  nnoremap <buffer> <silent> <bs>     :call <SID>backspace()<cr>
  nnoremap <buffer> <silent> <del>    :call <SID>delchar()<cr>
  nnoremap <buffer> <silent> <c-w>    :call <SID>delword()<cr>
  nnoremap <buffer> <silent> <c-u>    :call <SID>delline()<cr>
  " ...

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
  call s:renderstatus(a:state)

  " render prompt
  call s:renderprompt(a:state)

  setlocal nomodifiable
endfunction

" Status-line

function! s:renderstatus(state)
  let &l:statusline = "thrasher"
endfunction

" Prompt

function! s:resetprompt()
  let s:state.input = ["", "", ""]
endfunction

function! s:renderprompt(state)
  let input = copy(a:state.input)
  let hlcursor = s:hl.cursor

  if input[1] ==# " "
    let hlcursor = s:hl.base
    let input[1] = "_"
  endif

  execute "echoh " . s:hl.default . " | echon '>>> '" .
    \ " | echoh " . s:hl.default . " | echon '" . input[0] . "'" .
    \ " | echoh " . hlcursor     . " | echon '" . input[1] . "'" .
    \ " | echoh " . s:hl.default . " | echon '" . input[2] . "'" .
    \ " | echoh None"

  if empty(input[1])
    execute "echoh " . s:hl.base . " | echon '_' | echoh None"
  endif
endfunction

function! s:keypress(char)
  let s:state.input[0] .= a:char
  call s:renderprompt(s:state)
endfunction

function! s:movedown()
endfunction

function! s:moveup()
endfunction

function! s:moveleft()
  let parts = s:state.input

  if !empty(parts[0])
    let s:state.input = [
      \   substitute(parts[0], ".$", "", ""),
      \   matchstr(parts[0], ".$"),
      \   parts[1] . parts[2]
      \ ]
  endif

  call s:renderprompt(s:state)
endfunction

function! s:moveright()
  let parts = s:state.input

  let s:state.input = [
    \   parts[0] . parts[1],
    \   matchstr(parts[2], "^."),
    \   substitute(parts[2], "^.", "", "")
    \ ]

  call s:renderprompt(s:state)
endfunction

function! s:movestart()
  let input = join(s:state.input, "")

  let s:state.input = [
    \   "",
    \   matchstr(input, "^.", ""),
    \   substitute(input, "^.", "", "")
    \ ]

  call s:renderprompt(s:state)
endfunction

function! s:moveend()
  let s:state.input = [join(s:state.input, ""), "", ""]
  call s:renderprompt(s:state)
endfunction

function! s:backspace()
  let s:state.input[0] = substitute(s:state.input[0], ".$", "", "")
  call s:renderprompt(s:state)
endfunction

function! s:delchar()
  let parts = s:state.input

  let s:state.input = [
    \   parts[0],
    \   matchstr(parts[2], "^."),
    \   substitute(parts[2], "^.", "", "")
    \ ]

  call s:renderprompt(s:state)
endfunction

function! s:delword()
  let s:state.input[0] = substitute(s:state.input[0], '\w\+\W*$', "", "")
  call s:renderprompt(s:state)
endfunction

function! s:delline()
  let s:state.input = ["", "", ""]
  call s:renderprompt(s:state)
endfunction
