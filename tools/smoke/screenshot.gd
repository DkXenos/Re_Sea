## Renders one scene to a PNG so layout can be checked without a human looking
## at a window. Usage:
##   godot --script tools/smoke/screenshot.gd -- <scene_key> <out.png> [day]
extends SceneTree

const SCENES := {
	"claw": "res://scenes/claw/claw_phase.tscn",
	"desk": "res://scenes/desk/desk_phase.tscn",
	"menu": "res://scenes/main_menu/main_menu.tscn",
	"settings": "res://scenes/settings/settings.tscn",
	"cutscene": "res://scenes/cutscene/cutscene.tscn",
	"day_start": "res://scenes/day_start/day_start.tscn",
	"report": "res://scenes/report/day_report.tscn",
	"game_over": "res://scenes/game_over/game_over.tscn",
}


func _init() -> void:
	_run()


func _run() -> void:
	await process_frame
	var args := OS.get_cmdline_user_args()
	var key: String = args[0] if args.size() > 0 else "claw"
	var out: String = args[1] if args.size() > 1 else "/tmp/shot.png"
	var day: int = int(args[2]) if args.size() > 2 else 1
	var game: Node = root.get_node("/root/Game")
	game.start_run(4242)
	for i in day - 1:
		game.advance_day()
	if key == "desk":
		for item in game.current_day().item_pool:
			game.add_to_inventory(item)
	var scene: Node = load(SCENES[key]).instantiate()
	root.add_child(scene)
	for i in 20:
		await process_frame
	if args.size() > 3 and args[3] == "rulebook":
		scene.get_node("UiLayer/Root/RulebookPanel").toggle(true)
		for i in 5:
			await process_frame
	await process_frame
	var img: Image = root.get_texture().get_image()
	img.save_png(out)
	print("saved ", out, " ", img.get_size())
	quit()
