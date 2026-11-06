#!/usr/bin/env bash
# team/scripts/pm-guard.sh <session|prompt|stop> - the PM's message guard (v2.10). A Claude Code hook, not a rule the
# model has to remember: it reads the session transcript, counts the PM's messages to the human since the human last
# wrote, and (a) tells the PM the clock and the remaining budget before every turn, (b) refuses to end a turn whose
# final text breaks the contract. Installed by team/scripts/install-hooks.sh into .claude/settings.json; the health
# probe FAILs when it is missing. Runs only in the primary checkout (the PM's); seats' worktrees exit 0 at once.
#
#   session  SessionStart     -> prints context: clock, budget, the three allowed endings.
#   prompt   UserPromptSubmit -> prints context: clock, budget, what the incoming prompt is (human / seat / notification).
#   stop     Stop             -> exit 2 with the reason on stderr when the final text is not one of:
#                                 "·" alone (nothing for the human), a header message within budget, or INCIDENT.
#                                 A header message must carry a timestamp within GUARD_SKEW_MIN of the clock.
#
# Env: PM_GUARD_BUDGET (default 2) messages per human reply, GUARD_SKEW_MIN (default 5), PM_GUARD_OFF=1 disables.
set -uo pipefail
MODE="${1:-stop}"
[ "${PM_GUARD_OFF:-0}" = 1 ] && exit 0
input="$(cat 2>/dev/null || true)"
# The project is where this script lives (team/scripts/..), not the hook's cwd: a PM session started one directory
# up (it happens) still guards the right repo when the hook command uses the script's absolute path.
cd "$(cd "$(dirname "$0")/../.." && pwd)" 2>/dev/null || exit 0
[ -f team/TEAM.md ] || exit 0
# Primary checkout only: in a linked worktree --git-dir is .git/worktrees/<name>, in the primary it equals the common dir.
[ "$(git rev-parse --git-dir)" = "$(git rev-parse --git-common-dir)" ] || exit 0

PM_GUARD_INPUT="$input" python3 - "$MODE" "${PM_GUARD_BUDGET:-2}" "${GUARD_SKEW_MIN:-5}" <<'PY'
import sys, os, json, re, datetime
mode, budget, skew = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
try: hook = json.loads(os.environ.get('PM_GUARD_INPUT') or '{}')
except Exception: hook = {}
now = datetime.datetime.now().astimezone()
clock = now.strftime('%a %Y-%m-%d %H:%M %Z')
HEADER = re.compile(r'^\s*\S+ · (Mon|Tue|Wed|Thu|Fri|Sat|Sun) (\d{4}-\d\d-\d\d) (\d\d:\d\d)')
MACHINE = ('Another Claude session sent a message', '<cross-session-message', '[SYSTEM NOTIFICATION', '<task-notification',
           '[Cross-session', 'This is how Claude Code surfaces', '<command-name>', '<local-command')

def text_of(msg):
    c = msg.get('content')
    if isinstance(c, str): return c, True
    out, has_text = [], False
    for b in c or []:
        if isinstance(b, dict) and b.get('type') == 'text': out.append(b.get('text', '')); has_text = True
    return '\n'.join(out), has_text

def is_human(row):
    if row.get('isMeta'): return False
    t, has_text = text_of(row.get('message') or {})
    if not has_text or not t.strip(): return False
    head = t.lstrip()[:120]
    return not any(head.startswith(m) or m in head for m in MACHINE)

rows = []
try:
    with open(hook.get('transcript_path', ''), encoding='utf-8') as f:
        for line in f:
            try: d = json.loads(line)
            except Exception: continue
            if d.get('type') in ('user', 'assistant'): rows.append(d)
except Exception:
    rows = []

# Messages to the human since the human's last message (the current turn's final text is NOT in the transcript yet).
sent, last_kind = 0, 'none'
for row in rows:
    if row['type'] == 'user':
        if is_human(row): sent = 0; last_kind = 'human'
        else:
            t, has_text = text_of(row.get('message') or {})
            if has_text and t.strip(): last_kind = 'seat message' if 'cross-session' in t[:200] else 'notification'
    else:
        t, _ = text_of(row.get('message') or {})
        if HEADER.match(t or ''): sent += 1
remaining = max(0, budget - sent)

if mode in ('session', 'prompt'):
    if mode == 'prompt':
        p = (hook.get('prompt') or '').lstrip()
        kind = 'human' if p and not any(p.startswith(m) or m in p[:120] for m in MACHINE) else ('seat message' if 'cross-session' in p[:200] else 'notification')
        if kind == 'human': sent, remaining = 0, budget
    else:
        kind = 'session start'
    print(f"[pm-guard] Clock: {clock}. Incoming: {kind}. Messages to the human since their last reply: {sent} of {budget} "
          f"(remaining {remaining}). End this turn with exactly one of: the quiet line `·` (nothing for the human), "
          f"a header message `<word> · {clock}` only for a human action or a milestone and only while remaining > 0, "
          f"or a line starting with INCIDENT (production down, data loss, an outsider reached). Seat reports, merges, "
          f"verifications and bookkeeping never become a message. The timestamp is the clock above, not an estimate.")
    sys.exit(0)

# stop
if hook.get('stop_hook_active'): sys.exit(0)          # one correction per turn; never loop
final = hook.get('last_assistant_message')
if final is None:
    for row in reversed(rows):
        if row['type'] == 'assistant':
            t, has_text = text_of(row.get('message') or {})
            if has_text and t.strip(): final = t; break
final = (final or '').strip()
if final in ('', '·'): sys.exit(0)
if final.startswith('INCIDENT'): sys.exit(0)
m = HEADER.match(final)
if not m:
    sys.stderr.write(f"[pm-guard] The final text of a PM turn is one of: the quiet line `·`, a header message "
                     f"`<word> · {clock}` (human action or milestone, {remaining} remaining), or INCIDENT. Rewrite it; "
                     f"anything for a seat goes through SendMessage or a channel note, not here.\n")
    sys.exit(2)
try:
    ts = datetime.datetime.strptime(m.group(2) + ' ' + m.group(3), '%Y-%m-%d %H:%M').replace(tzinfo=now.tzinfo)
    off = abs((now - ts).total_seconds()) / 60
except Exception: off = 9999
if off > skew:
    sys.stderr.write(f"[pm-guard] Header timestamp is {int(off)} min off the clock. The clock is {clock}: rewrite the header "
                     f"with that value (never estimate the time).\n")
    sys.exit(2)
if sent + 1 > budget:
    sys.stderr.write(f"[pm-guard] Budget spent: this would be message {sent + 1} to the human since their last reply "
                     f"(budget {budget}). Rewrite the final text as the quiet line `·`; open asks stay in TEAM.md's Current "
                     f"state block until the human replies. Only a real incident may break this: start the line with INCIDENT.\n")
    sys.exit(2)
sys.exit(0)
PY
