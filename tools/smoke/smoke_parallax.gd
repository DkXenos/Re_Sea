# The window is the only place the sea exists, and it has to stay filled.
#
# Two ways this breaks silently: a layer that is a few pixels short leaves a
# transparent gap at one end of the rail, which reads as a hole in the water and
# only shows up once you drive the claw all the way over; and a layer that stops
# tracking the camera goes back to being a still picture, which looks fine in a
# screenshot and wrong in motion.
#   godot --headless --script tools/smoke/smoke_parallax.gd
#
# NOTE the --script file compiles before the autoloads register, so the scene is
# loaded inside _run rather than preloaded up here.
extends SceneTree

var failures: int = 0


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	var game: Node = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	game.start_run(777)

	var phase: Node2D = load("res://scenes/claw/claw_phase.tscn").instantiate()
	root.add_child(phase)
	await process_frame

	var view: Vector2 = phase.TANK_VIEW
	var camera: Camera2D = phase.get_node(
		"TankLayer/TankContainer/TankViewport/TankWorld/Camera")
	var layers: Array = phase._layers
	assert(not layers.is_empty(), "no parallax layers were built")
	print("layers built: %d" % layers.size())

	# the sea is inside the viewport, so nothing outside the frame can be water
	assert(phase.has_node("HullLayer/Hull"), "no hull behind the frame")
	var hull: TextureRect = phase.get_node("HullLayer/Hull")
	assert(hull.texture != null, "the hull has no texture")
	assert(String(hull.texture.resource_path).ends_with("hull_wall.png"),
		"the hull is drawing %s, which is not hull" % hull.texture.resource_path)
	assert(hull.stretch_mode == TextureRect.STRETCH_TILE,
		"the hull must tile at native size, never stretch")

	# a backdrop row keeps its texture's proportions - it may be scaled, but
	# only by the same amount on both axes
	for sprite: Sprite2D in layers:
		if not is_equal_approx(sprite.scale.x, sprite.scale.y):
			_fail("%s is scaled %s - that is a stretch" %
				[sprite.texture.resource_path.get_file(), sprite.scale])

	# drive the claw to both ends of the rail and check what the window is
	# actually showing at each. the camera smooths, so read where it ended up
	# rather than assuming it went exactly where it was sent.
	var claw: Node2D = phase.get_node("TankLayer/TankContainer/TankViewport/TankWorld/Claw")
	var stops: Array[float] = [phase._camera_min(), phase._camera_max(),
		(phase._camera_min() + phase._camera_max()) * 0.5]
	var seen_centres: Array[float] = []
	var moved: Dictionary = {}
	for stop: float in stops:
		claw.position.x = clampf(stop, claw.min_x, claw.max_x)
		# let the smoothing settle on the new target
		for f in 150:
			await process_frame
		var centre: float = camera.get_screen_center_position().x
		seen_centres.append(centre)
		var left: float = centre - view.x * 0.5
		for i in layers.size():
			var sprite: Sprite2D = layers[i]
			if sprite.texture == null:
				continue
			moved[i] = moved.get(i, []) + [sprite.position.x]
			# scenery is meant to have gaps between the clumps; only a backdrop
			# has to reach the whole way across
			var width: float = sprite.scale.x * sprite.texture.get_width()
			if width < view.x:
				continue
			if sprite.position.x > left or sprite.position.x + width < left + view.x:
				_fail("%s leaves a gap with the window at %.0f..%.0f (layer %.0f..%.0f)"
					% [sprite.texture.resource_path.get_file(), left, left + view.x,
					sprite.position.x, sprite.position.x + width])
	# if the claw never actually moved the view, the check above proved nothing
	var swept: float = seen_centres.max() - seen_centres.min()
	var rail: float = phase._camera_max() - phase._camera_min()
	assert(swept > rail * 0.95,
		"the camera swept %.0f of %.0f - the ends of the rail went unchecked"
		% [swept, rail])
	print("camera swept %.0f of %.0f units, both ends checked" % [swept, rail])

	# every layer with any depth to it has to actually move against the world
	for i in moved:
		var seen: Array = moved[i]
		var scroll: float = phase._layer_scroll[i]
		var shifted: bool = not is_equal_approx(seen[0], seen[1])
		if scroll < 1.0 and not shifted:
			_fail("layer %d has scroll %.2f but never moved" % [i, scroll])
		if is_zero_approx(scroll) and shifted:
			_fail("layer %d has scroll 0 and should be pinned, but moved" % i)
	assert(failures == 0, "%d parallax problem(s) - see above" % failures)
	print("layers hold the window at both ends of the rail and move against it")
	print("parallax verified")

	phase.free()
	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()


func _fail(message: String) -> void:
	failures += 1
	printerr("  PARALLAX: %s" % message)
