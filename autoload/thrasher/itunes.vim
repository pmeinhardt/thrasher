" Location: autoload/thrasher/itunes.vim
" Author:   Paul Meinhardt <https://github.com/pmeinhardt>

" Make sure we're running VIM version 8 or higher.
if exists("g:loaded_thrasher_itunes") || v:version < 800
    if v:version < 800
        echoerr 'Thrasher:refreshLibrary() is using async and requires VIM version 8 or higher'
    endif
    finish
endif
let g:loaded_thrasher_itunes = 1

" Helper functions
function! s:saveVariable(var, file)
    if filewritable(a:file)
        call writefile([string(a:var)], a:file)
    endif
endfunction

function! s:restoreVariable(file)
    if filereadable(a:file)
        let recover = readfile(a:file)[0]
    else
        echoerr string(a:files) . " not readable. Cannot restore variable!"
    endif
    execute "let result = " . recover
    return result
endfunction

function! s:getLibrary(mode, online)
" TODO - add filtering On-line, Off-line Combine Music and Library (and
" Tracks?)
"   let s:path = s:files.Tracks[_Offline]
    if a:mode
        if a:online
            let s:path = s:files.Music
        else
            let s:path = s:files.Music_Offline
        endif
    else
        if a:online
            let s:path = s:files.Library
        else
            let s:path = s:files.Library_Offline
        endif
    endif
    
    if filereadable(s:path)
        call s:refreshLibrary(s:path)
        if g:thrasher_verbose | echom "Collecting iTunes Library can take a while" | endif
    else
        echoerr "search script: Cannot find JXA executable at " . s:path
    endif
endfunction

" Async helpers

function! RefreshLibraryJobEnd(channel)
    let s:cache = s:restoreVariable(g:thrasher_refreshLibrary)
    call thrasher#refreshList()  " call thrasher#itunes#init({}, s:state.mode)
    call s:saveVariable(s:cache, s:files.Cache)
    echom "iTunes Library refreshed"
    unlet g:thrasher_refreshLibrary
endfunction

function! s:refreshLibrary(path)
    if exists('g:thrasher_refreshLibrary')
        if g:thrasher_verbose | echom 'refreshLibrary task is already running in background' | endif
    else
        if g:thrasher_verbose | echom 'Refreshing iTunes Library in background' | endif
        let g:thrasher_refreshLibrary = tempname()
        let cmd = ['osascript', '-l', 'JavaScript',  a:path]
        if g:thrasher_verbose | echom string(cmd) | endif
        let job = job_start(cmd, {'close_cb': 'RefreshLibraryJobEnd', 'out_io': 'file', 'out_name': g:thrasher_refreshLibrary})
    endif
endfunction

function! s:outHandler(job, message)
    exec 'silent! cb! ' . g:makeBufNum  
endfunction

function! s:exitHandler(job, status)
    echom "NowPlaying finished"
endfunction

function! s:nowPlaying()
    if exists('g:thrasher_refreshLibrary')
        if g:thrasher_nowplaying | echom 'NowPlaying task is already running ' | endif
    else
        "create/wipe the buffer
        let currentBuf = bufnr('%')
        let g:makeBufNum = bufnr('nowplaying_buffer', 1)
        exec g:makeBufNum . 'bufdo %d'
        exec 'b ' . currentBuf

        "execute the job
        let cmd =  ['/Users/rrj/.virtualenvs/Music/bin/python', s:files.NowPlaying ]
        let job = job_start(cmd, {'out_io': 'buffer', 'out_name': 'nowplaying_buffer', 'out_cb': 'OutHandler', 'exit_cb': 'ExitHandler'})
    endif
endfunction

" JavaScript for Automation helpers (Mac OS X)

function! s:jxa(code)
    let output = system("echo \"" . a:code . "\" | osascript -l JavaScript")
    return substitute(output, "\n$", "", "")
endfunction

" Calling external JXA scripts (compiled) seems like overkill
" but wait.. We could use them in async. 
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
\ 'Music_Offline':      s:dir . '/iTunes_Music_Offline.scpt',
\ 'Music':              s:dir . '/iTunes_Music.scpt',
\ 'Library_Offline':    s:dir . '/iTunes_Library_Offline.scpt',
\ 'Library':            s:dir . '/iTunes_Library.scpt',
\ 'Tracks_Offline':     s:dir . '/iTunes_Tracks_Offline.scpt',
\ 'Tracks':             s:dir . '/iTunes_Tracks.scpt',
\ 'Cache':              s:dir . '/Library_Cache.txt',
\ 'NowPlaying':         s:dir . 'itunes_notifications.py'
\ }

function! thrasher#itunes#init()
    " restore Music Library form disk file
    if filereadable(s:files.Cache) | let s:cache = s:restoreVariable(s:files.Cache) | endif
    " this is blocking version --> if empty(s:cache) | let s:cache = s:getLibrary(g:thrasher_mode) | endif
    " re-fill s:cache in the background
    call s:getLibrary(g:thrasher_mode, g:thrasher_online)
endfunction

function! thrasher#itunes#exit()
    " save Music Library to disk
    call s:saveVariable(s:cache, s:files.Cache)
    if g:thrasher_verbose | echom "iTunes Library saved to file " . s:files.Cache | endif
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
        if g:thrasher_verbose | echom  "PLAY 🎶 " . a:query["name"] . " : " .  a:query["collection"] | endif
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

function! thrasher#itunes#nowplaying()
    call s:nowPlaying()
endfunction

function! thrasher#itunes#refresh()
    call s:getLibrary(g:thrasher_mode, g:thrasher_online)
endfunction

function! thrasher#itunes#version()
    return eval(s:jxa("function run(argv) { var app = Application('iTunes'); return app.version(); }"))
endfunction


