" The MIT License (MIT)
" 
" Copyright (c) 2018 m0n0l0c0
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.

let t:last_buff = ''

if !exists('g:notebook_vim_tab')
  let g:notebook_vim_tab = 1
endif

if !exists('g:notebook_repl')
  let g:notebook_repl = expand('<sfile>:p:h') . '/notebook.py'
  " echo 'No repl path given, falling back to default ' . g:notebook_repl
endif

function! REPLInit()
  if !exists('t:fifo_in')
    let t:fifo_in = tempname()
    call system('mkfifo ' . t:fifo_in)
    if g:notebook_vim_tab 
      call term_start('/usr/bin/python3 ' . g:notebook_repl . ' ' . getcwd() . ' ' . t:fifo_in)
    else
      echo 'Here is your pipe ' . t:fifo_in . ' spawn ' . g:notebook_repl . ' script'
    endif
  endif
endfunction

function! REPLClose()
  " ToDo := Close repl and pipe
  echo "Warning: Not implemented!"
endfunction

" taken from https://stackoverflow.com/questions/1533565/how-to-get-visually-selected-text-in-vimscript
function! REPLGetBlock()
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

function! REPLEval() 
  if !exists('t:notebook_started')
    call REPLInit()
  endif

  let t:notebook_started = 1

  let str = REPLGetBlock()
  let str = substitute(str, "\"", "'", 'g')
  call system('echo "' . str . '" > ' . t:fifo_in)
  "exe '"' . str . '" write! >> ' . t:fifo_in
endfunction

"command! NotebookStart :call REPLInit()
command! REPLEval :call REPLEval()
map <LocalLeader>s : <C-U>REPLEval<CR>
