## Post-playtest migration: `visible_material` is what an item LOOKS like, and
## it is free information. Three items had a resin code in it - "PET bening",
## "HDPE bening" - which is not something you can see. You read a resin code off
## the moulded mark, and that is what `visible_label` and `tag_text` are for.
##
## Leaking it into the free field also blunted the best trap in the game: the
## paint bottle is supposed to look exactly like the drinking-water bottle, and
## only the residue tells them apart.
##
## The codes stay in `visible_label` and `tag_text`, where they are genuinely
## printed on the object - and the rulebook now explains what each one means.
##   godot --headless --script tools/migrations/r3_plain_visible_material.gd
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
