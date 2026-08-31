# all player-facing text. item names and rule text are in the .tres files,
# everything else is here.
# some of the wording in here is rough, needs a pass from someone who actually
# writes well
class_name Strings
extends RefCounted

const TABLE: Dictionary = {
	# --- menu ---
	"game_subtitle": "Sort the trash, save the sea",
	"menu_play": "Start",
	"menu_settings": "Settings",
	"menu_quit": "Quit",
	"menu_hint": "Click a button or press Enter",

	# --- settings ---
	"settings_title": "SETTINGS",
	"settings_master": "Master Volume",
	"settings_music": "Music",
	"settings_sfx": "Sound Effects",
	"settings_vfx": "Visual Effect Intensity",
	"settings_back": "Back",

	# --- cutscene ---
	"cutscene_skip": "Skip (Esc)",
	"cutscene_advance": "Click or press Enter to continue",
	"cutscene_line_1": "This bay used to be full of fish. Now it is full of what the land throws away.",
	"cutscene_line_2": "Every day the current brings a new delivery. Some of it is obvious. Some of it is in disguise.",
	"cutscene_line_3": "You run the claw. Lift it, inspect it, sort it. The sea counts every decision you make.",

	# --- day start ---
	"day_label": "DAY {n}",
	"day_rules_today": "Today's rules",
	"day_quota": "Sorting target",
	"day_budget": "Shift time",
	"day_tools": "Tools available",
	"day_tools_locked": "Not available yet",
	"day_begin": "Lower the Claw",
	"day_seed": "Seed: {n}",

	# --- claw phase ---
	"budget_label": "Shift time left",
	"budget_cost": "costs {n}",
	"budget_too_low": "Not enough shift time for that",
	"shift_end": "End Shift",
	"shift_to_desk": "To the Sorting Desk",
	"shift_to_claw": "To the Claw Machine",
	"shift_unsorted": "{n} still unsorted",
	"shift_over": "Shift time is up",
	"ocean_label": "Machines built: {have} / {need}",
	"upgrade_active": "Gear fitted: {v}  -  drop {drop} · tool {tool} · sort {sort}",
	"upgrade_none": "No gear fitted  -  drop {drop} · tool {tool} · sort {sort}",
	"claw_grip_chance": "Grip chance: {n}%",
	"claw_rail_locked": "Rail is resetting - it can be moved again in a moment",
	"claw_grip_none": "Line the claw up with something",
	"claw_hint": "A/D or the arrow keys to move, Space to drop. The console buttons work too.",
	"claw_drop_button": "DROP  ({n})",
	"claw_slipped": "Slipped! It fell back down.",

	# --- desk phase ---
	"desk_inventory": "Collected items",
	"desk_empty": "Everything has been sorted",
	"desk_no_selection": "Pick an item before choosing a bin",
	"desk_rulebook_button": "Rulebook (R)",
	"inspect_zoom_hint": "Scroll to zoom, drag to pan",
	"tools_locked": "No tools available today",
	"tools_armed": "{tool} ready - click the item",
	"evidence_title": "EVIDENCE LOG",
	"reveal_nothing": "Nothing on this one for that tool.",
	"inspect_found": "Found: {v}   (shift time -{n})",
	"inspect_coarse": "There is something, but it did not read clearly. Use the tool once more to read it. (shift time -{n})",
	"inspect_nothing": "Nothing on this one for that tool. The shift time is spent anyway -{n}.",
	"inspect_rules_title": "RULES IN FORCE TODAY",
	"inspect_question": "Looks like {mat}. Do you believe it?",
	"inspect_question_labeled": "Marked {label}, looks like {mat}. Do you believe it?",
	"inspect_pick_first": "Pick an item from the list on the left.",
	"tools_cost_label": "costs {n}",

	# --- evidence chips ---
	"chip_material": "LOOKS LIKE: {v}",
	"chip_label": "MARKING: {v}",
	"chip_weight": "WEIGHT: {v} kg",
	"chip_no_label": "no marking",
	"chip_residue": "RESIDUE: {v}",
	"chip_residue_type": "RESIDUE TYPE: {v}",
	"chip_true_material": "TRUE MATERIAL: {v}",
	"chip_tag": "CODE / LABEL: {v}",
	"field_residue_yes": "present",
	"field_residue_no": "clean",
	"field_none": "none",
	"field_no_tag": "no code",
	"field_multilayer_suffix": " (multilayer)",

	# --- mystery box ---
	"box_sealed": "Sealed crate - no telling what is inside",
	"box_opened_toast": "Crate opened: {n} items added to the list",
	"box_needs_tool": "{tool} opens this",
	"box_no_tool": "Nothing here can cut it open yet",
	"box_question": "Sealed shut. Cut it open to find out.",
	"box_not_sortable": "Cut the crate open before binning it",
	"tool_wrong_for_box": "{tool} is no use on a sealed crate",
	"tool_only_opens": "{tool} only opens sealed crates",
	"tools_cost_free": "free",

	# --- bins ---
	"bin_organic": "ORGANIC",
	"bin_recyclable": "RECYCLABLE",
	"bin_hazard": "HAZARDOUS",
	"bin_landfill": "LANDFILL",

	# --- rulebook ---
	"rulebook_title": "RULEBOOK",
	"rulebook_codes": "WHAT THE RECYCLING CODES MEAN",
	"rulebook_codes_note": "These codes are printed or stamped on the item itself. A code tells you what it is made of - not whether it is clean.",
	"rulebook_close": "Close",
	"rulebook_empty": "No special rules today",
	"rulebook_general": "GENERAL",

	# --- day report ---
	"report_title": "DAY {n} REPORT",
	"report_machines": "Machines built {have} / {need}",
	"report_quota_met": "Target reached",
	"report_quota_failed": "Target missed",
	"report_recovered": "MATERIAL RECOVERED",
	"report_recovered_line": "{n}  {v}",
	"report_recovered_none": "Nothing was sorted correctly, so nothing reaches the workshop.",
	"report_recovered_note": "Only what goes in the right bin becomes blueprint material.",
	"report_wasted": "{n} sorted wrongly - lost, not stored.",
	"report_mistakes": "What was missed",
	"report_missed": "Never checked: {v}",
	"report_rule": "Broke: {v}",
	"report_should_be": "Should have been: {v}",
	"report_you_put": "You put it in: {v}",
	"report_next": "Next Day",
	"report_perfect": "No mistakes. Nice work.",

	# --- after-day screen ---
	"after_title": "END OF DAY {n}",
	"after_tab_result": "Today's Haul",
	"after_tab_tech": "Technology",
	"after_tab_gear": "Gear",
	"after_next_day": "Start the Next Day",
	"after_last_day": "Finish the Last Shift",
	"after_sorted": "Correct {ok}  ·  wrong {bad}  ·  unsorted {left}",
	"after_budget": "Shift time used {spent} of {max}, {left} left",

	# --- blueprints ---
	"blueprint_requires": "Needs: {v}",
	"blueprint_done": "DONE",
	"tech_prev": "‹",
	"tech_next": "›",
	"tech_pool": "Materials in store:  {v}",
	"tech_pool_empty": "Materials in store:  none yet",
	"tech_parts": "Parts fitted {have} / {need}",
	"tech_craft": "BUILD {v}",
	"tech_craft_locked": "Finish every part first",
	"tech_craft_done": "ALREADY BUILT",
	"tech_unlocks": "Building this unlocks the gear: {v}",
	"tech_part_todo": "Not built yet",
	"tech_part_done": "Fitted",
	"tech_needs": "Needs {n} {v}",
	"tech_have": "have {n}",
	"tech_short": "Short {n} {v}",
	"tech_rakit": "Build",
	"tech_rakit_done": "Fitted",
	"tech_close": "Close",

	# --- upgrades ---
	"upgrade_equip": "Fit",
	"upgrade_equipped": "Fitted",
	"upgrade_locked": "Locked",
	"upgrade_benefit": "+ {v}",
	"upgrade_cost": "- {v}",

	# --- calibration puzzle (EXPERIMENTAL) ---
	# delete this block with scenes/puzzle/
	"puzzle_title": "PUT THE MACHINE'S STEPS IN ORDER",
	"puzzle_hint": "Drag the steps into the right order, then run it. A wrong order costs nothing - try as many times as you like.",
	"puzzle_run": "Run",
	"puzzle_skip": "Skip",
	"puzzle_continue": "Continue",
	"puzzle_success": "The machine runs correctly. Shift time +{n}.",
	"puzzle_wrong": "That order is not right yet.",

	# --- endings ---
	# three endings, decided by how many machines were actually built
	"end_bad_title": "THE SEA WAS LEFT BEHIND",
	"end_bad_body": "Five days went by and not one machine was ever built. The rubbish keeps arriving, and there is nothing here to stop it.",
	"end_regular_title": "A START",
	"end_regular_body": "{have} of {need} machines are running. The bay is starting to breathe again, but the work is not finished.",
	"end_good_title": "THE BAY RECOVERED",
	"end_good_body": "All three machines are running. The coral is growing back and the fish have come home. You finished it.",
	"over_retry": "Try Again",
	"over_menu": "Main Menu",

	# --- pause ---
	"pause_title": "PAUSED",
	"pause_resume": "Resume",
	"pause_menu": "Main Menu",
}

