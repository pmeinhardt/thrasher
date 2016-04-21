" Location: autoload/thrasher/itunes.vim
" Author:   Paul Meinhardt <https://github.com/pmeinhardt>

if exists("g:loaded_thrasher_itunes") || v:version < 700
  finish
endif
let g:loaded_thrasher_itunes = 1

" JavaScript for Automation helpers (Mac OS X)

function! s:jxa(code)
  let stdout = system("echo \"" . a:code . "\" | osascript -l JavaScript")
  return substitute(stdout, "\n$", "", "")
endfunction

" Thrasher commands (iTunes OS X)

function! thrasher#itunes#search(query)
  if !empty(a:query)
    return eval(s:jxa("function run(argv) { var app = Application('iTunes'); var lib = app.playlists.byName('Library'); var tracks = lib.search({for: '" . a:query.artist . "'}); return JSON.stringify(tracks.map(function (t) { return {id: t.id(), name: t.name(), album: t.album(), artist: t.artist()}; })); }"))
  endif
  " return s:jxa("function run(argv) { var app = Application('iTunes'); return app.play(); }")
  return []
endfunction

function! thrasher#itunes#play(query)
  if !empty(a:query)
    return s:jxa("function run(argv) { var app = Application('iTunes'); var lib = app.playlists.byName('Library'); var tracks = lib.search({for: 'Metallica', only: 'artists'}); return app.play(tracks[0]); }")
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
  return s:jxa("function run(argv) { var app = Application('iTunes'); var track = app.currentTrack(); return app.playerState() + ': ' + [track.name(), track.album(), track.artist()].join(' // '); }")
endfunction
