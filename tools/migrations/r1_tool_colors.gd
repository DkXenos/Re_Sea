# one-off: give each ToolData its accent colour.
# the .tres files are canonical so schema changes go through little scripts
# like this instead of regenerating from python.
#   godot --headless --script tools/migrations/r1_tool_colors.gd
extends SceneTree

const COLORS := {
	"rinse": Color8(96, 178, 230),
	"swab": Color8(214, 120, 200),
	"magnifier": Color8(240, 200, 84),
	"cutter": Color8(226, 106, 92),
}


func _init() -> void:
	for id: String in COLORS:
		var path := "res://data/tools/%s.tres" % id
		var tool_data: ToolData = load(path)
		if tool_data == null:
			push_error("missing " + path)
			continue
		tool_data.color = COLORS[id]
		ResourceSaver.save(tool_data, path)
		print("  %s -> %s" % [id, tool_data.color.to_html(false)])
	quit()
