# settings only. run progress isn't saved, closing the game loses the run.
#
# Nothing else lives here. Whether the guided tour has been seen used to, and
# that is exactly what made it impossible to see twice - it is a fact about the
# sitting, not about the machine, so Game keeps it in memory for the launch and
# it starts again the next time the game is opened.
class_name SaveSettings
extends RefCounted

const PATH := "user://settings.cfg"
const DEFAULTS := {"master": 0.8, "music": 0.6, "sfx": 0.8, "vfx": 1.0}

static func load_all() -> Dictionary:
	var values := DEFAULTS.duplicate()
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return values
	for key: String in DEFAULTS:
		values[key] = clampf(float(cfg.get_value("audio", key, DEFAULTS[key])), 0.0, 1.0)
	return values

static func save_all(values: Dictionary) -> void:
	var cfg := ConfigFile.new()
	# read first, so anything already in the file that is not ours survives
	cfg.load(PATH)
	for key: String in values:
		cfg.set_value("audio", key, values[key])
	cfg.save(PATH)