# resin codes off real packaging. fixed reference table, not per-item content,
# so it stays here instead of becoming 14 more .tres files.
const CODES: Array = [
	["PET 1", "clear plastic for drink bottles. Recyclable if it is clean."],
	["HDPE 2", "thick plastic for jerrycans and soap bottles. Recyclable if it is clean."],
	["PVC 3", "flexible waterproof plastic. Hard to recycle."],
	["PE", "thin plastic film, often laminated onto paper."],
	["PS 6", "styrofoam. Almost never accepted for recycling."],
	["PA 6", "nylon, used for rope and netting."],
	["PAP", "paper and card. If it is lined with plastic or foil the layers cannot be separated."],
	["ALU", "aluminium. Valuable, and it can be recycled over and over."],
	["GL", "glass. Recyclable, but mixed glass is often rejected."],
	["Pb", "lead. A toxic heavy metal - always hazardous."],
]

static func t(key: String) -> String:
	if TABLE.has(key):
		return TABLE[key]
	push_warning("Missing string key: %s" % key)
	return key

# t() with {placeholder} subs, e.g. tf("day_label", {"n": 3})
static func tf(key: String, args: Dictionary) -> String:
	return t(key).format(args)

static func category_name(cat: int) -> String:
	match cat:
		ItemData.Category.ORGANIC: return t("bin_organic")
		ItemData.Category.RECYCLABLE: return t("bin_recyclable")
		ItemData.Category.HAZARD: return t("bin_hazard")
		ItemData.Category.LANDFILL: return t("bin_landfill")
	return "?"
