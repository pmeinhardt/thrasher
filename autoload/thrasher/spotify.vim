if exists('g:loaded_thrasher_spotify')
  finish
endif
let g:loaded_thrasher_spotify = 1

function! thrasher#spotify#play()
  " let l:json = thrasher#jxa#run('function run() { console.log("meh"); }')

  let l:json = thrasher#jxa#run('function run() {
  \   var app = Application("iTunes");
  \   var lib = app.playlists.byName("Library");
  \   return JSON.stringify([42]);
  \ }')

  " \   return JSON.stringify(lib.tracks().map(function (t) {
  " \     return { id: t.id(), name: t.name() };
  " \   }));
  " \ }')

  call setline(1, l:json)
endfunction
