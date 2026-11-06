#!/usr/bin/env bash
# team/scripts/install-hooks.sh - wire team/scripts/pm-guard.sh into the project's .claude/settings.json (v2.10).
# Run by the HUMAN (or the spin-up recipe) from the project root before the PM's first session: the auto-mode
# classifier refuses a session that edits its own permission or hook settings, so the PM cannot do this itself.
# Idempotent; keeps every other key (permissions, existing hooks). The hooks run in every worktree but pm-guard.sh
# exits at once outside the primary checkout, so seats are unaffected.
# Usage: team/scripts/install-hooks.sh            -> .claude/settings.json of this project (committed; relative command)
#        team/scripts/install-hooks.sh <dir>      -> <dir>/.claude/settings.local.json with the script's ABSOLUTE path,
#                                                    for a PM session that was started in <dir> instead of the project root.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
[ -f team/scripts/pm-guard.sh ] || { echo "team/scripts/pm-guard.sh missing - copy team/ from the framework first" >&2; exit 1; }
chmod +x team/scripts/pm-guard.sh
if [ -n "${1:-}" ]; then TARGET="$(cd "$1" && pwd)/.claude/settings.local.json"; CMD="bash $(pwd)/team/scripts/pm-guard.sh"
else TARGET=".claude/settings.json"; CMD="bash team/scripts/pm-guard.sh"; fi
mkdir -p "$(dirname "$TARGET")"
TARGET="$TARGET" CMD="$CMD" python3 - <<'PY'
import json, os
p, base = os.environ['TARGET'], os.environ['CMD']
d = json.load(open(p)) if os.path.exists(p) else {}
hooks = d.setdefault('hooks', {})
want = {'SessionStart': 'session', 'UserPromptSubmit': 'prompt', 'Stop': 'stop'}
for event, mode in want.items():
    cmd = f'{base} {mode}'
    groups = hooks.setdefault(event, [])
    if any(h.get('command') == cmd for g in groups for h in g.get('hooks', [])): continue
    groups.append({'hooks': [{'type': 'command', 'command': cmd, 'timeout': 20}]})
json.dump(d, open(p, 'w'), indent=2); open(p, 'a').write('\n')
print(f"installed pm-guard hooks in {p} (SessionStart, UserPromptSubmit, Stop)")
PY
echo "Restart the PM session (or start it now) so the hooks load. Verify: team/scripts/health.sh prints 'OK   pm-guard hooks installed'."
