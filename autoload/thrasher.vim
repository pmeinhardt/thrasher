" Location: autoload/thrasher.vim
" Author:   Paul Meinhardt <https://github.com/pmeinhardt>

if exists("g:autoloaded_thrasher")
  finish
endif
let g:autoloaded_thrasher = 1

function! s:jxa(code)
  return system("echo \"" . a:code . "\" | osascript -l JavaScript")
endfunction

function! s:search(q)
  let output = s:jxa("function run(argv) { var app = Application('iTunes'); var lib = app.playlists.byName('Library'); var res = lib.search({for: 'Metallica', in: 'artists'}); return res.map(function (t) { return t.name(); }); }")
  return output
endfunction

function! thrasher#status()
  let output = s:jxa("function run(argv) { var app = Application('iTunes'); var track = app.currentTrack(); return app.playerState() + ': ' + [track.name(), track.album(), track.artist()].join(' // '); }")
  echom substitute(output, "\n$", "", "")
  echom s:search("Metallica")
endfunction

function! thrasher#play()
  let error = s:jxa("function run(argv) { var app = Application('iTunes'); var lib = app.playlists.byName('Library'); var tracks = lib.tracks.whose({artist: 'Metallica'}); return app.play(tracks[0]); }")
endfunction

function! thrasher#pause()
  let error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.pause(); }")
endfunction

function! thrasher#stop()
  let error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.stop(); }")
endfunction

function! thrasher#next()
  let error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.nextTrack(); }")
endfunction

function! thrasher#prev()
  let error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.previousTrack(); }")
endfunction

" let g:ThrasherLogo = [
"   \ "                                    ,'",
"   \ "                                 .c0: ",
"   \ "                               .dNX'  ",
"   \ "                ..           ,kMM0.   ",
"   \ "               'KX'       .cKMMMd.    ",
"   \ "              :WMMWl.   .oNMMMWc      ",
"   \ "            .xMMMMMM0.,kWMMMMN,       ",
"   \ "           .KMMMMMMMMMMMMMMM0.        ",
"   \ "          ;NMMMMMMMMMMMMMMMx.         ",
"   \ "        .oMMMMMMXMMMMMMMMWl           ",
"   \ "       .0MMMMWk' cWMMMMMN,            ",
"   \ "      ,NMMMXl.    ,NMMMK.             ",
"   \ "     oMMMO;.       .0Mk.              ",
"   \ "   .OMWd.           .;                ",
"   \ "  'XKc.                               ",
"   \ " ck,                                  ",
"   \ "..                                    "
"   \ ]

let g:ThrasherBufName = "thrasher"

function! thrasher#show()
  silent! execute "edit " . g:ThrasherBufName

  setlocal noswapfile
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal nowrap
  setlocal foldcolumn=0
  setlocal foldmethod=manual
  setlocal nofoldenable
  setlocal nobuflisted
  setlocal nospell
  setlocal nonu
  setlocal nornu

  iabc <buffer>

  let i = 1
  for l in g:ThrasherLogo
    call setline(i, l)
    let i += 1
  endfor

  setlocal filetype=thrasher
endfunction
