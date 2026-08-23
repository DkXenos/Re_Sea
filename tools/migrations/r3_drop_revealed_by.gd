## Revision 3 §1.6 migration: ItemData no longer carries revealed_by_rinse /
## _swab / _magnifier / _cutter. Which tool reveals what is the "tool" key on
## each hotspot, which was always the value the game actually checked - the
## booleans were a second, per-tool source of truth that a fifth tool would
## have needed a code change to extend.
##
## Re-saving each item drops the dead keys from the .tres.
##   godot --headless --script tools/migrations/r3_drop_revealed_by.gd
extends SceneTree


func _init() -> void:
	var dir := DirAccess.open("res://data/items/")
	if dir == null:
		push_error("no data/items/")
		quit()
		return
	var names := dir.get_files()
	names.sort()
	for file_name: String in names:
		var clean := file_name.trim_suffix(".remap")
		if not clean.ends_with(".tres"):
			continue
		var path := "res://data/items/" + clean
		var item: ItemData = load(path)
		if item == null:
			continue
		ResourceSaver.save(item, path)
		var tools: Array[String] = []
		for spot: Dictionary in item.hotspots:
			if not String(spot["tool"]) in tools:
				tools.append(String(spot["tool"]))
		print("  %-16s revealed by: %s" % [item.id, ", ".join(tools) if tools else "-"])
	quit()
