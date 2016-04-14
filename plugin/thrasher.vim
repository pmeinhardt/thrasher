" Location: plugin/thrasher.vim
" Author:   Paul Meinhardt <https://github.com/pmeinhardt>

if exists("g:loaded_thrasher")
  finish
endif
let g:loaded_thrasher = 1

command! Thrasher         call thrasher#show()

command! ThrasherStatus   call thrasher#status()
command! ThrasherPlay     call thrasher#play()
command! ThrasherPause    call thrasher#pause()
command! ThrasherStop     call thrasher#stop()
command! ThrasherNext     call thrasher#next()
command! ThrasherPrev     call thrasher#prev()

" command! ThrasherQueue    call thrasher#queue()
" command! ThrasherUnqueue  call thrasher#unqueue()
" command! ThrasherClearQ   call thrasher#clearq()
