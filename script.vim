let t:last_buff = ''

if !exists('g:notebook_vim_tab')
  let g:notebook_vim_tab = 1
endif

if !exists('g:notebook_repl')
  let g:notebook_repl = expand('<sfile>:p:h') . '/notebook/py'
  echo 'No repl path given, falling back to default ' . g:notebook_repl
  finish
endif

function! Init()
  if exists('t:pid')
    return
  endif
  let t:fifo_in = tempname()
  call system('mkfifo ' . t:fifo_in)
  let t:pid = system('tail -f ' . t:fifo_in . ' | python3.6 | echo "$!"')
  redraw
endfunction

function! Close()
  if !exists('t:pid')
    echo 'Warning: REPL not running, call Init first'
    return
  endif

  call system('echo "exit()" >> ' . t:fifo_in)
  " an empty line should close the 'tail -f' process
  call system('echo "" >> ' . t:fifo_in)
  call system('kill -9 ' . t:pid)
  unlet! t:pid
  unlet! t:fifo_in
endfunction

" taken from https://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
function! GetBlock()
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
      return getline('.')
  endif
  let joint = join(lines, "\n")

  let vm = visualmode()
  if (vm ==? "v" || vm ==? "CTRL-V")
    " If comming from visual and last equals current
    " then, the visual select mode was not cleared,
    " get current line
    if joint == t:last_buff
      let joint = getline('v')
    else
      let t:last_buff = joint
    endif
  else
    let joint = getline('v')
  endif
  return joint
endfunction

function! Eval()
  if !exists('t:fifo_in')
    let t:fifo_in = tempname()
    call system('mkfifo ' . t:fifo_in)
    if g:notebook_vim_tab 
      call term_start('/usr/bin/python3 ' . g:notebook_repl . ' ' . getcwd() . ' ' . t:fifo_in)
    else
      echo 'Here is your pipe ' . t:fifo_in . ' spawn ' . g:notebook_repl . ' script'
    endif
  endif

  let str = GetBlock()
  let str = substitute(str, "\"", "'", 'g')
  call system('echo "' . str . '" > ' . t:fifo_in)
  "exe '"' . str . '" write! >> ' . t:fifo_in
endfunction

"command! NotebookStart :call Init()
command! NotebookEval :call Eval()
map <LocalLeader>s : <C-U>NotebookEval<CR>
