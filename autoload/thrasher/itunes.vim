scriptencoding utf-8
" Location: autoload/thrasher/itunes.vim
" Author:   Paul Meinhardt <https://github.com/pmeinhardt>

" Make sure we're running VIM version 8 or higher.
if exists('g:loaded_thrasher_itunes') || v:version < 800
    if v:version < 800
        echoerr 'Thrasher:refreshLibrary() is using async and requires VIM version 8 or higher'
    endif
    finish
endif
let g:loaded_thrasher_itunes = 1

" Helper functions
command! -nargs=1 Silent execute ':silent !'.<q-args> | execute ':redraw!'

function! s:saveVariable(var, file)
    " if !filewritable(a:file) | Silent touch a:file | endif
    call writefile([string(a:var)], a:file)
endfunction

function! s:restoreVariable(file)
    if filereadable(a:file)
        let l:recover = readfile(a:file)[0]
    else
        echoerr string(a:file) . ' not readable. Cannot restore variable!'
    endif
    execute 'let l:result = ' . l:recover
    return l:result
endfunction

function! s:getLibrary(mode, online)
    let l:jxa_path = s:files.Library_2
    if filereadable(s:files.Cache) | echom l:jxa_path | endif
    if a:mode
        if a:online
            call s:refreshLibrary(l:jxa_path, 'Music', 'Online')
        else
            call s:refreshLibrary(l:jxa_path, 'Music', 'Offline' )
        endif
    else
        if a:online
            call s:refreshLibrary(l:jxa_path, 'Library', 'Online')
        else
            call s:refreshLibrary(l:jxa_path, 'Library', 'Offline')
        endif
    endif
endfunction

" Async helpers

function! RefreshLibrary_JobEnd(channel)
    let s:cache = s:restoreVariable(g:thrasher_refreshLibrary)
    if !filewritable(s:files.Cache)
        Silent touch s:files.Cache
    endif
    call s:saveVariable(s:cache,s:files.Cache)
    call thrasher#refreshList()
    if filereadable(s:files.Cache) | echom 'iTunes Library refreshed' | endif
    unlet g:thrasher_refreshLibrary
endfunction

function! s:refreshLibrary(jxa, library, mode)
    if exists('g:thrasher_refreshLibrary')
        if g:thrasher_verbose | echom 'refreshLibrary task is already running in background' | endif
    else
        if g:thrasher_verbose | echom 'Refreshing iTunes Library in background' | endif
        let g:thrasher_refreshLibrary = tempname()
        let l:cmd = ['osascript', '-l', 'JavaScript',  a:jxa, a:library, a:mode]
        if g:thrasher_verbose | echom string(l:cmd) | endif
        if g:thrasher_verbose | echom string(g:thrasher_refreshLibrary) | endif
        let l:job = job_start(l:cmd, {'close_cb': 'RefreshLibrary_JobEnd', 'out_io': 'file', 'out_name': g:thrasher_refreshLibrary})
    endif
endfunction

" JavaScript for Automation helpers (Mac OS X)

function! s:jxa(code)
    let l:output = system("echo \"" . a:code . "\" | osascript -l JavaScript")
    return substitute(l:output, '\n$', '', '')
endfunction

" Calling external JXA scripts (compiled)
function! s:jxaexecutable(path)
    let l:output = system('osascript -l JavaScript ' . a:path )
    return substitute(l:output, '\n$', '', '')
endfunction

function! s:jxaescape(str)
    return escape(a:str, '\"''')
endfunction

" Thrasher commands (iTunes OS X)

let s:cache = []
" Folder in which scripts resides: (not safe for symlinks)
let s:dir = expand('<sfile>:p:h')
let s:files = {
\ 'Library_2':          s:dir . '/iTunes_Library_2.scpt',
\ 'Cache':              s:dir . '/Library_Cache.txt'
\ }

function! thrasher#itunes#init()
    " restore Music Library form disk file
    if filereadable(s:files.Cache) | let s:cache = s:restoreVariable(s:files.Cache) | endif
    " This is blocking version --> if empty(s:cache) | let s:cache = s:getLibrary(g:thrasher_mode) | endif
    " re-fill s:cache in the background
    call s:getLibrary(g:thrasher_mode, g:thrasher_online)
endfunction

function! thrasher#itunes#exit()
    " save Music Library to disk
    call s:saveVariable(s:cache, s:files.Cache)
    if g:thrasher_verbose | echom 'iTunes Library saved to file ' . s:files.Cache | endif
    let s:cache = []
endfunction

function! thrasher#itunes#search(query, mode)
    if empty(a:query) | return s:cache | endif
    
    let l:prop = (a:mode ==# 'track') ? 'name' : a:mode
    if l:prop ==# 'artist' || l:prop ==# 'collection' || l:prop ==# 'name'
        let l:filtfn = printf("match(v:val['" . l:prop . "'], '%s') >= 0", a:query)
    else
        let l:filtfn = printf("match(values(v:val), '%s') >= 0", a:query)
    endif

    let l:tracks = copy(s:cache)
    call filter(l:tracks, l:filtfn)

    return l:tracks
endfunction

function! thrasher#itunes#play(query)
    if !empty(a:query)
        if g:thrasher_verbose | echom  'PLAY 🎶 ' . a:query['name'] . ' : ' .  a:query['collection'] | endif
        return s:jxa("function run(argv) { let app = Application('iTunes'); let pl = app.playlists.byName('" . a:query["collection"] . "'); let tr = pl.tracks.byName('" . a:query["name"] . "'); pl.play(); app.stop(); tr.play();}")
    endif
endfunction

function! thrasher#itunes#pause()
    let l:error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.pause(); }")
endfunction

function! thrasher#itunes#toggle()
    let l:error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.playpause(); }")
endfunction

function! thrasher#itunes#stop()
    let l:error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.stop(); }")
endfunction

function! thrasher#itunes#next()
    let l:error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.nextTrack(); }")
endfunction

function! thrasher#itunes#prev()
    let l:error = s:jxa("function run(argv) { var app = Application('iTunes'); return app.backTrack(); }")
endfunction

function! thrasher#itunes#status()
    return eval(s:jxa("function run(argv) { var app = Application('iTunes'); var playerState = app.playerState(); try {var track = app.currentTrack(); return JSON.stringify({state: playerState, track: {name: track.name(), collection: track.album(), artist: track.artist()}});} catch(e) { return JSON.stringify({state: playerState, track: {name: '', collection: '', artist: ''} })}} "))
endfunction

function! thrasher#itunes#notify(message)
    let l:error = s:jxa("function run(argv) { let app = Application.currentApplication(); let info = '"  . a:message . "'; app.includeStandardAdditions = true; app.displayNotification(info, { withTitle: 'Thrasher' }); }")
endfunction

function! thrasher#itunes#refresh()
    call s:getLibrary(g:thrasher_mode, g:thrasher_online)
endfunction

function! thrasher#itunes#version()
    return eval(s:jxa("function run(argv) { var app = Application('iTunes'); return app.version(); }"))
endfunction


