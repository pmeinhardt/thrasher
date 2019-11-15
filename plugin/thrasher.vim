if (exists('g:loaded_thrasher') && g:loaded_thrasher) || v:version < 700
  finish
endif
let g:loaded_thrasher = 1

if !exists('g:thrasher_map') | let g:thrasher_map = '<leader>t' | endif
if !exists('g:thrasher_cmd') | let g:thrasher_cmd = 'Thrasher' | endif

command! -nargs=0 Thrasher          call thrasher#run()
command! -nargs=0 ThrasherPlay      call thrasher#play()
command! -nargs=0 ThrasherPause     call thrasher#pause()
command! -nargs=0 ThrasherToggle    call thrasher#toggle()
command! -nargs=0 ThrasherNext      call thrasher#next()
command! -nargs=0 ThrasherPrev      call thrasher#prev()
command! -nargs=0 ThrasherStatus    call thrasher#status()

execute 'nnoremap <plug>(thrasher) :<c-u>' . g:thrasher_cmd . '<cr>'

if g:thrasher_map != '' && !hasmapto('<plug>(thrasher)', 'n')
  execute 'nnoremap <silent> ' . g:thrasher_map . ' <plug>(thrasher)'
endif
