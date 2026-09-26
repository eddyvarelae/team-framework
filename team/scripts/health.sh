#!/usr/bin/env bash
# team/scripts/health.sh - the health probe (v2.8). Run from the project root at the top of every PM
# cycle, or from launchd on a daemon machine. One line per check: OK / WARN / FAIL. Exit 1 on any FAIL.
# Checks: framework currency + byte-copies · primary checkout · locks · silent orders · review requests ·
# seat canary words. Thresholds via env: LOCK_MAX_MIN=30 NOTE_MAX_H=24. Needs git and python3.
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "FAIL not inside a git checkout"; exit 1; }
FW="${TEAM_FRAMEWORK:-$HOME/Projects/team-framework}"
LOCK_MAX_MIN="${LOCK_MAX_MIN:-30}"; NOTE_MAX_H="${NOTE_MAX_H:-24}"
fail=0; now=$(date +%s)
ok(){ echo "OK   $*"; }; warn(){ echo "WARN $*"; }; bad(){ echo "FAIL $*"; fail=1; }
mtime(){ stat -f %m "$1" 2>/dev/null || stat -c %Y "$1"; }

# 1. Framework: checkout current, framework-owned files byte-identical (startup ritual step 0).
if [ -d "$FW/.git" ]; then
  git -C "$FW" fetch -q origin 2>/dev/null || warn "framework: fetch failed (offline?) - currency check used the last fetch"
  behind=$(git -C "$FW" rev-list --count HEAD..origin/main 2>/dev/null || echo 0)
  if [ "$behind" = 0 ]; then ok "framework checkout at origin/main"
  else bad "framework checkout is $behind commit(s) behind origin/main - pull and apply the delta (startup step 0)"; fi
  drift=""
  for f in $(cd "$FW/team" && ls README.md actors/*.md scripts/*.sh diagram.mmd diagram.png 2>/dev/null); do
    if [ ! -f "team/$f" ]; then drift="$drift team/$f(missing)"
    elif ! cmp -s "$FW/team/$f" "team/$f"; then drift="$drift team/$f"; fi
  done
  if [ -z "$drift" ]; then ok "framework-owned files are byte-copies of $FW"
  else bad "framework-owned files differ from $FW:$drift"; fi
else
  bad "framework checkout missing at $FW - git clone git@github.com:eddyvarelae/team-framework.git $FW"
fi

# 2. Primary checkout: the PM's, on main, and nobody else editing in it.
br=$(git branch --show-current)
if [ "$br" = main ]; then ok "primary checkout on main"; else warn "primary checkout on '$br' - the PM's checkout stays on main; seats get worktrees"; fi
ok "worktrees: $(git worktree list | wc -l | tr -d ' ') ($(git worktree list | awk '{print $NF}' | tr '\n' ' '| sed 's/ $//'))"
outside=$(git status --porcelain | awk '{print $NF}' | grep -v '^team/' | head -5 | tr '\n' ' ')
if [ -z "$outside" ]; then ok "primary checkout: no uncommitted changes outside team/"
else warn "primary checkout has uncommitted changes outside team/ (a seat working in the PM's checkout?): $outside"; fi

# 3. Locks: 'LOCK <what> <date -Iseconds>' / 'UNLOCK <what> <date -Iseconds>' anywhere on a channel line (after the signature and canary word).
python3 - "$LOCK_MAX_MIN" <<'PY' || fail=1
import re, sys, glob, datetime
mx = int(sys.argv[1]); now = datetime.datetime.now(datetime.timezone.utc); held = {}; bad = 0
for f in sorted(glob.glob('team/channels/*.md')):
    for line in open(f, encoding='utf-8'):
        m = re.search(r'\b(UN)?LOCK\s+(\S+)\s+(\d{4}-\d\d-\d\dT\d\d:\d\d(?::\d\d)?(?:[+-]\d\d:?\d\d|Z)?)', line)
        if not m: continue
        key = (f, m.group(2))
        if m.group(1): held.pop(key, None); continue
        ts = m.group(3).replace('Z', '+00:00')
        try: t = datetime.datetime.fromisoformat(ts)
        except ValueError: print(f"WARN lock {m.group(2)} in {f}: unparseable timestamp {m.group(3)} (use date -Iseconds)"); continue
        if t.tzinfo is None: t = t.astimezone()
        held[key] = t
if not held: print("OK   locks: none held")
for (f, what), t in held.items():
    age = int((now - t).total_seconds() // 60)
    if age > mx: print(f"FAIL lock {what} held {age} min in {f} (max {mx}) - chase the holder or revert the lock"); bad = 1
    else: print(f"OK   lock {what} held {age} min in {f}")
sys.exit(bad)
PY

# 4. Silent orders: a channel with an active WORK ORDER whose last change is older than NOTE_MAX_H.
for ch in team/channels/*.md; do
  if awk '/^## WORK ORDER/{f=1;next} /^## /{f=0} f' "$ch" | grep -qv -e '^[[:space:]]*$' -e '^(none yet'; then
    last=$(git log -1 --format=%ct -- "$ch" 2>/dev/null); last=${last:-0}; m=$(mtime "$ch"); [ "$m" -gt "$last" ] && last=$m
    ageh=$(( (now - last) / 3600 ))
    if [ "$ageh" -le "$NOTE_MAX_H" ]; then ok "$ch: active order, last change ${ageh}h ago"
    else warn "$ch: active order but last change ${ageh}h ago (> ${NOTE_MAX_H}h) - is the seat alive?"; fi
  fi
done

# 5. Review requests: '### RR-n' headings under OPEN REQUESTS without a verdict, or whose last verdict is FINDINGS.
python3 - <<'PY'
import re
f = 'team/channels/review-requests.md'
try: txt = open(f, encoding='utf-8').read()
except FileNotFoundError: print(f"WARN {f} missing"); raise SystemExit
sec = txt.split('## OPEN REQUESTS', 1)[-1].split('\n## Resolved', 1)[0]
waiting, findings = [], []
for r in re.split(r'(?m)^(?=#{2,4}\s*RR-\d+)', sec):
    m = re.match(r'#{2,4}\s*(RR-\d+)', r)
    if not m: continue
    verdicts = re.findall(r'\*\*Reviewer \(\d{4}-\d\d-\d\d\):\*\*\s*`?([A-Z ]+)', r)
    if not verdicts: waiting.append(m.group(1))
    elif verdicts[-1].strip().startswith('FINDINGS'): findings.append(m.group(1))
if not waiting and not findings: print("OK   review-requests: nothing pending")
if waiting: print("WARN review-requests awaiting a verdict: " + ", ".join(waiting) + " - run team/scripts/reviewer.sh")
if findings: print("WARN review-requests with unresolved FINDINGS (does not ship): " + ", ".join(findings))
PY

# 6. Seat canary words: 'Canary words: Dev=…, Tester=…' in TEAM.md's Current state block; each seat's newest note starts with its word.
python3 - <<'PY' || fail=1
import re
txt = open('team/TEAM.md', encoding='utf-8').read()
m = re.search(r'(?im)^\s*canary words?:\s*(.+)$', txt)
words = dict(re.findall(r'(\w+)\s*=\s*([^\s,;]+)', m.group(1))) if m else {}
if not words: print("OK   canary words: none listed in the Current state block (no seats booted)"); raise SystemExit
chan = {'Dev': 'dev-questions', 'Tester': 'tester-feedback', 'Designer': 'design-questions', 'Cloud': 'cloud-questions'}
bad = 0
for role, word in words.items():
    f = f"team/channels/{chan.get(role, role.lower() + '-questions')}.md"
    try: body = open(f, encoding='utf-8').read()
    except FileNotFoundError: print(f"WARN canary {role}={word}: channel {f} missing"); continue
    notes = re.findall(rf'\*\*{role} \((\d{{4}}-\d\d-\d\d)\):\*\*\s*(\S*)', body)
    if not notes: print(f"OK   canary {role}={word}: no notes yet"); continue
    newest = max(d for d, _ in notes)
    latest = [w for d, w in notes if d == newest]
    missing = [w for w in latest if w.strip('*_`').rstrip('.,:;') != word]
    if missing: print(f"FAIL canary {role}={word}: {len(missing)}/{len(latest)} note(s) dated {newest} lack it - resend the boot line once, restart the seat if the next note still lacks it"); bad = 1
    else: print(f"OK   canary {role}={word}: newest note(s) ({newest}) carry it")
raise SystemExit(bad)
PY

exit $fail
