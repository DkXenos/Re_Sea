## Plays the entire game headlessly through the real main.tscn: menu, cutscene,
## five days of claw and desk, a report after each, then the ending.
##   godot --headless --script tools/smoke/smoke_full.gd
extends SceneTree

var game: Node
var main: Node
var bad_mode := false
var verbose := false
# 0 = let the game pick. a fixed seed makes two runs comparable, which is how
# the puzzle gets proved optional.
var fixed_seed := 0
## "" leaves the claw unmodified; "first" fits whatever is available.
var upgrade_choice := "first"
## Play the run without crafting anything, to read off the raw material supply.
var no_craft := false


func _init() -> void:
	_run()


func _current() -> Node:
	var holder: Node = main.get_node("SceneHolder")
	return holder.get_child(0) if holder.get_child_count() > 0 else null


func _run() -> void:
	await process_frame
	# Headless physics still ticks in real time, so a full five-day run takes
	# well over a minute at 1x. Scaling time compresses the same simulated run
	# into far fewer frames; the claw's descent step stays well inside the
	# grab-area overlap window, so nothing is skipped.
	# Pass --realtime when the numbers matter (balance checks); the scaled run
	# is a different but equally valid simulation, since where the claw stops
	# during a coarser descent step changes which item it contacts.
	Engine.time_scale = 1.0 if "--realtime" in OS.get_cmdline_user_args() else 6.0
	bad_mode = "--bad" in OS.get_cmdline_user_args()
	verbose = "--verbose-days" in OS.get_cmdline_user_args()
	var args := OS.get_cmdline_user_args()
	var seed_at := args.find("--seed")
	if seed_at >= 0 and seed_at + 1 < args.size():
		fixed_seed = int(args[seed_at + 1])
	game = root.get_node("/root/Game")
	game.sfx_enabled = false  # see Game.sfx_enabled
	if "--no-puzzle" in args:
		game.feature_calibration_puzzle = false
	if "--no-upgrade" in args:
		upgrade_choice = ""
	no_craft = "--no-craft" in args
	main = load("res://main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	var seen: Array[String] = []
	# assert the shape of the run off a run that was actually played, never
	# off state set by hand
	var tier := int(game.visual_tier)
	var tier_rises := 0
	var claimed := 0
	var first_claim_day := 0
	var seen_after: Dictionary = {}
	var guard := 0
	while guard < 40000:
		guard += 1
		await physics_frame
		if int(game.visual_tier) > tier:
			tier_rises += 1
		tier = int(game.visual_tier)
		if game.unlocked_blueprints.size() > claimed:
			claimed = game.unlocked_blueprints.size()
			if first_claim_day == 0:
				first_claim_day = game.day_index + 1
			if verbose:
				print("     built %s on day %d, pool now %s"
					% [game.unlocked_blueprints[-1], game.day_index + 1, _pool_line()])
		var scene: Node = _current()
		if scene == null:
			continue
		var kind := scene.name
		if seen.is_empty() or seen[-1] != String(kind) + "|" + str(game.day_index):
			seen.append(String(kind) + "|" + str(game.day_index))
			print("-> %-10s day_index=%d tier=%d" % [kind, game.day_index, game.visual_tier])
		match String(kind):
			"MainMenu":
				scene.get_node("UiLayer/Root/Buttons/PlayButton").pressed.emit()
				if fixed_seed != 0:
					game.start_run(fixed_seed)
			"Cutscene":
				scene._finish()
			"DayStart":
				scene.get_node("UiLayer/Root/BeginButton").pressed.emit()
			"ShiftPhase":
				_drive_shift(scene)
			"DayReport":
				if verbose:
					var b: Dictionary = scene._result
					print("     quota %d, sorted %d, correct %d, wrong %d, "
						% [b["quota"], b["sorted"], b["correct"], b["wrong"]]
						+ "shortfall -%d, clean +%d, delta %+d"
						% [b["shortfall"], b["clean_bonus"], b["delta"]])
				scene.get_node("UiLayer/Root/NextButton").pressed.emit()
			"AfterDay":
				# entered every day, so work it the way a player would - craft
				# whatever the pool can pay for, keep an upgrade on, move on
				if verbose and not seen_after.has(game.day_index):
					seen_after[game.day_index] = true
					print("     pool after day %d: %s" % [game.day_index + 1,
						_pool_line()])
				_drive_after_day(scene)
			"GameOver":
				print("reached ending: %s built=%d title=%s" % [game.ending_kind(),
					game.unlocked_blueprints.size(),
					scene.get_node("UiLayer/Root/TitleLabel").text])
				break
	print("frames=%d  scenes visited=%d" % [guard, seen.size()])
	print("tier rises=%d  blueprints claimed=%d  first claim on day %d"
		% [tier_rises, claimed, first_claim_day])
	assert(String(_current().name) == "GameOver", "run did not reach an ending")
	if bad_mode:
		assert(game.ending_kind() == &"bad",
			"sorting everything wrong should never build a machine, got the %s ending"
			% game.ending_kind())
	elif no_craft:
		print("supply run: nothing was crafted, the pool above is five days' worth")
	else:
		# every meta system has to be reachable inside one normal run
		assert(tier_rises >= 2,
			"a well-played run must cross at least two tier thresholds, crossed %d" % tier_rises)
		assert(claimed >= 2,
			"a well-played run must claim at least two blueprints, claimed %d" % claimed)
		# a well-played run finishes one whole blueprint by end of day 3
		assert(first_claim_day > 0 and first_claim_day <= 3,
			"the first blueprint must be built by the end of day 3, built on day %d"
			% first_claim_day)
	game.stop_all_sfx()
	for i in 10:
		await process_frame
	quit()


## The spendable material pool, for the tuning report.
func _pool_line() -> String:
	var parts: Array[String] = []
	for category in ItemData.Category.values():
		parts.append("%s %d" % [Strings.category_name(category),
			game.material_count(category)])
	return "  ".join(parts)


# crafts every finished blueprint, keeps the first available upgrade on.
# driving the real buttons is the whole point - the old tier check called Game
# directly and passed for ages without ever firing in a real run.
func _drive_after_day(scene: Node) -> void:
	# A claimed blueprint may open the calibration puzzle over this screen.
	# Skipping it is what a player who does not want it would do.
	for child: Node in scene.get_children():
		if child is CanvasLayer and child.has_method("_close"):
			child._close()
			return
	# page through the sheets, craft what the pool can pay for, hit CRAFT on any
	# sheet that's done. setting Game.crafted by hand proves nothing.
	if _drive_tech(scene):
		return
	if game.equipped_upgrade == &"" and upgrade_choice != "":
		for row: Control in scene.get_node("UiLayer/Root/GearPage/Scroll/Rows").get_children():
			for child: Node in row.get_children():
				if child is Button and not (child as Button).disabled:
					(child as Button).pressed.emit()
					return
	scene.get_node("UiLayer/Root/NextButton").pressed.emit()


## One action per call, so every craft goes through the popup that owns it and
## the diagram is rebuilt in between. Returns true while there was something to
## do, which keeps the screen open until the tab is worked out.
func _drive_tech(scene: Node) -> bool:
	# --no-craft measures what 5 days SUPPLY with nothing spent. that's the
	# number the component costs have to be written against, and you can't see
	# it in a run that's busy spending.
	if no_craft:
		return false
	var page: Control = scene.get_node("UiLayer/Root/TechPage")
	var popup: Control = scene.get_node("PopupLayer/Popup/Panel")
	if scene.get_node("PopupLayer").visible:
		var rakit: Button = popup.get_node("CraftPartButton")
		if not rakit.disabled:
			rakit.pressed.emit()
		popup.get_node("CloseButton").pressed.emit()
		return true
	for sheet in game.blueprints.size():
		var bp: BlueprintData = scene._current_blueprint()
		if bp == null:
			return false
		if not page.get_node("CraftButton").disabled:
			page.get_node("CraftButton").pressed.emit()
			return true
		for component: ComponentData in bp.components:
			if game.can_craft(component):
				scene._open_popup(component)
				return true
		page.get_node("NextButton").pressed.emit()
	return false


## Works the shift the way a player would: stay at the tank while there is
## something worth grabbing, switch to the desk when there is not, and switch
## back when the desk is clear. Driving both views at once would never exercise
## the tab switch, and the desk only refreshes its inventory when it becomes
## the active view.
func _drive_shift(shift: Node) -> void:
	var claw_view: Node = shift.get_node("ClawView")
	var desk_view: Node = shift.get_node("DeskView")
	# unsorted_items() already counts a sealed box as work waiting, so the
	# driver crosses to the desk to open one without needing to be told.
	var unsorted: Array = game.unsorted_items()
	var worth_grabbing: bool = game.can_afford(&"drop") and claw_view.has_work()
	var on_claw: bool = shift._view == 0
	if on_claw:
		if worth_grabbing:
			_drive_claw(claw_view)
		elif not unsorted.is_empty():
			shift._toggle_view()
	else:
		if not unsorted.is_empty():
			_drive_desk(desk_view)
		elif worth_grabbing:
			shift._toggle_view()


func _drive_claw(scene: Node) -> void:
	var world: Node = scene.get_node("TankLayer/TankContainer/TankViewport/TankWorld")
	var claw: Node2D = world.get_node("Claw")
	var items: Node2D = world.get_node("Items")
	if claw.state != 0 or not game.can_afford(&"drop"):
		return
	if items.get_child_count() > 0:
		claw.position.x = clampf(items.get_child(0).position.x, claw.min_x, claw.max_x)
	claw.start_drop()


## Sorts using the same resolver the game judges with, so the run survives to
## day 5 and the win ending is reached rather than the loss ending.
func _drive_desk(scene: Node) -> void:
	var inspect: Control = scene.get_node("UiLayer/Root/InspectPanel")
	var bins: Control = scene.get_node("UiLayer/Root/BinRow")
	# boxes aren't sortable, so open them first. free, so no reason not to.
	var inventory: Control = scene.get_node("UiLayer/Root/InventoryPanel")
	for card: Node in inventory.get_node("Scroll/Grid").get_children():
		for child: Node in card.get_children():
			if child is Button and (child as Button).text == Strings.t("box_open") \
					and not (child as Button).disabled:
				(child as Button).pressed.emit()
				return
	var entry = inspect.entry
	if entry == null or not game.can_afford(&"sort"):
		return
	var day = game.current_day()
	var choice: int = int(RuleChecker.resolve(entry.data, day.active_rules)["category"])
	if bad_mode:
		choice = (choice + 1) % 4  # sort everything wrong, to reach the loss ending
	bins.bin_chosen.emit(choice)
