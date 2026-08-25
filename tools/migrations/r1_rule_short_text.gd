# one-off: give each rule the short form for the inspect panel checklist. the
# rulebook still prints `text` verbatim.
#   godot --headless --script tools/migrations/r1_rule_short_text.gd
extends SceneTree

const SHORT := {
	"r_baseline": "Bahannya menentukan tempatnya",
	"r_residue": "Ada sisa kotoran  ->  RESIDU",
	"r_multilayer": "Kemasan berlapis  ->  RESIDU",
	"r_chem_residue": "Sisa oli / cat / obat  ->  B3",
	"r_flammable": "Label MUDAH TERBAKAR  ->  B3",
	"r_alu_always": "Aluminium  ->  DAUR ULANG",
}


func _init() -> void:
	for id: String in SHORT:
		var path := "res://data/rules/%s.tres" % id
		var rule: RuleData = load(path)
		if rule == null:
			push_error("missing " + path)
			continue
		rule.short_text = SHORT[id]
		ResourceSaver.save(rule, path)
		print("  %s -> %s" % [id, rule.short_text])
	quit()
