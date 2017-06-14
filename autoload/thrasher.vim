scriptencoding utf-8
" Location: autoload/thrasher.vim
" Author:   Paul Meinhardt <https://github.com/pmeinhardt>

if exists('g:autoloaded_thrasher')
    finish
endif
let g:autoloaded_thrasher = 1

if !executable('osascript')
    echom ('Thrasher: Cannot find osascript')
    finish
endif

if !exists('g:thrasher_online')
    " Browse all tracks (also not downloaded)
    " Not First World problem but I have been developing this code in Sumatra
    " with spotty internet at best and occasional power cuts
    let g:thrasher_online = 1
endif

if !exists(' g:thrasher_mode')
    " 0 - search iTunes Library by playlists (userPlaylists in Apple parlance)
    " 1 - search Apple Music playlists (subscriptionPlaylists)
    " there is potential for mode 2 - not coded into logic at the moment
    " - search tracks by albums (in iTunes Library - this is how original Thrasher worked
    let g:thrasher_mode = 0
endif

" Configuration

let s:bufname = 'thrasher'

let s:bufglobals = {
            \   'guicursor': 'a:blinkon0',
            \   'hlsearch': 0,
            \   'ignorecase': 1,
            \   'imdisable': 1,
            \   'insertmode': 0,
            \   'langmap': '',
            \   'magic': 1,
            \   'maxfuncdepth': 200,
            \   'mousefocus': 0,
            \   'report': 9999,
            \   'showcmd': 0,
            \   'sidescroll': 0,
            \   'sidescrolloff': 0,
            \   'splitbelow': 1,
            \   'timeout': 1,
            \   'timeoutlen': 0,
            \   'ttimeout': 0
            \ }

let s:hl = {
            \   'base':    'Comment',
            \   'cursor':  'Constant',
            \   'default': 'Normal'
            \ }

let s:modes = [
            \   'any',
            \   'artist',
            \   'collection',
            \   'track',
            \ ]

" Variables

let s:active = 0
let s:cursorpos = [0, 1, 1, 0]

let s:regglobals = {}

let s:state = {
            \   'player': 'itunes',
            \   'input': ['', '', ''],
            \   'focus': 1,
            \   'mode': s:modes[0],
            \   'list': []
            \ }

" Commands

function! s:dispatch(player, fname, ...)
    return call('thrasher#' . a:player . '#' . a:fname, a:000)
endfunction

function! thrasher#search(query, mode)
    return s:dispatch(s:state.player, 'search', a:query, a:mode)
endfunction

function! thrasher#play(query)
    return s:dispatch(s:state.player, 'play', a:query)
endfunction

" function! thrasher#play(...)
"   let query = {}

"   if a:0 > 0
"     let query.artist = get(a:000, 0, '')
"     let query.album = get(a:000, 1, '')
"     let query.track = get(a:000, 2, '')
"   endif

"   return s:dispatch(s:state.player, 'play', query)
" endfunction

function! thrasher#pause()
    return s:dispatch(s:state.player, 'pause')
endfunction

function! thrasher#toggle()
    return s:dispatch(s:state.player, 'toggle')
endfunction

function! thrasher#stop()
    return s:dispatch(s:state.player, 'stop')
endfunction

function! thrasher#next()
    return s:dispatch(s:state.player, 'next')
endfunction

function! thrasher#prev()
    return s:dispatch(s:state.player, 'prev')
endfunction

function! thrasher#status()
    let l:status = s:dispatch(s:state.player, 'status')
    " let track = status.track
    " let info = join([track.name, track.collection, track.artist], ", ")
    " if g:thrasher_verbose | echom status.state . ": " . info | endif
    " if g:thrasher_notify
    "     return s:dispatch(s:state.player, 'notify', status.state . ": " . info)
    " else
    "     return strpart(status.state . ": " . info, 0, 45)
    " endif
    if l:status.state ==# 'playing'
        let l:track = l:status.track
        let l:info = join([l:track.name, l:track.collection, l:track.artist], ', ')
        return strpart(l:status.state . ': ' . l:info, 0, 45)
    else
         return l:status.state
    endif
endfunction

function! thrasher#refresh()
    return s:dispatch(s:state.player, 'refresh')
endfunction

function! thrasher#refreshList()
    " this (after async Library refresh) will re-fill s:state.list
    " let s:state.list = thrasher#search({}, s:state.mode)
    if s:open
        call s:keypress('')
    endif
