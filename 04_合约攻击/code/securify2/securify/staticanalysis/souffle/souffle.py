import csv
import os
import shutil
import tempfile
from collections import defaultdict

from .factformatter import format_facts_as_csv
from .wrapper import (
    souffle_wrapper,
    get_souffle_binary_path
)

__all__ = ["is_souffle_available", "run_souffle", "generate_fact_files"]


def is_souffle_available():
    souffle_binary = get_souffle_binary_path()

    def is_exe(file):
        return os.path.isfile(file) and os.access(file, os.X_OK)

    if os.path.dirname(souffle_binary):
        return is_exe(souffle_binary)

    for path in os.environ["PATH"].split(os.pathsep):
        if is_exe(os.path.join(path.strip('"'), souffle_binary)):
            return True

    return False


def run_souffle(source_file, *, facts=None, fact_dir=None, output_dir=None, executable_dir=None, souffle_kwargs=None):
    tmp_dirs = []

    def get_temp_dir():
        tmp_dir = tempfile.TemporaryDirectory()
        tmp_dirs.append(tmp_dir)
        return tmp_dir

    def get_dir(d):
        if d is not None:
            if os.path.exists(d):
                shutil.rmtree(d)
            os.makedirs(d, exist_ok=True)

            return d

        return get_temp_dir().name

    try:
        fact_dir = get_dir(fact_dir)
        output_dir = get_dir(output_dir)

        if facts:
            generate_fact_files(facts, fact_dir)

        souffle_output = souffle_wrapper(
            file=source_file,
            fact_dir=fact_dir,
            output_dir=output_dir,
            dl_executable=executable_dir,
            **(souffle_kwargs or {}))

        output_facts = read_outputs(output_dir)

        return souffle_output, output_facts

    finally:
        for tmp in tmp_dirs:
            tmp.cleanup()


def read_outputs(out_dir=None, relations_types=None):
    result = {}

    if relations_types:
        relations_types = {r._name: lambda args: r(*args) for r in relations_types}
    else:
        relations_types = {}

    for f in os.listdir(out_dir):
        file_path = os.path.join(out_dir, f)
        if not os.path.isfile(file_path) or not f.endswith(".csv"):
            continue

        relation_name = os.path.basename(f)
        relation_name = os.path.splitext(relation_name)[0]

        relation_constructor = relations_types.get(relation_name, tuple)

        with open(file_path) as csv_file:
            csv_reader = csv.reader(csv_file, delimiter='\t', strict=True)

            result[relation_name] = [
                relation_constructor(columns) for columns in csv_reader
            ]

    return result


def generate_fact_files(facts, fact_dir):
    for fact_class, facts in format_facts_as_csv(facts):
        fact_relation = fact_class._name
        fact_file = os.path.join(fact_dir, fact_relation + ".facts")

        with open(fact_file, 'w') as f:
            f.write("\n".join(facts))
