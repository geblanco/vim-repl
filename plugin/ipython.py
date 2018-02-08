from IPython.core.interactiveshell import InteractiveShell
from prompt_toolkit.key_binding.input_processor import KeyPress
from prompt_toolkit.keys import Keys
import threading
import sys
import os
import time

if len(sys.argv) < 3:
  print('Usage python3 notebook.py <working dir> <pipe>')
  sys.exit(1)

print('Changing dir to {}'.format(sys.argv[1]))
os.chdir(sys.argv[1])
pipe_path = sys.argv[2]

print('Starting interactives shell...')

def process(content, shell):
  content = content.strip()
  print(content)
  result = shell.run_cell(raw_cell=content, store_history=True)
  shell.pt_cli.input_processor.feed(KeyPress(Keys.Enter))
  shell.pt_cli.input_processor.process_keys()

def worker(pipe_path, shell):
  pipe = open(pipe_path, 'r')
  done = False
  while not done:
    content = pipe.read()
    if content != '':
      if content.strip() == 'quit':
        print('Received signal, exiting...')
        shell.pt_cli.input_processor.feed(KeyPress(Keys.Enter))
        shell.pt_cli.input_processor.process_keys()
        done = True
      else:
        process(content, shell)

    pipe.flush()
    time.sleep(0.05)
  
  process('exit', shell)

shell = get_ipython().instance()
th = threading.Thread(target=worker, args=[pipe_path, shell])
th.start()

