# signal bus. no state, no logic, just so scenes don't need each other's paths
extends Node

signal scene_change_requested(scene_key: StringName)
signal day_started(day: DayData)
signal phase_finished()

signal budget_changed(remaining: int, maximum: int)
signal item_grabbed(item: ItemData)
signal grip_failed(item: ItemData)
signal grip_preview_changed(chance: float, item: ItemData)

signal tool_armed(tool_id: StringName)
signal tool_used(tool_id: StringName, revealed_field: String)
signal item_sorted(entry: CarriedItem, chosen: int, correct: bool)
signal container_opened(box: CarriedItem, contents: Array)
signal rulebook_toggled(open: bool)

signal sfx_requested(sfx_name: StringName)
signal vfx_intensity_changed(value: float)
signal hotspots_visible_changed(value: bool)
signal blueprints_changed()
signal component_crafted(component: ComponentData)
signal upgrade_equipped(upgrade_id: StringName)
signal toast_requested(text: String)

# F1 overlay
signal debug_command(command: StringName, arg: Variant)
