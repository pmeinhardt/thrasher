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

" TODO calling external JXA script (compiled) seems like overkill
" but wait.. I have something on my mind
function! s:jxaexecutable(path)
    let output = system('osascript -l JavaScript ' . a:path )
    return substitute(output, "\n$", "", "")
endfunction

function! s:jxaescape(str)
    return escape(a:str, '\"''')
endfunction

" Thrasher commands (iTunes OS X)

let s:cache = []
" Folder in which scripts resides: (not safe for symlinks)
let s:dir = expand('<sfile>:p:h')
let s:files = {
\ 'Music':      s:dir . '/iTunes_Music.scpt',
\ 'Library':    s:dir . '/iTunes_Library.scpt',
\ 'Tracks':     s:dir . '/iTunes_Tracks.scpt'
\ }

function! thrasher#itunes#init()
    if empty(s:cache)

        if g:thrasher_mode
            " Apple Music playlists [collection = Apple Music playlist]
            " (subscriptionPlaylist)
            let s:library = s:files.Music
        else
            " Library playlists [collection = Library playlist]
            " (userPlaylist)
            let s:library = s:files.Library
        endif
        " let s:library = s:files.Tracks
        " Not active -  Library tracks [colection = album]

        if filereadable(s:library)
            if g:thrasher_verbose | echom s:library | endif
            let s:cache = eval(s:jxaexecutable(s:library))
        else
            echom "Thrasher: Cannot find JXA executable " . s:library
        endif
    endif
endfunction

function! thrasher#itunes#exit()
    let s:cache = []
endfunction

function! thrasher#itunes#search(query, mode)
    if empty(a:query) | return s:cache | endif

    let prop = (a:mode ==# "track") ? "name" : a:mode

    if prop ==# "artist" || prop ==# "collection" || prop ==# "name"
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
        return s:jxa("function run(argv) { let app = Application('iTunes'); let pl = app.playlists.byName('" . a:query["collection"] . "'); let tr = pl.tracks.byName('" . a:query["name"] . "'); pl.play(); app.stop(); tr.play();}")
    endif
endfunction

        " " if has_key(a:query, "obj")
        " " return s:jxa("function run(argv) { var app = Application('iTunes'); var lib = app.playlists.byName('Library'); app.stop(); return app.play(lib.tracks.byId(" . a:query["obj"]["id"] . ")); }")
        " " Play Apple Music playlist by name
        " " return s:jxa("function run(argv) { var app = Application('iTunes'); var lib = app.playlists.byName('Library'); app.stop(); let pl= app.sources['Library'].subscriptionPlaylists['" . a:query["collection"] . "']; pl.play()}")
        
        " if g:thrasher_verbose | echom  a:query["name"] . " / " .  a:query["collection"] | endif
        " if g:thrasher_mode
        "     " Play playlist at track - by name
        "     return s:jxa("function run(argv) { let app = Application('iTunes'); let pl = app.playlists.byName('" . a:query["collection"] . "'); let tr = pl.tracks.byName('" . a:query["name"] . "'); pl.play(); app.stop(); tr.play();}")
        " else
        "     " Play single track - by id and fall back to queue
        "     return s:jxa("function run(argv) { let app = Application('iTunes'); let lib = app.playlists.byName('Library'); app.stop(); app.play(lib.tracks.byId(" . a:query["id"] . ")); }")
        " endif
    " endif
    " " As a fallback play from entire Library [0] = Music
    " return s:jxa("function run(argv) { let app = Application('iTunes'); let pl = app.sources['Library'].userPlaylists[0]; return pl.play(); }")

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
    return eval(s:jxa("function run(argv) { var app = Application('iTunes'); var playerState = app.playerState(); try {var track = app.currentTrack(); return JSON.stringify({state: playerState, track: {name: track.name(), collection: track.album(), artist: track.artist()}});} catch(e) { return JSON.stringify({state: playerState, track: {name: '', collection: '', artist: ''} })}} "))
endfunction

function! thrasher#itunes#version()
    return eval(s:jxa("function run(argv) { var app = Application('iTunes'); return app.version(); }"))
endfunction

function! thrasher#itunes#notify(message)
    if g:thrasher_verbose
        echom a:message
    endif
    let error = s:jxa("function run(argv) { let app = Application.currentApplication(); let info = '"  . a:message . "'; app.includeStandardAdditions = true; app.displayNotification(info, { withTitle: 'Thrasher' }); }")
endfunction
