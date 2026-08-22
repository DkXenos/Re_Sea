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

# --- static rules that no runtime test can catch ---
echo "Rules:"
static_check() {
  local name="$1"; local hits="$2"
  if [ -z "$hits" ]; then printf '  PASS  %s\n' "$name"
  else printf '  FAIL  %s\n' "$name"; printf '%s\n' "$hits" | sed 's/^/        /'; fail=1; fi
}
# Game objects animate through SpriteFrames, never through code (revision 1 §1).
static_check "no tweens in game-object scripts" \
  "$(grep -n 'create_tween' scenes/claw/claw.gd scenes/claw/tank_item.gd \
      scenes/claw/fish.gd scenes/desk/bin_row.gd 2>/dev/null)"
static_check "no tweened transforms or frames anywhere" \
  "$(grep -rnE 'tween_property\([^,]+, *"(position|rotation|scale|frame)' \
      --include='*.gd' scenes/ autoload/ systems/ 2>/dev/null)"
# Every visual is a PNG.
static_check "no ColorRect / draw_* / 3D nodes" \
  "$(grep -rnE 'ColorRect|draw_rect|draw_circle|draw_line|draw_texture|Node3D|Sprite3D|Camera3D' \
      --include='*.gd' --include='*.tscn' --include='*.tres' \
      scenes/ autoload/ systems/ data/ main.gd main.tscn 2>/dev/null)"
static_check "exactly two autoloads" \
  "$(awk '/^\[autoload\]/{f=1;next} /^\[/{f=0} f&&/=/{n++} END{if(n!=2) print "found " n}' project.godot)"

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
