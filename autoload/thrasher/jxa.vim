if exists('g:loaded_thrasher_osascript')
  finish
endif
let g:loaded_thrasher_osascript = 1

" JavaScript for Automation helpers (macOS)

function! thrasher#jxa#run(code)
  let l:output = system('echo ''' . a:code . ''' | osascript -l JavaScript')
  return substitute(l:output, '\n$', '', '')
endfunction

function! thrasher#jxa#escape(str)
  return escape(a:str, '"''')
endfunction