endfunction

function! thrasher#librarytoggle()
" Toggle Apple Music/iTunes Library and refresh List Cache
    if g:thrasher_mode
        let g:thrasher_mode = 0
    else
        let g:thrasher_mode = 1
    endif
    return s:dispatch(s:state.player, 'refresh')
endfunction

function! thrasher#onlinetoggle()
" Toggle On-line and refresh List Cache
    if g:thrasher_online
        let g:thrasher_online = 0
    else
        let g:thrasher_online = 1
    endif
    return s:dispatch(s:state.player, 'refresh')
endfunction

" Interface/

function! thrasher#run()
    if s:active | return 0 | endif
    let s:active = 1

    call s:dispatch(s:state.player, 'init')
    let s:state.list = thrasher#search({}, s:state.mode)

    noautocmd call s:open()
    call s:render(s:state)
    call setpos('.', s:cursorpos)

    return 1
endfunction

function! thrasher#exit()
    if s:active && bufnr('%') ==# s:bufnr && bufname('%') ==# s:bufname
        let s:cursorpos = getpos('.')
        noautocmd call s:close()
        " noautocmd call s:dispatch(s:state.player, 'exit')
        let s:active = 0
    return 1
    endif

    return 0
endfunction

function! s:open()
    " open new window (bottom)
    silent! execute 'keepalt botright 1new ' . s:bufname

    " store buffer information
    let s:bufnr = bufnr('%')
    let s:winw = winwidth(0)

    " remove all abbreviations
    abclear <buffer>

    " backup and override globals
    for [l:k, l:v] in items(s:bufglobals)
        if exists('+' . l:k)
            silent! execute "let s:regglobals['" . l:k . "'] = &" . l:k .
                        \ ' | let &' . l:k ' = ' . string(l:v)
        endif
    endfor

    " setup buffer config
    setlocal bufhidden=unload
    setlocal buftype=nofile
    setlocal colorcolumn=0
    setlocal foldcolumn=0
    setlocal foldlevel=99
    setlocal foldmethod=manual
    setlocal nobuflisted
    setlocal nocursorcolumn
    setlocal nofoldenable
    setlocal nolist
    setlocal nonumber
    setlocal norelativenumber
    setlocal nospell
    setlocal noswapfile
    setlocal noundofile
    setlocal nowrap
    setlocal textwidth=0
    setlocal winfixheight

    " set custom filetype
    setlocal filetype=thrasher

    " install common key mappings
    nnoremap <buffer> <silent> <s-tab> :<c-u>call <sid>togglefocus()<cr>

    " correct arrow keys
    if has('termresponse') && v:termresponse =~? '\<esc>' ||
                \ &term =~? '\vxterm|<k?vt|gnome|screen|linux|ansi|tmux'
        for l:k in ['\A <up>', '\B <down>', '\C <right>', '\D <left>']
            execute 'nnoremap <buffer> <silent> <esc>[' . l:k
        endfor
    endif

    " set focus
    call s:focus()
    let s:open = 1
endfunction

function! s:close()
    bunload! "" . s:bufname

    " restore globals
    for l:k in keys(s:bufglobals)
        if exists('+' . l:k)
            silent! execute "let &" . l:k . " = s:regglobals['" . l:k . "']"
        endif
    endfor

    " drop buffer information
    unlet! s:bufnr s:winw

    " clear echo line
    echo
    let s:open = 0
endfunction

