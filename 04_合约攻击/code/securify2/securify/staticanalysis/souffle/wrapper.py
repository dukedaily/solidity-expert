import os
import codecs
import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import List

from .exceptions import (
    SouffleError,
)

__all__ = [
    "get_souffle_binary_path",
    "souffle_wrapper",
    "SouffleOutput",
]


def souffle_wrapper(souffle_binary=None,
                    file=None,
                    stdin=None,
                    help=None,
                    fact_dir=None,
                    include_dir=None,
                    output_dir=None,
                    library_dir=None,
                    libraries=None,
                    jobs=None,
                    version=None,
                    verbose=None,
                    profile_out=None,
                    profile_use=None,
                    report_out=None,
                    dl_executable=None,
                    use_interpreter=None,
                    force_recompilation=None,
                    success_return_code=0,
                    macro_definitions=None):
    def get_path(d):
        return str(d) if isinstance(d, Path) else d

    if souffle_binary is None:
        souffle_binary = get_souffle_binary_path()

    command = [souffle_binary]

    def add_option(param_value, param_name):
        if param_value is not None:
            command.append(param_name)

    def add_param(param_value, param_name, transformer=None, no_args=False):
        if param_value is not None:
            if transformer:
                param_value = transformer(param_value)

            if not no_args:
                command.append(f'{param_name}={param_value}')
            else:
                command.append(f'{param_name}')

    add_option(help, '--help')
    add_option(version, '--version')
    add_option(verbose, '--verbose')

    add_param(fact_dir, '--fact-dir', get_path)
    add_param(include_dir, '--include-dir', get_path)
    add_param(output_dir, '--output-dir', get_path)
    add_param(library_dir, '--library-dir', get_path)
    add_param(libraries, '--libraries', get_path)

    add_param(jobs, '--jobs')
    add_param(profile_out, '--profile')
    add_param(profile_use, '--profile-use')
    add_param(report_out, '--debug-report')

    # Try to compile dl only if there is no use_interpreter directive
    # Turn it off for now
    #use_interpreter=True

    if not use_interpreter:
        add_param(dl_executable, '--dl-program')

    if macro_definitions:
        macro_mappings = (f"{k}={v}" for k, v in macro_definitions.items())
        macros = " ".join(macro_mappings)
        add_param(f"'{macros}'", '--macro')

    if file:
        command.append(get_path(file))

    # if stdin is not None:
    #     stdin = force_bytes(stdin, 'utf8')

    # Use souffle command (either for the interpreter or for compilation
    if not os.path.exists(dl_executable)\
       or force_recompilation\
       or use_interpreter:

        compilation_msg = 'Compiling it now. This might take some time...'
        if force_recompilation:
            print("Forcing recompilation.", compilation_msg)
        elif not os.path.exists(dl_executable) and not use_interpreter:
            print("Executable not found.", compilation_msg)

        #print(command)
        proc = subprocess.Popen(command,
                                stdin=subprocess.PIPE,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)

        stdoutdata, stderrdata = proc.communicate(stdin)

        if proc.returncode != success_return_code:
            raise SouffleError(
                command=command,
                return_code=proc.returncode,
                stdin_data=stdin,
                stdout_data=codecs.decode(stdoutdata),
                stderr_data=codecs.decode(stderrdata),
            )

    # Use compiled executable
    if not use_interpreter:

        command = os.path.abspath(dl_executable)

        #print(command)
        proc = subprocess.Popen(command,
                                stdin=subprocess.PIPE,
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)

        stdoutdata, stderrdata = proc.communicate(stdin)

        if proc.returncode != success_return_code:
            raise SouffleError(
                command=command,
                return_code=proc.returncode,
                stdin_data=stdin,
                stdout_data=codecs.decode(stdoutdata),
                stderr_data=codecs.decode(stderrdata),
            )

    return SouffleOutput(codecs.decode(stdoutdata),
                         codecs.decode(stderrdata),
                         command,
                         proc)


def get_souffle_binary_path():
    return os.environ.get('SOUFFLE_BINARY', 'souffle')


@dataclass
class SouffleOutput:
    stdout: str
    stderr: str

    command: List[str]

    process: subprocess.Popen

    def __iter__(self):
        return iter((self.stdout,
                     self.stderr,
                     self.command,
                     self.process,
                     ))
