import os
os.system('cmd /c "docker build -t python_container ."')
os.system('cmd /c "docker run python_container"')