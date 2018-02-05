from IPython.core.interactiveshell import InteractiveShell
import sys
import os

if len(sys.argv) < 3:
  print('Usage python3 notebook.py <working dir> <pipe>')
  sys.exit(1)

print('Changing dir to {}'.format(sys.argv[1]))
os.chdir(sys.argv[1])
pipe_path = sys.argv[2]
done = False
pipe = open(pipe_path, 'r')

print('Starting interactives shell...')
shell = InteractiveShell()

while not done:
  content = pipe.read()
  if content != '':
    if content.strip() == 'quit':
      print('Received signal, exiting...')
      done = True
    else:
      print(content)
      result = shell.run_cell(content)
try:
  pipe.close()
except:
  print('Error closing pipe')