function! s:focus()
    let s:state.focus = 1

    " install prompt key mappings
    nnoremap <buffer> <silent> <esc>    :<c-u>call thrasher#exit()<cr>
    nnoremap <buffer> <silent> <c-c>    :<c-u>call thrasher#exit()<cr>

    nnoremap <buffer> <silent> <c-g>    :<c-u>call thrasher#toggle()<cr>
    nnoremap <buffer> <silent> <c-f>    :<c-u>call thrasher#next()<cr>
    nnoremap <buffer> <silent> <c-b>    :<c-u>call thrasher#prev()<cr>

    nnoremap <buffer> <silent> <cr>     :<c-u>call <sid>accept()<cr>
    nnoremap <buffer> <silent> <c-o>    :<c-u>call <sid>accept()<cr>

    nnoremap <buffer> <silent> <c-v>    :<c-u>call <sid>modeswitch()<cr>

    nnoremap <buffer> <silent> <c-j>    :<c-u>call <sid>movedown()<cr>
    nnoremap <buffer> <silent> <down>   :<c-u>call <sid>movedown()<cr>
    nnoremap <buffer> <silent> <c-k>    :<c-u>call <sid>moveup()<cr>
    nnoremap <buffer> <silent> <up>     :<c-u>call <sid>moveup()<cr>
    nnoremap <buffer> <silent> <c-h>    :<c-u>call <sid>moveleft()<cr>
    nnoremap <buffer> <silent> <left>   :<c-u>call <sid>moveleft()<cr>
    nnoremap <buffer> <silent> <c-l>    :<c-u>call <sid>moveright()<cr>
    nnoremap <buffer> <silent> <right>  :<c-u>call <sid>moveright()<cr>
    nnoremap <buffer> <silent> <c-a>    :<c-u>call <sid>movestart()<cr>
    nnoremap <buffer> <silent> <c-e>    :<c-u>call <sid>moveend()<cr>
    nnoremap <buffer> <silent> <bs>     :<c-u>call <sid>backspace()<cr>
    nnoremap <buffer> <silent> <del>    :<c-u>call <sid>delchar()<cr>
    nnoremap <buffer> <silent> <c-w>    :<c-u>call <sid>delword()<cr>
    nnoremap <buffer> <silent> <c-u>    :<c-u>call <sid>delline()<cr>
    "
    " accept input (ascii range 32 through 126)
    let l:mapcmd = 'nnoremap <buffer> <silent> <char-%d> ' .
                \ ':<c-u>call <sid>%s("%s")<cr>'

    let l:keyfn = 'keypress'

    for l:code in range(32, 33) + range(35, 91) + range(93, 123) + range(125, 126)
        execute printf(l:mapcmd, l:code, l:keyfn, nr2char(l:code))
    endfor

    for l:code in [34, 92, 124]
        execute printf(l:mapcmd, l:code, l:keyfn, escape(nr2char(l:code), '"|\'))
    endfor

    " update prompt
    call s:renderprompt(s:state)
endfunction

function! s:unfocus()
    let s:state.focus = 0

    " disable prompt key mappings
    nunmap <buffer> <c-j>
    nunmap <buffer> <down>
    nunmap <buffer> <c-k>
    nunmap <buffer> <up>
    nunmap <buffer> <c-h>
    nunmap <buffer> <left>
    nunmap <buffer> <c-l>
    nunmap <buffer> <right>
    nunmap <buffer> <c-a>
    nunmap <buffer> <c-e>
    nunmap <buffer> <bs>
    nunmap <buffer> <del>
    nunmap <buffer> <c-w>
    nunmap <buffer> <c-u>
    " 
    " disable prompt input
    let l:unmapcmd = 'nunmap <buffer> <silent> <char-%d>'

    for l:code in range(32, 126)
        execute printf(l:unmapcmd, l:code)
    endfor

    " update prompt
    call s:renderprompt(s:state)
endfunction

function! s:togglefocus()
    if s:state.focus
        call s:unfocus()
    else
        call s:focus()
    endif
endfunction

" Control

function! s:research(state)
    let l:querystr = join(a:state.input, '')
    let l:mode = a:state.mode
    let a:state.list = thrasher#search(l:querystr, l:mode)
endfunction

function! s:modeswitch()
    let l:idx = (index(s:modes, s:state.mode) + 1) % len(s:modes)
    let s:state.mode = s:modes[l:idx]

    call s:research(s:state)

    call s:renderbuffer(s:state)
    call s:renderstatus(s:state)
endfunction

function! s:accept()
    if empty(s:state.list) | return | endif
    let l:index = line('.') - 1
    " call thrasher#play({"obj": s:state.list[l:index]})
    if g:thrasher_verbose | echom 'Playing from collection: ' .  s:state.list[l:index]['collection'] | endif
    call thrasher#play(s:state.list[l:index])
endfunction

" Rendering

function! s:render(state)
    call s:renderbuffer(a:state)
    call s:renderstatus(a:state)
    call s:renderprompt(a:state)
endfunction

" Buffer

function! s:renderbuffer(state)
    setlocal modifiable

    let l:tracks = a:state.list
    let l:length = len(l:tracks)

    silent! execute '%d _ | res' l:length

    if empty(l:tracks)
        setlocal nocursorline
        if !exists('g:thrasher_refreshLibrary') 
            call setline(1, 'NO RESULTS')
        else
            call setline(1, 'Getting playlists and tracks from iTunes Library for the first time may take a while.')
        endif
    else
        setlocal cursorline
        let l:i = 1
        for l:t in l:tracks
            call setline(l:i, l:t.collection . ' : ' . l:t.name . ' [' . l:t.artist . ']' )
            let l:i += 1
        endfor
    endif

    setlocal nomodifiable
endfunction

" Status-line

function! s:renderstatus(state)

    let l:library = ' [Apple Music]'
    if !g:thrasher_mode | let l:library = ' [iTunes Library]' | endif
    let l:online = ' [On-line] '
    if !g:thrasher_online | let l:online = ' [Off-line] ' | endif
    let l:status = thrasher#status()

    let l:base = 'thrasher [ ' . join(s:modes, ' ') . ' ] ' . len(a:state.list)  . l:library . l:online . l:status
    let l:line = substitute(l:base, a:state.mode, '<' . a:state.mode . '>', '')

    let &l:statusline = l:line
endfunction

" Prompt

function! s:renderprompt(state)
    let l:input = copy(a:state.input)

    let [l:hldefault, l:hlcursor, l:hlbase] = [s:hl.default, s:hl.cursor, s:hl.base]

    if l:input[1] ==# ' '
        let l:hlcursor = l:hlbase
        let l:input[1] = '_'
    endif

    if has('multi_byte')
        let l:prompt = a:state.focus ? '⚡️>>' : '🎸__'
    else
        let l:prompt = a:state.focus ? '>>>' : '---'
    endif

    execute "echoh " . l:hlbase . " | echon '" . l:prompt . "'" .
                \ " | echoh " . l:hldefault . " | echon '" . input[0] . "'" .
                \ " | echoh " . l:hlcursor  . " | echon '" . input[1] . "'" .
                \ " | echoh " . l:hldefault . " | echon '" . input[2] . "'" .
                \ " | echoh None"

    if empty(l:input[1])
        execute "echoh " . l:hlbase . " | echon '_' | echoh None"
    endif
endfunction

function! s:keypress(char)
    let s:state.input[0] .= a:char
    call s:research(s:state)
    call s:render(s:state)
endfunction

function! s:backspace()
    let s:state.input[0] = substitute(s:state.input[0], ".$", "", "")
    call s:research(s:state)
    call s:render(s:state)
endfunction

function! s:delchar()
    let prev = s:state.input

    let s:state.input = [
                \   prev[0],
                \   matchstr(prev[2], "^."),
                \   substitute(prev[2], "^.", "", "")
                \ ]

    call s:research(s:state)
    call s:render(s:state)
endfunction

function! s:delword()
    let s:state.input[0] = substitute(s:state.input[0], '\w\+\W*$', "", "")
    call s:research(s:state)
    call s:render(s:state)
endfunction

function! s:delline()
    let s:state.input = ["", "", ""]
    call s:research(s:state)
    call s:render(s:state)
endfunction

function! s:movedown()
    execute "keepjumps norm! j"
endfunction

function! s:moveup()
    execute "keepjumps norm! k"
endfunction

function! s:moveleft()
    if empty(s:state.input[0]) | return | endif

    let prev = s:state.input
    let s:state.input = [
                \   substitute(prev[0], ".$", "", ""),
                \   matchstr(prev[0], ".$"),
                \   prev[1] . prev[2]
                \ ]

    call s:renderprompt(s:state)
endfunction

function! s:moveright()
    if empty(s:state.input[1]) | return | endif

    let prev = s:state.input
    let s:state.input = [
                \   prev[0] . prev[1],
                \   matchstr(prev[2], "^."),
                \   substitute(prev[2], "^.", "", "")
                \ ]

    call s:renderprompt(s:state)
endfunction

function! s:movestart()
    if empty(s:state.input[0]) | return | endif

    let input = join(s:state.input, "")
    let s:state.input = [
                \   "",
                \   matchstr(input, "^.", ""),
                \   substitute(input, "^.", "", "")
                \ ]

    call s:renderprompt(s:state)
endfunction

function! s:moveend()
    if empty(s:state.input[1]) | return | endif
    let s:state.input = [join(s:state.input, ""), "", ""]
    call s:renderprompt(s:state)
endfunction

" Auto-commands

if has("autocmd")
    augroup ThrasherAutoCmdGroup
        autocmd!
        autocmd BufLeave Thrasher noa call thrasher#exit()
    augroup END
endif