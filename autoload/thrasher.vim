" Location: autoload/thrasher.vim
" Author:   Paul Meinhardt <https://github.com/pmeinhardt>

if exists("g:autoloaded_thrasher")
  finish
endif
let g:autoloaded_thrasher = 1

" Configuration

let s:bufname = "thrasher"

let s:bufglobals = {
  \   "guicursor": "a:blinkon0",
  \   "hlsearch": 0,
  \   "ignorecase": 1,
  \   "imdisable": 1,
  \   "insertmode": 0,
  \   "langmap": "",
  \   "magic": 1,
  \   "maxfuncdepth": 200,
  \   "mousefocus": 0,
  \   "report": 9999,
  \   "showcmd": 0,
  \   "sidescroll": 0,
  \   "sidescrolloff": 0,
  \   "splitbelow": 1,
  \   "timeout": 1,
  \   "timeoutlen": 0,
  \   "ttimeout": 0
  \ }

let s:hl = {
  \   "base":    "Comment",
  \   "cursor":  "Constant",
  \   "default": "Normal"
  \ }

" Variables

let s:active = 0

let s:regglobals = {}

let s:state = {
  \   "player": "itunes",
  \   "input": ["", "", ""],
  \   "mode": "library",
  \   "list": []
  \ }

" Commands

function! s:dispatch(player, fname, ...)
  return call("thrasher#" . a:player . "#" . a:fname, a:000)
endfunction

function! thrasher#search(...)
  let query = {}

  if a:0 > 0
    let query.artist = get(a:000, 0, "")
    let query.album  = get(a:000, 1, "")
    let query.track  = get(a:000, 2, "")
  endif

  return s:dispatch(s:state.player, "search", query)
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

  " backup and override globals
  for [k, v] in items(s:bufglobals)
    if exists("+" . k)
      silent! execute "let s:regglobals['" . k . "'] = &" . k .
        \ " | let &" . k " = " . string(v)
    endif
  endfor

  " setup buffer config
  setlocal bufhidden=unload
  setlocal buftype=nofile
  setlocal colorcolumn=0
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

  nnoremap <buffer> <silent> <c-g>    :call thrasher#toggle()<cr>
  nnoremap <buffer> <silent> <c-f>    :call thrasher#next()<cr>
  nnoremap <buffer> <silent> <c-b>    :call thrasher#prev()<cr>

  nnoremap <buffer> <silent> <cr>     :call <sid>enter()<cr>

  nnoremap <buffer> <silent> <c-j>    :call <sid>movedown()<cr>
  nnoremap <buffer> <silent> <down>   :call <sid>movedown()<cr>
  nnoremap <buffer> <silent> <c-k>    :call <sid>moveup()<cr>
  nnoremap <buffer> <silent> <up>     :call <sid>moveup()<cr>
  nnoremap <buffer> <silent> <c-h>    :call <sid>moveleft()<cr>
  nnoremap <buffer> <silent> <left>   :call <sid>moveleft()<cr>
  nnoremap <buffer> <silent> <c-l>    :call <sid>moveright()<cr>
  nnoremap <buffer> <silent> <right>  :call <sid>moveright()<cr>
  nnoremap <buffer> <silent> <c-a>    :call <sid>movestart()<cr>
  nnoremap <buffer> <silent> <c-e>    :call <sid>moveend()<cr>
  nnoremap <buffer> <silent> <bs>     :call <sid>backspace()<cr>
  nnoremap <buffer> <silent> <del>    :call <sid>delchar()<cr>
  nnoremap <buffer> <silent> <c-w>    :call <sid>delword()<cr>
  nnoremap <buffer> <silent> <c-u>    :call <sid>delline()<cr>

  " correct arrow keys
  if has("termresponse") && v:termresponse =~? "\<esc>" ||
    \ &term =~? '\vxterm|<k?vt|gnome|screen|linux|ansi|tmux'
    for k in ["\A <up>", "\B <down>", "\C <right>", "\D <left>"]
      execute "nnoremap <buffer> <silent> <esc>[" . k
    endfor
  endif

  " accept input (ascii range 32 through 126)
  let mapcmd = 'nnoremap <buffer> <silent> <char-%d> :call <sid>%s("%s")<cr>'
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

  " restore globals
  for k in keys(s:bufglobals)
    if exists("+" . k)
      silent! execute "let &" . k . " = s:regglobals['" . k . "']"
    endif
  endfor

  " drop buffer information
  unlet! s:bufnr s:winw

  " clear echo line
  echo
endfunction

" Rendering

function! s:render(state)
  setlocal modifiable

  let tracks = a:state.list
  let length = len(tracks)

  " render track list
  silent! execute "%d _ | res" length

  if empty(tracks)
    call setline(1, "NO RESULTS")
  else
    let i = 1
    for t in tracks
      call setline(i, t.name)
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

  let [hldefault, hlcursor, hlbase] = [s:hl.default, s:hl.cursor, s:hl.base]

  if input[1] ==# " "
    let hlcursor = hlbase
    let input[1] = "_"
  endif

  execute "echoh " . hldefault . " | echon '>>> '" .
    \ " | echoh " . hldefault . " | echon '" . input[0] . "'" .
    \ " | echoh " . hlcursor  . " | echon '" . input[1] . "'" .
    \ " | echoh " . hldefault . " | echon '" . input[2] . "'" .
    \ " | echoh none"

  if empty(input[1])
    execute "echoh " . hlbase . " | echon '_' | echoh none"
  endif
endfunction

function! s:keypress(char)
  let s:state.input[0] .= a:char
  call s:renderprompt(s:state)
endfunction

function! s:movedown()
  execute "keepj norm! j"
endfunction

function! s:moveup()
  execute "keepj norm! k"
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

function! s:enter()
  let querystr = join(s:state.input, "")
  let results = thrasher#search(querystr)
  let s:state.list = results
  call s:render(s:state)
endfunction
