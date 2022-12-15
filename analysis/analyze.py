import csv


HIT_THRESHOLD = 250
SQU_THRESHOLD = 3
MUL_THRESHOLD = 42000


lines = []
with open("../run.sh.csv") as fh:
    fr = csv.DictReader(fh)
    for r in fr:
        t = int(r['tsc'])
        c = int(r['off662000'])
        lines.append((t, c < HIT_THRESHOLD))


for i in range(1, len(lines)-1):
    if lines[i][1] and not lines[i-1][1] and not lines[i+1][1]:
        lines[i] = (lines[i][0], False)
    elif lines[i-1][1] and lines[i+1][1]:
        lines[i] = (lines[i][0], True)

while not lines[0][1]:
    lines.pop(0)
while not lines[-1][1]:
    lines.pop()


def get_sq_times():
    ret = []

    sq_start = None
    in_sq = False

    for i,l in enumerate(lines):
        if l[1] and in_sq:
            continue
        elif l[1]:
            to_set = True
            for j in range(i, i + SQU_THRESHOLD):
                if j >= len(lines) or not lines[j][1]:
                    to_set = False
            if to_set:
                if sq_start != None:
                    ret.append((l[0] - sq_start) % 2**32)
                sq_start = l[0]
                in_sq = True
        else:
            in_sq = False

    return ret

sq_times = get_sq_times()[0:2044]
sq_vals = list(map(lambda d: '0' if d < MUL_THRESHOLD else '1', sq_times))

print("1" + ''.join(sq_vals) + "1")
