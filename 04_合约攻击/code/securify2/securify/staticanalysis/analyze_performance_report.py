import json

with open("souffle-profile.json") as fp:
    r = json.load(fp)

relations = list(r["root"]["program"]["relation"].items())

relations_with_runtime = list(filter(lambda x: "runtime" in x[1], relations))
for _, r in relations_with_runtime:
    r["runtime"] = (r["runtime"]["end"] - r["runtime"]["start"]) / 1000 / 1000

relations_by_time = sorted(relations_with_runtime, key=lambda x: -x[1]["runtime"])

for t in (list(map(lambda t: t[0] + " " + str(t[1]["runtime"]), relations_by_time)))[0:10]:
    print(t)

print()
print()


relations_by_count = sorted(relations_with_runtime, key=lambda x: -x[1]["num-tuples"])
for t in (list(map(lambda t: t[0] + " " + str(t[1]["num-tuples"]), relations_by_count)))[0:10]:
    print(t)


print()
print()

relations_by_reads = sorted(relations_with_runtime, key=lambda x: -x[1]["reads"])
for t in (list(map(lambda t: t[0] + " " + str(t[1]["reads"]), relations_by_reads)))[0:10]:
    print(t)

# sorted(relations, key=lambda
