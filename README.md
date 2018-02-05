# vim-repl
A minimal repl for vim, with KISS in mind

# Why?
After trying many, many plugins for repl/tab completion out there I was tired of none of them working. So I came up with my own.

# Features
By now this plugin is just a repl for python, although it can be extended to use anything as repl

# How does it work?
When first activated, a pipe is created for streaming code. Then the repl script is launched, it grabs the content of the pipe and executes it. By now the repl is started within a terminal tab in vim (requires compilation with +terminal), although this is not necessary, if you want to run it in a separate terminal, just get the pipe name and start the repl script there. Also, set this is option in your `vimrc`

`let g:notebook_vim_tab = 0`

# What's next?
* Add more options for shell spawn, repl and so on
* I've tried many completing engines for vim, some of them work reasonably well, but none fits to my needs. In the future this plugin could be used for completion too.

# Contributing
Any idea/comment/pr is wellcome :)
