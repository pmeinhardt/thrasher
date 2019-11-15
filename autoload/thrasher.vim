if exists('g:autoloaded_thrasher')
  finish
endif
let g:autoloaded_thrasher = 1

" Configuration

let s:bufname = 'thrasher'

" Variables

let s:state = {
  \   'player': 'spotify',
  \   'finder': 'ctrlp',
  \   'queue': []
  \ }

" Commands

function! s:dispatch(player, fname, ...)
  return call('thrasher#' . a:player . '#' . a:fname, a:000)
endfunction

function! thrasher#play()
  return s:dispatch(s:state.player, 'play')
endfunction

function! thrasher#pause()
  return s:dispatch(s:state.player, 'pause')
endfunction

function! thrasher#toggle()
  return s:dispatch(s:state.player, 'toggle')
endfunction

function! thrasher#next()
  return s:dispatch(s:state.player, 'next')
endfunction

function! thrasher#prev()
  return s:dispatch(s:state.player, 'prev')
endfunction

function! thrasher#search(query)
  " return s:dispatch(s:state.finder, 'search', a:query)
endfunction

function! thrasher#status()
  let l:status = s:dispatch(s:state.player, 'status')
  let l:track = status.track
  let l:info = join([track.name, track.album, track.artist], ', ')
  echo s:status.state . ': ' . l:info
endfunction

function! thrasher#run()
  " call into finder
  let l:results = thasher#search()
endfunction
