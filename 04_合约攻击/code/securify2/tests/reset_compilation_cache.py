import shutil
from pathlib import Path

if __name__ == '__main__':
    for path in Path('.').glob('**/cache/'):
        if list(path.glob(f"*.ast")):
            shutil.rmtree(path)
