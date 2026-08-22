#!/usr/bin/env bash
# Runs every headless check. Any SCRIPT ERROR, Parse Error, failed load, leaked
# instance or failed assertion counts as a failure.
#   ./tools/smoke/run_all.sh
set -u
cd "$(dirname "$0")/../.."

BAD='SCRIPT ERROR|Parse Error|Failed loading|leaked|still in use|assertion failed|Condition .* is true'
fail=0

check() {
  local name="$1"; shift
  local out; out=$("$@" 2>&1)
  local hits; hits=$(printf '%s' "$out" | grep -icE "$BAD")
  if [ "$hits" -eq 0 ]; then
    printf '  PASS  %s\n' "$name"
  else
    printf '  FAIL  %s\n' "$name"
    printf '%s\n' "$out" | grep -iE "$BAD" | head -5 | sed 's/^/        /'
    fail=1
  fi
}

echo "Boot:"
check "boots (2 frames)"   godot --headless --quit-after 2
check "boots (240 frames)" godot --headless --quit-after 240

echo "Systems:"
for t in claw desk report settings debug extensibility full; do
  check "smoke_$t" godot --headless --script "tools/smoke/smoke_$t.gd"
done
check "smoke_claw --fail" godot --headless --script tools/smoke/smoke_claw.gd -- --fail
check "smoke_full --bad"  godot --headless --script tools/smoke/smoke_full.gd -- --bad

if [ "$fail" -eq 0 ]; then echo "All checks passed."; else echo "FAILURES above."; fi
exit $fail
