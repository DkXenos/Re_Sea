## Settings persistence. Run progress is deliberately NOT saved - closing the
## game loses the run, which is correct for a prototype.
class_name SaveSettings
extends RefCounted

const PATH := "user://settings.cfg"
const DEFAULTS := {"master": 0.8, "music": 0.6, "sfx": 0.8, "vfx": 1.0}
## On/off settings. `hotspots` draws the ring overlay marking where each tool
## can be used; on by default, and an accessibility option rather than a
## difficulty one.
const TOGGLES := {"hotspots": true}

static func load_all() -> Dictionary:
	var values := DEFAULTS.duplicate()
	values.merge(TOGGLES.duplicate())
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return values
	for key: String in DEFAULTS:
		values[key] = clampf(float(cfg.get_value("audio", key, DEFAULTS[key])), 0.0, 1.0)
	for key: String in TOGGLES:
		values[key] = bool(cfg.get_value("display", key, TOGGLES[key]))
	return values

static func save_all(values: Dictionary) -> void:
	var cfg := ConfigFile.new()
	for key: String in values:
		cfg.set_value("display" if TOGGLES.has(key) else "audio", key, values[key])
	cfg.save(PATH)
