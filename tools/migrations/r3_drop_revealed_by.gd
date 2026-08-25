# one-off: kill revealed_by_rinse/_swab/_magnifier/_cutter off ItemData. which
# tool reveals what is the "tool" key on the hotspot, which is what the game
# was checking anyway - the booleans were a second source of truth and a fifth
# tool would have needed a code change.
# re-saving each item drops the dead keys.
#   godot --headless --script tools/migrations/r3_drop_revealed_by.gd
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
