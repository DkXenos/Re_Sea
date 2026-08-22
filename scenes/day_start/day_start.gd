## The rules-for-today card. Day 1 is the tutorial: surface info only, one rule,
## tools disabled. There is no separate tutorial system - the day data says it.
extends Node2D


func _ready() -> void:
	var day := Game.current_day()
	var root := $UiLayer/Root
	root.get_node("TitleLabel").text = Strings.tf("day_label", {"n": day.day_number})
	root.get_node("IntroLabel").text = day.intro_text
	root.get_node("RulesTitle").text = Strings.t("day_rules_today")
	root.get_node("SeedLabel").text = Strings.tf("day_seed", {"n": Game.run_seed})
	root.get_node("StatsLabel").text = "%s %d          %s %d          %s %s" % [
		Strings.t("day_quota"), day.quota,
		Strings.t("day_budget"), day.budget,
		Strings.t("day_tools"), _tools_summary(day)]
	var list: VBoxContainer = root.get_node("RulesScroll/RulesList")
	for rule: RuleData in day.active_rules:
		var label := Label.new()
		label.text = "-  " + rule.text
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 17)
		list.add_child(label)
	var begin: Button = root.get_node("BeginButton")
	begin.text = Strings.t("day_begin")
	begin.pressed.connect(func() -> void:
		Events.sfx_requested.emit(&"ui_click")
		Events.phase_finished.emit())
	begin.grab_focus()


func _tools_summary(day: DayData) -> String:
	if not day.tools_enabled():
		return Strings.t("day_tools_locked")
	var parts: Array[String] = []
	for tool_data: ToolData in Game.tools:
		if tool_data.id in day.available_tools:
			parts.append(tool_data.display_name)
	return ", ".join(parts)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"advance"):
		Events.phase_finished.emit()
		get_viewport().set_input_as_handled()
