" Location: plugin/thrasher.vim
" Author:   Paul Meinhardt <https://github.com/pmeinhardt>

if exists("g:loaded_thrasher") || v:version < 700
  finish
endif
let g:loaded_thrasher = 1

command! -nargs=0 Thrasher         call thrasher#run()

command! -nargs=* ThrasherPlay     call thrasher#play()
command! -nargs=0 ThrasherPause    call thrasher#pause()
command! -nargs=0 ThrasherStop     call thrasher#stop()
command! -nargs=0 ThrasherNext     call thrasher#next()
command! -nargs=0 ThrasherPrev     call thrasher#prev()

command! -nargs=0 ThrasherStatus   call thrasher#status()

" command! -nargs=* ThrasherQueue    call thrasher#queue()
" command! -nargs=0 ThrasherUnqueue  call thrasher#unqueue()
" command! -nargs=0 ThrasherClearQ   call thrasher#clearq()

" command! -nargs=0 ThrasherConfig   call thrasher#configure()
