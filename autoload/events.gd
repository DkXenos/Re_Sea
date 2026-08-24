## Autoload 1 of 2: the signal bus. Nothing here has state or logic - it exists
## so no scene ever needs a hardcoded path to another scene.
extends Node

# --- flow ---
signal scene_change_requested(scene_key: StringName)
signal day_started(day: DayData)
## A phase scene emits this when it is done; main.gd asks DayManager what comes
## next. No scene ever names another scene.
signal phase_finished()

# --- claw phase ---
signal budget_changed(remaining: int, maximum: int)
signal item_grabbed(item: ItemData)
signal grip_failed(item: ItemData)
signal grip_preview_changed(chance: float, item: ItemData)

# --- desk phase ---
signal tool_armed(tool_id: StringName)
signal tool_used(tool_id: StringName, revealed_field: String)
signal item_sorted(entry: CarriedItem, chosen: int, correct: bool)
## A sealed box was opened and became its contents (revision 4 §2).
signal container_opened(box: CarriedItem, contents: Array)
signal rulebook_toggled(open: bool)

# --- global feedback ---
signal ocean_health_changed(value: int)
signal sfx_requested(sfx_name: StringName)
signal vfx_intensity_changed(value: float)
signal hotspots_visible_changed(value: bool)
## The material pool moved, a component was crafted, or a blueprint was built.
signal blueprints_changed()
## One component of a blueprint was crafted (revision 4 §3).
signal component_crafted(component: ComponentData)
## The fitted upgrade changed. Swappable between days since revision 3.
signal upgrade_equipped(upgrade_id: StringName)
signal toast_requested(text: String)

# --- debug (F1 overlay) ---
signal debug_command(command: StringName, arg: Variant)
