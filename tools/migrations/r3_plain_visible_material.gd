# one-off, after a playtest. visible_material is what it LOOKS like and it's
# free info. three items had a resin code in there ("PET bening", "HDPE
# bening") which you can't see - you read that off the moulded mark, which is
# what visible_label and tag_text are for.
#
# it also killed the best trap in the game: the paint bottle is meant to look
# exactly like the drinking water bottle and only the residue separates them.
#
# codes stay in visible_label/tag_text where they're actually printed.
#   godot --headless --script tools/migrations/r3_plain_visible_material.gd
extends SceneTree

const PLAIN := {
	"pet_bottle": "plastik bening",
	"paint_bottle": "plastik bening",
	"oil_jerrycan": "plastik tebal",
}


func _init() -> void:
	for id: String in PLAIN:
		var path := "res://data/items/%s.tres" % id
		var item: ItemData = load(path)
		if item == null:
			push_error("missing " + path)
			continue
		var was: String = item.visible_material
		item.visible_material = PLAIN[id]
		ResourceSaver.save(item, path)
		print("  %-16s %-14s -> %-16s (code kept on label %s / tag %s)"
			% [id, was, item.visible_material, item.visible_label, item.tag_text])
	quit()
