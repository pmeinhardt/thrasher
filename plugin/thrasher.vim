" Location: plugin/thrasher.vim
" Author:   Paul Meinhardt <https://github.com/pmeinhardt>

if exists("g:loaded_thrasher") || v:version < 700
    finish
endif
let g:loaded_thrasher = 1

command! -nargs=0 Thrasher          call thrasher#run()

command! -nargs=* ThrasherPlay      call thrasher#play(<f-args>)
command! -nargs=0 ThrasherPause     call thrasher#pause()
command! -nargs=0 ThrasherToggle    call thrasher#toggle()
command! -nargs=0 ThrasherStop      call thrasher#stop()
command! -nargs=0 ThrasherNext      call thrasher#next()
command! -nargs=0 ThrasherPrev      call thrasher#prev()

command! -nargs=0 ThrasherStatus    call thrasher#status()
command! -nargs=0 ThrasherLibrary   call thrasher#librarytoggle()
command! -nargs=0 ThrasherOnline    call thrasher#onlinetoggle()
command! -nargs=0 ThrasherRefresh   call thrasher#refresh()

" command! -nargs=* ThrasherQueue    call thrasher#queue()
" command! -nargs=0 ThrasherUnqueue  call thrasher#unqueue()
" command! -nargs=0 ThrasherClearQ   call thrasher#clearq()

" command! -nargs=* ThrasherConfig   call thrasher#configure()

" TODO: Figure out which arguments we could pass to ThrasherPlay, e.g.
"
"   ThrasherPlay metallica
"   ThrasherPlay whiplash
"   ThrasherPlay artist metallica
"   ThrasherPlay album kill' em all
"   ThrasherPlay track whiplash
"
" or (alternative syntax) ThrasherPlay [[[artist]/album]/track], e.g.
"
"   ThrasherPlay metallica
"   ThrasherPlay /kill' em all
"   ThrasherPlay //whiplash
"
" Add -complete=customlist,... or -complete=custom,...
" see :help :command-completion-custom

" TODO: Standalone window mode (no esc., full height list)

" nnoremap <silent> <plug>(thrasher) :<c-u>Thrasher<cr>
nnoremap <plug>(thrasher) :<c-u>Thrasher<cr>

if !exists("g:thrashermap") | let g:thrashermap = "<leader>m" | endif

if g:thrashermap != "" && !hasmapto("<plug>(thrasher)")
    execute "map " . g:thrashermap . " <plug>(thrasher)"
endif
