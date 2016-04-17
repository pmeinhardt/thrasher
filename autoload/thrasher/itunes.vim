" Location: autoload/thrasher/itunes.vim
" Author:   Paul Meinhardt <https://github.com/pmeinhardt>

if exists("g:loaded_thrasher_itunes") || v:version < 700
  finish
endif
let g:loaded_thrasher_itunes = 1

" JavaScript for Automation helpers (Mac OS X)

function! s:jxa(code)
  return system("echo \"" . a:code . "\" | osascript -l JavaScript")
endfunction

function! s:search(q)
  let output = s:jxa("function run(argv) { var app = Application('iTunes'); var lib = app.playlists.byName('Library'); var res = lib.search({for: 'Metallica', in: 'artists'}); return res.map(function (t) { return t.name(); }); }")
  return output
endfunction

" Thrasher commands (iTunes OS X)

function! thrasher#itunes#status()
  let output = s:jxa("function run(argv) { var app = Application('iTunes'); var track = app.currentTrack(); return app.playerState() + ': ' + [track.name(), track.album(), track.artist()].join(' // '); }")
  " echom substitute(output, "\n$", "", "")
endfunction

function! thrasher#itunes#play()
  let error = s:jxa("function run(argv) { var app = Application('iTunes'); var lib = app.playlists.byName('Library'); var tracks = lib.tracks.whose({artist: 'Metallica'}); return app.play(tracks[0]); }")
endfunction

function! thrasher#itunes#pause()
  let error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.pause(); }")
endfunction

function! thrasher#itunes#stop()
  let error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.stop(); }")
endfunction

function! thrasher#itunes#next()
  let error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.nextTrack(); }")
endfunction

function! thrasher#itunes#prev()
  let error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.previousTrack(); }")
endfunction
