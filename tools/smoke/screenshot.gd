## Renders one scene to a PNG so layout can be checked without a human looking
## at a window. Usage:
##   godot --script tools/smoke/screenshot.gd -- <scene_key> <out.png> [day]
extends SceneTree

const SCENES := {
	"claw": "res://scenes/claw/claw_phase.tscn",
	"desk": "res://scenes/desk/desk_phase.tscn",
	"shift": "res://scenes/shift/shift_phase.tscn",
	"menu": "res://scenes/main_menu/main_menu.tscn",
	"settings": "res://scenes/settings/settings.tscn",
	"cutscene": "res://scenes/cutscene/cutscene.tscn",
	"day_start": "res://scenes/day_start/day_start.tscn",
	"report": "res://scenes/report/day_report.tscn",
	"after_day": "res://scenes/after_day/after_day.tscn",
	"game_over": "res://scenes/game_over/game_over.tscn",
}


func _init() -> void:
	_run()


## Sorts a day's worth of items, getting some of them wrong, so the report has
## real mistakes to explain.
func _play_a_messy_day(game: Node) -> void:
	var day = game.current_day()
	var rules: Array[RuleData] = day.active_rules
	var n: int = 0
	for item in day.item_pool:
		var entry = game.add_to_inventory(item)
		n += 1
		var choice: int = int(RuleChecker.resolve(item, rules)["category"])
		if n % 3 == 0:
			choice = (choice + 2) % 4
		var correct := RuleChecker.judge(entry, choice, rules)
		game.stats["sorted"] = int(game.stats["sorted"]) + 1
		var key := "correct" if correct else "wrong"
		game.stats[key] = int(game.stats[key]) + 1


func _run() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	var key: String = args[0] if args.size() > 0 else "claw"
	var out: String = args[1] if args.size() > 1 else "/tmp/shot.png"
	var day: int = int(args[2]) if args.size() > 2 else 1
	var game: Node = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	game.start_run(4242)
	for i in day - 1:
		game.advance_day()
	if key == "desk" or (key == "shift" and args.size() > 3 and args[3] in ["desk", "evidence"]):
		for item in game.current_day().item_pool:
			game.add_to_inventory(item)
	if key == "report" or key == "after_day":
		_play_a_messy_day(game)
	if key == "after_day":
		# The after-day screen reads what the report worked out, so stand in
		# for the report having run.
		game.commit_day_result(game.end_day_breakdown())
	var scene: Node = load(SCENES[key]).instantiate()
	root.add_child(scene)
	for i in 20:
		await process_frame
	if key == "shift" and args.size() > 3 and args[3] == "evidence":
		scene._toggle_view()
		for i in 3:
			await process_frame
		var inspect: Control = scene.get_node("DeskView/UiLayer/Root/InspectPanel")
		for e in game.inventory:
			if e.data.id == &"oil_jerrycan":
				inspect.show_entry(e)
				inspect._armed = &"rinse"
				inspect._use_tool_at(Vector2(160, 160) + (Vector2(0.38, 0.70) - Vector2(0.5, 0.5)) * 288.0)
				inspect._armed = &"swab"
				inspect._use_tool_at(Vector2(160, 160) + (Vector2(0.62, 0.60) - Vector2(0.5, 0.5)) * 288.0)
				inspect._armed = &""
		for i in 5:
			await process_frame
	if key == "shift" and args.size() > 3 and args[3] == "desk":
		scene._toggle_view()
		for i in 3:
			await process_frame
	if key == "after_day" and args.size() > 3:
		var tabs := {"result": 0, "tech": 1, "gear": 2}
		if tabs.has(args[3]):
			scene._show_tab(int(tabs[args[3]]))
			for i in 3:
				await process_frame
	if args.size() > 3 and args[3] == "rulebook":
		scene.get_node("UiLayer/Root/RulebookPanel").toggle(true)
		for i in 5:
			await process_frame
	await process_frame
	var img: Image = root.get_texture().get_image()
	img.save_png(out)
	print("saved ", out, " ", img.get_size())
	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()
