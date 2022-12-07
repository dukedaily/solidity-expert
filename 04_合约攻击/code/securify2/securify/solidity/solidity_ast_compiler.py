import argparse
import codecs
import os
from fnmatch import fnmatch

import semantic_version
from solc import compile_standard, get_solc_version_string
from solc.main import strip_zeroes_from_month_and_day

__all__ = ["compile_ast", "compiler_version"]


def compile_ast(src_path):
    # We need to use absolute paths
    src_path = os.path.join(os.getcwd(), src_path)
    _, src_name = os.path.split(src_path)

    # We are only interested in the AST
    output_selection = {"*": {"": ["ast"]}}

    # Define settings for compilation
    compile_input = {
        'language': 'Solidity',
        'sources': {src_name: {'urls': [src_path]}},
        'settings': {
            'outputSelection': output_selection
        }
    }

    # Call solc compiler using json input
    compile_output = compile_standard(compile_input, allow_paths='/')
    ast = compile_output['sources'][os.path.basename(src_path)]['ast']

    with open(src_path, 'rb') as file:
        ast["source"] = codecs.utf_8_decode(file.read())[0]

    ast["_solc_version"] = compiler_version()

    return ast


def compiler_version():
    version = get_solc_version_string()
    version = version[len('Version: '):]
    version = version.strip()
    version = version.replace('++', 'pp')
    version = strip_zeroes_from_month_and_day(version)

    return semantic_version.Version(version)


if __name__ == '__main__':
    # Adds possibility to run script with command-line arguments
    parser = argparse.ArgumentParser(description='Compile a single or multiple contracts.')
    parser.add_argument('-o', '--output', help='print the output of the compiler', action='store_true')
    parser.add_argument('file', nargs='*', help='if indicated, the contracts to run')

    args = parser.parse_args()
    arg_files = args.file
    # Check the case that no specific file(s) was given for compilation, if so compile all files

    arg_files.append('contract0.sol')

    pattern = "*.sol"
    contracts = []

    for arg_file in arg_files:
        if os.path.isfile(arg_file):
            if fnmatch(arg_file, pattern):
                contracts.append(arg_file)
        for path, subdirs, files in os.walk(arg_file):
            for name in files:
                if fnmatch(name, pattern):
                    contracts.append(os.path.join(path, name))

    for contract in contracts:
        output = args.output
        compile_ast(contract)

    print(compiler_version())
