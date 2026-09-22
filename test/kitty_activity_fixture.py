import json
import sys
import time
from pathlib import Path
path = Path(sys.argv[1])
last = None
# Emulate the shell protocol, so lifecycle cleanup is exercised as native input.
sys.stdout.write('\033]133;C\007')
sys.stdout.flush()
while True:
    if path.exists():
        value = path.read_text()
        if value != last:
            last = value
            data = json.loads(value)
            if 'progress' in data:
                sys.stdout.write(f'\033]9;4;{data["progress"]};{data.get("percent",0)}\007')
            if 'title' in data:
                sys.stdout.write(f'\033]2;{data["title"]}\007')
            if data.get('bell'):
                sys.stdout.write('\007')
            if data.get('text'):
                print(data['text'])
            if data.get('end'):
                sys.stdout.write('\033]133;D;0\007')
            sys.stdout.flush()
    time.sleep(0.03)
