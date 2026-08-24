#!/usr/bin/env bash
# Runs every headless check. Any SCRIPT ERROR, Parse Error, failed load, leaked
# instance or failed assertion counts as a failure.
#   ./tools/smoke/run_all.sh
set -u
cd "$(dirname "$0")/../.."

BAD='SCRIPT ERROR|Parse Error|Failed loading|leaked|still in use|assertion failed|Condition .* is true|TIMED OUT'
fail=0

# A failed GDScript assertion aborts the coroutine without ever reaching quit(),
# so a broken check hangs forever instead of failing. macOS has no `timeout`, so
# enforce a limit by hand and treat overrunning as a failure.
LIMIT=${SMOKE_LIMIT:-180}

run_limited() {
  local log; log=$(mktemp)
  "$@" >"$log" 2>&1 &
  local pid=$!
  local waited=0
  while kill -0 "$pid" 2>/dev/null; do
    if [ "$waited" -ge "$LIMIT" ]; then
      kill -9 "$pid" 2>/dev/null
      echo "TIMED OUT after ${LIMIT}s (a failed assertion never reaches quit)" >>"$log"
      break
    fi
    sleep 1; waited=$((waited + 1))
  done
  wait "$pid" 2>/dev/null
  cat "$log"; rm -f "$log"
}

check() {
  local name="$1"; shift
  local out; out=$(run_limited "$@" 2>&1)
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
# Every visual is a PNG on disk, nothing is drawn or built at runtime, and
# nothing here decides what the designers' art looks like (revision 3 §1).
ASSET_SRC="scenes/ autoload/ systems/ data/ main.gd main.tscn"
static_check "no drawn visuals, no 3D" \
  "$(grep -rnE '_draw\(|draw_rect|draw_circle|draw_line|draw_polygon|draw_texture|ColorRect|Polygon2D|Line2D|Node3D|Sprite3D|Camera3D' \
      --include='*.gd' --include='*.tscn' --include='*.tres' $ASSET_SRC 2>/dev/null)"
static_check "no shaders, lighting or runtime textures" \
  "$(grep -rnE 'ShaderMaterial|CanvasModulate|PointLight2D|LightOccluder2D|normal_map|GradientTexture|NoiseTexture' \
      --include='*.gd' --include='*.tscn' --include='*.tres' $ASSET_SRC 2>/dev/null)"
static_check "panels are NinePatchRect over a PNG, never StyleBoxFlat" \
  "$(grep -rnE 'StyleBoxFlat' --include='*.gd' --include='*.tscn' --include='*.tres' \
      $ASSET_SRC assets/ 2>/dev/null)"
# State is a named animation or its own PNG - never a tint on designer art.
static_check "no modulate expressing state on a game object" \
  "$(grep -nE '\.modulate' scenes/claw/claw.gd scenes/claw/tank_item.gd \
      scenes/claw/fish.gd scenes/desk/bin_row.gd 2>/dev/null
     grep -rnE '\b(sprite|_sprite|_item_sprite|_hotspot_sprite|mark|bubble)\.modulate' \
      --include='*.gd' scenes/ 2>/dev/null)"
# Scaling a sprite in code is code deciding a display size, so each one that
# genuinely has to exist is a named constant quoted in ASSETS.md.
static_check "sprites are scaled only by a named display constant" \
  "$(grep -rnE '\.scale *= *' --include='*.gd' scenes/ autoload/ systems/ 2>/dev/null \
      | grep -vE 'BASE_SCALE|TOOL_ICON_SCALE|BIN_DISPLAY_SCALE|BOX_CARD_SCALE')"
# Anything that differs between items lives in that item's .tres.
static_check "no per-asset special cases in code" \
  "$(grep -rnE '\.id *== *&?"' --include='*.gd' $ASSET_SRC 2>/dev/null)"
static_check "exactly two autoloads" \
  "$(awk '/^\[autoload\]/{f=1;next} /^\[/{f=0} f&&/=/{n++} END{if(n!=2) print "found " n}' project.godot)"

echo "Boot:"
check "boots (2 frames)"   godot --headless --quit-after 2
check "boots (240 frames)" godot --headless --quit-after 240

echo "Systems:"
for t in claw desk shift inspect layout report ocean box upgrades upgrade_play puzzle settings debug extensibility full; do
  check "smoke_$t" godot --headless --script "tools/smoke/smoke_$t.gd"
done
check "smoke_claw --fail" godot --headless --script tools/smoke/smoke_claw.gd -- --fail
check "smoke_full --bad"  godot --headless --script tools/smoke/smoke_full.gd -- --bad
check "smoke_shift day 1"  godot --headless --script tools/smoke/smoke_shift.gd -- 1

# Revision 2 §6: the experimental calibration puzzle must be genuinely
# optional. One seed, one whole game each way, and the ocean has to end in the
# same place - the flag is the only difference.
echo "Feature flag:"
ending() {
  run_limited godot --headless --script tools/smoke/smoke_full.gd -- --seed "$1" "${@:2}" \
    2>&1 | grep -o 'reached ending: health=[0-9]*'
}
with=$(ending 20260823)
without=$(ending 20260823 --no-puzzle)
if [ -n "$with" ] && [ "$with" = "$without" ]; then
  printf '  PASS  full run identical with the puzzle off (%s)\n' "$with"
else
  printf '  FAIL  puzzle flag changes the run: on=[%s] off=[%s]\n' "$with" "$without"; fail=1
fi

if [ "$fail" -eq 0 ]; then echo "All checks passed."; else echo "FAILURES above."; fi
exit $fail
