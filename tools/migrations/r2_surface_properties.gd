# one-off: give every item the property line the inspect panel shows instead
# of the name. only things you could actually see or feel by handling it.
#   godot --headless --script tools/migrations/r2_surface_properties.gd
extends SceneTree

const PROPS := {
	"banana_peel": ["lunak", "berserat", "berbau"],
	"fish_bone": ["keras", "ringan", "berpori"],
	"pet_bottle": ["tembus pandang", "lentur", "mengapung"],
	"alu_can": ["logam tipis", "penyok", "ringan"],
	"styrofoam_tray": ["sangat ringan", "berbusa", "mengapung"],
	"car_battery": ["berat", "kotak kaku", "ada kutub logam"],
	"oil_jerrycan": ["buram", "kaku", "permukaan licin"],
	"paint_bottle": ["tembus pandang", "kaku", "ada noda kental"],
	"juice_carton": ["kaku", "bagian dalam licin", "berbentuk kotak"],
	"eco_tote": ["lentur", "berserat", "ada jahitan"],
	"paper_cup": ["kaku", "permukaan licin", "ringan"],
	"spray_can": ["logam", "terasa padat", "ada nozel"],
	"glass_jar": ["tembus pandang", "berat", "licin"],
	"fishing_net": ["berjaring", "lentur", "basah"],
}


func _init() -> void:
	for id: String in PROPS:
		var path := "res://data/items/%s.tres" % id
		var item: ItemData = load(path)
		if item == null:
			push_error("missing " + path)
			continue
		var props: Array[String] = []
		props.assign(PROPS[id])
		item.surface_properties = props
		ResourceSaver.save(item, path)
		print("  %-16s %s" % [id, item.surface_label()])
	quit()
