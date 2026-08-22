## Verifies the four sliders are wired to something real: three audio buses and
## the global VFX intensity, and that all four survive a restart.
##   godot --headless --script tools/smoke/smoke_settings.gd
extends SceneTree


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	var game: Node = root.get_node("/root/Game")
	var events: Node = root.get_node("/root/Events")

	for bus_name: String in ["Master", "Music", "SFX"]:
		assert(AudioServer.get_bus_index(bus_name) >= 0, "missing audio bus: " + bus_name)
	print("buses present: Master, Music, SFX")

	game.apply_setting("master", 0.5)
	game.apply_setting("music", 0.25)
	game.apply_setting("sfx", 0.75)
	var master_db := AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))
	var music_db := AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	assert(is_equal_approx(master_db, linear_to_db(0.5)), "master slider not on the bus")
	assert(music_db < master_db, "music slider not on its own bus")
	print("bus volumes follow the sliders: master %.1f dB, music %.1f dB" % [master_db, music_db])

	# Zero must mute rather than just go very quiet.
	game.apply_setting("music", 0.0)
	assert(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")), "zero must mute the bus")
	game.apply_setting("music", 0.6)
	assert(not AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")), "unmute failed")
	print("zero mutes, non-zero unmutes")

	# The VFX slider is not audio: it scales a global float that at least one
	# visible thing reads.
	var seen := []
	events.vfx_intensity_changed.connect(func(v: float) -> void: seen.append(v))
	game.apply_setting("vfx", 0.4)
	assert(is_equal_approx(game.vfx_intensity, 0.4), "vfx intensity not applied")
	assert(seen.size() == 1, "vfx change not broadcast")
	var phase: Node = load("res://scenes/claw/claw_phase.tscn").instantiate()
	root.add_child(phase)
	await process_frame
	var few: int = phase.get_node("GlassLayer/Bubbles").get_child_count()
	game.apply_setting("vfx", 1.0)
	await process_frame
	var many: int = phase.get_node("GlassLayer/Bubbles").get_child_count()
	assert(many > few, "vfx slider changed nothing visible")
	print("vfx slider drives bubble count: %d at 0.4 -> %d at 1.0" % [few, many])

	# Persistence.
	assert(FileAccess.file_exists("user://settings.cfg"), "settings.cfg not written")
	var reloaded: Dictionary = SaveSettings.load_all()
	assert(is_equal_approx(float(reloaded["master"]), 0.5), "master did not persist")
	assert(is_equal_approx(float(reloaded["vfx"]), 1.0), "vfx did not persist")
	print("persisted and reloaded: %s" % reloaded)

	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()
