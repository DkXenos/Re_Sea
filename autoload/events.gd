## Autoload 1 of 2: the signal bus. Nothing here has state or logic - it exists
## so no scene ever needs a hardcoded path to another scene.
extends Node

# --- flow ---
signal scene_change_requested(scene_key: StringName)
signal day_started(day: DayData)
signal claw_phase_finished()
signal desk_phase_finished()

# --- claw phase ---
signal grabs_changed(remaining: int)
signal item_grabbed(item: ItemData)
signal fish_grabbed()
signal grip_failed(item: ItemData)
signal grip_preview_changed(chance: float, item: ItemData)

# --- desk phase ---
signal tool_armed(tool_id: StringName)
signal tool_used(tool_id: StringName, revealed_field: String)
signal item_sorted(entry: CarriedItem, chosen: int, correct: bool)
signal rulebook_toggled(open: bool)

# --- global feedback ---
signal ocean_health_changed(value: int)
signal sfx_requested(sfx_name: StringName)
signal vfx_intensity_changed(value: float)
signal toast_requested(text: String)

# --- debug (F1 overlay) ---
signal debug_command(command: StringName, arg: Variant)
