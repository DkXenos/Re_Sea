## Generates assets/items/hotspots_<id>.png from each ItemData's `hotspots`
## array, and points `hotspot_overlay` at the result.
##
##   godot --headless --script tools/gen_hotspot_overlays.gd
##   godot --headless --import
##   godot --headless --script tools/gen_hotspot_overlays.gd
##
## Twice, with an import between: Godot cannot load a PNG it has not imported
## yet, so the first pass writes the images and the second points each
## ItemData.hotspot_overlay at them.
##
## The rings used to be drawn into the item PNGs themselves, which made the
## search trivial and meant the owner was testing an easier game than the real
## one. They are a separate, toggleable overlay now.
##
## This reads the .tres files, which are the single source of truth for hotspot
## positions - so the rings can never drift from the data the game checks
## against. Tool colours come from ToolData.color for the same reason.
extends SceneTree

const SIZE := 160
const RING_WIDTH := 3.0
const DASH_ARC := 18.0
const DASH_STEP := 30.0
const ITEM_DIR := "res://data/items/"


func _init() -> void:
	var colors := _tool_colors()
	var dir := DirAccess.open(ITEM_DIR)
	var made := 0
	var linked := 0
	for file_name: String in dir.get_files():
		if not file_name.ends_with(".tres"):
			continue
		var item: ItemData = load(ITEM_DIR + file_name)
		if item == null:
			continue
		var out_path := "res://assets/items/hotspots_%s.png" % item.id
		_draw_overlay(item, colors, out_path)
		if ResourceLoader.exists(out_path):
			item.hotspot_overlay = load(out_path)
			ResourceSaver.save(item, ITEM_DIR + file_name)
			linked += 1
		made += 1
	print("wrote %d overlays, linked %d" % [made, linked])
	if linked < made:
		print("  run `godot --headless --import` then this script again to link them")
	quit()


func _tool_colors() -> Dictionary:
	var out := {}
	var dir := DirAccess.open("res://data/tools/")
	for file_name: String in dir.get_files():
		if not file_name.ends_with(".tres"):
			continue
		var tool_data: ToolData = load("res://data/tools/" + file_name)
		if tool_data != null:
			out[String(tool_data.id)] = tool_data.color
	return out


func _draw_overlay(item: ItemData, colors: Dictionary, out_path: String) -> void:
	var img := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for spot: Dictionary in item.hotspots:
		var color: Color = colors.get(String(spot["tool"]), Color.WHITE)
		var centre: Vector2 = Vector2(spot["pos"]) * SIZE
		var radius: float = float(spot["radius"]) * SIZE
		_dashed_ring(img, centre, radius, color)
	# Godot needs the file on disk before it can be imported and loaded.
	img.save_png(ProjectSettings.globalize_path(out_path))


## A dashed ring, drawn pixel by pixel. This is a generator writing a PNG, not
## the game drawing a shape at runtime - the game only ever loads the file.
func _dashed_ring(img: Image, centre: Vector2, radius: float, color: Color) -> void:
	var inner := radius - RING_WIDTH * 0.5
	var outer := radius + RING_WIDTH * 0.5
	var x_from := maxi(0, int(centre.x - outer) - 1)
	var x_to := mini(SIZE - 1, int(centre.x + outer) + 1)
	var y_from := maxi(0, int(centre.y - outer) - 1)
	var y_to := mini(SIZE - 1, int(centre.y + outer) + 1)
	for y in range(y_from, y_to + 1):
		for x in range(x_from, x_to + 1):
			var offset := Vector2(x, y) + Vector2(0.5, 0.5) - centre
			var dist := offset.length()
			if dist < inner or dist > outer:
				continue
			var angle := fposmod(rad_to_deg(offset.angle()), DASH_STEP)
			if angle > DASH_ARC:
				continue
			img.set_pixel(x, y, color)
