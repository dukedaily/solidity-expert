import inspect
import os
import time
import unittest
from itertools import groupby
from pathlib import Path
from pprint import pprint

from securify.solidity import compile_cfg
from securify.staticanalysis import static_analysis
from tests.staticanalysis.evaluation import securify_wrapper

pattern_ids = [
    ("DAO", "DAO"),
    ("DAOConstantGas", "DAOConstantGasPattern"),
    ("LockedEther", "LockedEtherPattern"),
    ("MissingInputValidation", "MissingInputValidationPattern"),
    ("RepeatedCall", "RepeatedCallPattern"),
    ("TODAmount", "TODAmountPattern"),
    # ("TODTransfer", "TODTransferPattern"),
    ("TODReceiver", "TODReceiverPattern"),
    ("UnhandledException", "UnhandledExceptionPattern"),
    ("UnrestrictedEtherFlow", "UnrestrictedEtherFlowPattern"),
    ("UnrestrictedWrite", "UnrestrictedWritePattern"),
]


def get_lines(securify_output, pattern_name):
    # pprint(securify_output)

    v, c, w, co = [], [], [], []
    for t, e in securify_output.items():
        if ".sol" not in t:
            continue

        lines = e["results"][pattern_name]
        c.extend(map(lambda x: x + 1, lines["safe"]))
        w.extend(map(lambda x: x + 1, lines["warnings"]))
        v.extend(map(lambda x: x + 1, lines["violations"]))
        co.extend(map(lambda x: x + 1, lines["conflicts"]))

    return set(v), set(c), set(w), set(co)


def compare(path_src):
    securify_start_time = time.time()
    cfg, ast, *_ = compile_cfg(path_src)
    result = static_analysis.analyze_cfg(cfg).facts_out
    securify_end_time = time.time()

    def group_matches(results):
        return {k: list(v) for k, v in groupby(results, lambda t: t[0])}

    compliant_securify = group_matches(result["patternCompliance"])
    violation_securify = group_matches(result["patternViolation"])
    warnings_securify = group_matches(result["patternWarning"])
    conflict_securify = group_matches(result["patternConflict"])

    secu_start_time = time.time()
    securify_output = securify_wrapper.run_securify(path_src)
    secu_end_time = time.time()

    # print("")
    # print("Securify")
    # print("=========")
    # print("Compliant ")
    # pprint(list(compliant_securify.values()))
    # print("Violation ")
    # pprint(list(violation_securify.values()))
    # print("Warnings ")
    # pprint(list(warnings_securify.values()))
    # print("Conflict ")
    # pprint(list(conflict_securify.values()))
    #
    # print("")
    # print("Securify")
    # print("=========")
    # pprint(securify_output)

    # print(secu_end_time - secu_start_time)
    # print(securify_end_time - securify_start_time)

    print(path_src)
    for pattern_name, pattern_id in pattern_ids:
        safe_securify = {int(t[2][1:]) for t in compliant_securify.get(pattern_id, [])}
        unsafe_securify = {int(t[2][1:]) for t in violation_securify.get(pattern_id, [])}
        warn_securify = {int(t[2][1:]) for t in warnings_securify.get(pattern_id, [])}
        conf_securify = {int(t[2][1:]) for t in conflict_securify.get(pattern_id, [])}

        (unsafe_securify,
         safe_securify,
         warn_securify,
         conf_securify) = get_lines(securify_output, pattern_name)

        elements = [
            safe_securify,
            warn_securify,
            unsafe_securify,
            conf_securify,
            safe_securify,
            warn_securify,
            unsafe_securify,
            conf_securify
        ]

        lines = sorted({item for e in elements for item in e})

        print(pattern_name)
        print("\t".join(["Securify", "", "", "", "Securify"]))
        print("\t".join(["SF", "WRN", "USF", "CNF"] * 2 + ["DIFF"]))

        for line in lines:
            t = [str(line) if line in s else "" for s in elements]
            d = any([t[i] != t[i + 4] for i in range(4)])
            print("\t".join(t + ["X" if d else ""]))

        print()


def make_test_case(path_src):
    def test_case(self: unittest.TestCase):
        compare(path_src)

    return test_case


def list_contracts():
    return Path(os.path.abspath(__file__)).parent.glob("**/*.sol")


class Evaluation(unittest.TestCase):
    frame = inspect.currentframe()
    for path in list_contracts():
        test_name = str(path.stem) \
            .replace(".sol", "") \
            .replace("\\", ".") \
            .replace("/", ".")

        frame.f_locals[f'test_{test_name}'] = make_test_case(str(path))


if __name__ == '__main__':
    for path in list_contracts():
        pass
