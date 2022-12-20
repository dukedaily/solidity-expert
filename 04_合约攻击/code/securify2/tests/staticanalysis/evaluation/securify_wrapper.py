import json
import os
import subprocess


def get_securify_binary_path():
    return os.environ.get('SECURIFY_BINARY', 'securify')


def run_securify(solc_file):
    command = []

    command.append(get_securify_binary_path())
    command.append("-fs")
    command.append(solc_file)
    command.append("-q")
    command.append("--json")

    proc = subprocess.Popen(command,
                            stdin=subprocess.PIPE,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)

    stdoutdata, stderrdata = proc.communicate()

    return json.loads(stdoutdata)


if __name__ == '__main__':
    run_securify("no-reentrancy.sol")
