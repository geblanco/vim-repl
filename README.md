# vim-repl
A minimal repl for vim, with KISS in mind

# Why?
After trying many, many plugins for repl/tab completion out there I was tired of none of them working. So I came up with my own.

# Features
By now this plugin is just a repl for python, although it can be extended to use anything as repl

# How does it work?
When first activated, a pipe is created for streaming code. Then the repl script is launched, it grabs the content of the pipe and executes it. By now the repl is started within a terminal tab in vim (requires compilation with +terminal), although this is not necessary, if you want to run it in a separate terminal, just get the pipe name and start the repl script there. Also, set this is option in your `vimrc`

`let g:notebook_vim_tab = 0`

# Options
* `g:repl_ipython`: Shortcut for setting options for ipython instead of python notebook (much richier) - Default 0
* `g:repl_interpreter`: The interpreter to be used for the repl - Default `/usr/bin/python3`
* `g:repl_script`: The script to grab content from the pipe and stream it to the repl - Default `notebook.py`
* `g:repl_args`: Arguments for the interpreter. Used for ipython (needs some args to work with preloaded scripts) - Defaults to ""
* `g:repl_vim_tab`: Whether to spawn the repl inside vim's terminal or not (requires you to run the streamer appart) - Defaults to 1
* `g:repl_vertical`: When `g:notebook_vim_tab = 1`, set the terminal to split vertical or horizontal - Defaults to 0 (horizontal)

## Advice
I think the most useful setup comes with `g:repl_ipython = 1`, `g:repl_vertical = 1`, which sets up everything for ipython and splits vertically.

# What's next?
* I've tried many completing engines for vim, some of them work reasonably well, but none fits to my needs. In the future this plugin could be used for completion too.

# Disclaimer
This is an experimental project, expect nothing from it :)

# Contributing
Any idea/comment/pr is wellcome :)
