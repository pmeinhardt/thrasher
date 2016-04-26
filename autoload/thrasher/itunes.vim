" Location: autoload/thrasher/itunes.vim
" Author:   Paul Meinhardt <https://github.com/pmeinhardt>

if exists("g:loaded_thrasher_itunes") || v:version < 700
  finish
endif
let g:loaded_thrasher_itunes = 1

" JavaScript for Automation helpers (Mac OS X)

function! s:jxa(code)
  let output = system("echo \"" . a:code . "\" | osascript -l JavaScript")
  return substitute(output, "\n$", "", "")
endfunction

function! s:jxaescape(str)
  return escape(a:str, '\"''')
endfunction

" Thrasher commands (iTunes OS X)

let s:cache = []

function! thrasher#itunes#init()
  if empty(s:cache)
    let s:cache = eval(s:jxa("function run(argv) { var app = Application('iTunes'); var lib = app.playlists.byName('Library'); return JSON.stringify(lib.tracks().map(function (t) { return {id: t.id(), name: t.name(), album: t.album(), artist: t.artist()}; })); }"))
  endif
endfunction

function! thrasher#itunes#exit()
  let s:cache = []
endfunction

function! thrasher#itunes#search(query, mode)
  if empty(a:query) | return s:cache | endif

  let prop = (a:mode ==# "track") ? "name" : a:mode

  if prop ==# "artist" || prop ==# "album" || prop ==# "name"
    let filtfn = printf("match(v:val['" . prop . "'], '%s') >= 0", a:query)
  else
    let filtfn = printf("match(values(v:val), '%s') >= 0", a:query)
  endif

  let tracks = copy(s:cache)
  call filter(tracks, filtfn)

  return tracks
endfunction

function! thrasher#itunes#play(query)
  if !empty(a:query)
    if has_key(a:query, "obj")
      return s:jxa("function run(argv) { var app = Application('iTunes'); var lib = app.playlists.byName('Library'); return app.play(lib.tracks.byId(" . a:query["obj"]["id"] . ")); }")
    else
      return s:jxa("function run(argv) { var app = Application('iTunes'); var lib = app.playlists.byName('Library'); var tracks = lib.search({for: 'Metallica', only: 'artists'}); return app.play(tracks[0]); }")
    endif
  endif
  return s:jxa("function run(argv) { var app = Application('iTunes'); return app.play(); }")
endfunction

function! thrasher#itunes#pause()
  let error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.pause(); }")
endfunction

function! thrasher#itunes#toggle()
  let error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.playpause(); }")
endfunction

function! thrasher#itunes#stop()
  let error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.stop(); }")
endfunction

function! thrasher#itunes#next()
  let error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.nextTrack(); }")
endfunction

function! thrasher#itunes#prev()
  let error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.backTrack(); }")
endfunction

function! thrasher#itunes#status()
  return eval(s:jxa("function run(argv) { var app = Application('iTunes'); var track = app.currentTrack(); return JSON.stringify({state: app.playerState(), track: {name: track.name(), album: track.album(), artist: track.artist()}}); }"))
endfunction
