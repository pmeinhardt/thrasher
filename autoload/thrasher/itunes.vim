" Location: autoload/thrasher/itunes.vim
" Author:   Paul Meinhardt <https://github.com/pmeinhardt>

if exists("g:loaded_thrasher_itunes") || v:version < 700
    finish
endif
let g:loaded_thrasher_itunes = 1

" Helper functions
function! s:saveVariable(var, file)
    call writefile([string(a:var)], a:file)
endfunction

function! s:restoreVariable(file)
    let recover = readfile(a:file)[0]
    execute "let result = " . recover
    return result
endfunction

function! s:getLibrary(mode)
" TODO - add filtering On-line, Off-line Combine Music and Library (and
" Tracks?)
    if a:mode
        let s:library = s:files.Music
    else
        let s:library = s:files.Library
    endif
    " let s:library = s:files.Tracks
    if filereadable(s:library)
        if g:thrasher_verbose | echom "search script: " . s:library | endif
        echom "Thrasher: collecting iTunes Library takes a while"
        return eval(s:jxaexecutable(s:library))
    else
        echom "search script: Cannot find JXA executable at " . s:library
    endif
endfunction

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
\ 'Tracks':     s:dir . '/iTunes_Tracks.scpt',
\ 'Cache':      s:dir . '/Library_Cache.txt'
\ }

function! thrasher#itunes#init()
    let s:cache = s:restoreVariable(s:files.Cache)
    if empty(s:cache)
        let s:cache = s:getLibrary(g:thrasher_mode)
    endif
endfunction

function! thrasher#itunes#exit()
    call s:saveVariable(s:cache, s:files.Cache)
    if g:thrasher_verbose | echom "s:cache saved to file " . s:files.Cache | endif
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
        if g:thrasher_verbose | echom  "PLAY " . a:query["name"] . " / " .  a:query["collection"] | endif
        return s:jxa("function run(argv) { let app = Application('iTunes'); let pl = app.playlists.byName('" . a:query["collection"] . "'); let tr = pl.tracks.byName('" . a:query["name"] . "'); pl.play(); app.stop(); tr.play();}")
    endif
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
    return eval(s:jxa("function run(argv) { var app = Application('iTunes'); var playerState = app.playerState(); try {var track = app.currentTrack(); return JSON.stringify({state: playerState, track: {name: track.name(), collection: track.album(), artist: track.artist()}});} catch(e) { return JSON.stringify({state: playerState, track: {name: '', collection: '', artist: ''} })}} "))
endfunction

function! thrasher#itunes#notify(message)
    let error = s:jxa("function run(argv) { let app = Application.currentApplication(); let info = '"  . a:message . "'; app.includeStandardAdditions = true; app.displayNotification(info, { withTitle: 'Thrasher' }); }")
endfunction

function! thrasher#itunes#version()
    return eval(s:jxa("function run(argv) { var app = Application('iTunes'); return app.version(); }"))
endfunction


