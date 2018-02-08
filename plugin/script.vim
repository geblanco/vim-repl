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

" variables
" g:repl_ipython
" g:repl_interpreter
" g:repl_script
" g:repl_args
" g:repl_vim_tab
" g:repl_vertical
"

" Shortcut for ipython options
if exists('g:repl_ipython') && g:repl_ipython
  let g:repl_interpreter = '/usr/bin/ipython3 -i'
  let g:repl_script = expand('<sfile>:p:h') . '/ipython.py'
  let g:repl_args = ' -- '
  let g:repl_vim_tab = 1
endif

if !exists('g:repl_interpreter')
  let g:repl_interpreter = '/usr/bin/python3'
endif

if !exists('g:repl_script')
  let g:repl_script = expand('<sfile>:p:h') . '/notebook.py'
endif

if !exists('g:repl_args')
  let g:repl_args = ''
endif

if !exists('g:repl_vim_tab')
  let g:repl_vim_tab = 1
endif

if !exists('g:repl_vertical')
  let g:repl_vertical = 0
endif

if !exists('g:repl_must_load')
  let g:repl_must_load = 1
endif

function! REPLInit()
  if !exists('t:fifo_in')
    let t:fifo_in = tempname()
    call system('mkfifo ' . t:fifo_in)
    if g:repl_vim_tab 
      let current_window = winnr()
      call term_start(g:repl_interpreter . ' ' . g:repl_script . ' ' . g:repl_args  . ' ' . getcwd() . ' ' . t:fifo_in, 
            \ { 'vertical' : g:repl_vertical, 'term_finish': 'close' })
      exe current_window . 'wincmd w'
      let g:repl_must_load = 0
    else
      echo 'Here is your pipe ' . t:fifo_in . ' spawn ' . g:repl_script . ' script'
      let g:repl_must_load = 1
    endif
  endif
endfunction

function! REPLClose()
  call system('echo "quit" > ' . t:fifo_in)
  call system('rm ' . t:fifo_in)
  let g:repl_must_load = 1
  unlet t:fifo_in
  unlet t:repl_started
endfunction

function! REPLReady()
  let g:repl_must_load = 0
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
  if !exists('t:repl_started')
    call REPLInit()
  endif

  let t:repl_started = 1
  
  if g:repl_must_load == 1
    echo "Load repl externally and hit ':call REPLReady()' to start piping content"
  else
    let str = REPLGetBlock()
    let str = substitute(str, "\"", "'", 'g')
    call system('echo "' . str . '" > ' . t:fifo_in)
    "exe '"' . str . '" write! >> ' . t:fifo_in
  endif
endfunction

command! REPLEval :call REPLEval()
command! REPLClose :call REPLClose()
