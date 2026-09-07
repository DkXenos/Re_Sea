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

	# --- opening cutscene ---
	# eleven beats over five stills. the arc: what the bay was, the first thing
	# that did not belong, the delivery that followed, us going down to look, and
	# the three sheets that are the answer.
	"cutscene_skip": "Skip (Esc)",
	"cutscene_advance": "Click or press Enter",
	"open_1": "The bay used to be loud. Gulls arguing, waves turning over, a crab picking a fight with the tide.",
	"open_2": "You could stand in the shallows and count the fish going past your ankles.",
	"open_3": "Then one afternoon something came down through the light that did not belong to any of it.",
	"open_4": "One cup. Nobody watching it fall thought it was worth a second look.",
	"open_5": "One became a hundred. A hundred became the delivery the current brings every single day.",
	"open_6": "And none of it arrives labelled. A clean cup and a lined one sink in exactly the same way.",
	"open_7": "So we went down to look at it properly.",
	"open_8": "The turtle cannot tell which of these it is safe to swallow. Neither could we, at first.",
	"open_9": "Three machines. Every part of them built out of what the bay hands back to us.",
	"open_10": "But a machine is only as good as what we feed it, and the sea does not sort itself.",
	"open_11": "Lower the claw. Look before you decide.",

	# --- day start ---
	"day_label": "DAY {n}",
	"day_rules_today": "Today's rules",
	"day_quota": "Sorting target",
	"machines_title": "Machines",
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
	"shift_nothing_sorted": "Shift over, and not one thing sorted. Nothing reaches the workshop today.",
	"shift_sea_cleared": "Every last piece out of the water and into a bin. The seabed is clear.",
	"machines_label": "Machines built: {have} / {need}",
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
	"desk_rulebook_short": "i",
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
	"tools_not_today": "not today",

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
	"rulebook_where": "WHERE THINGS GO",
	"rulebook_where_note": "The baseline sorting guide. A special rule above always beats this - a recyclable with residue on it is no longer recyclable.",
	"rulebook_codes": "WHAT THE RECYCLING CODES MEAN",
	"rulebook_codes_note": "These codes are printed or stamped on the item itself. A code tells you what it is made of - not whether it is clean.",
	"rulebook_close": "Close",
	"rulebook_empty": "No special rules today",
	"rulebook_general": "GENERAL",

	# --- day report ---
	"report_title": "DAY {n} REPORT",
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
	"after_haul_title": "TODAY'S HAUL",
	"after_haul_empty": "Nothing was sorted today.",
	"after_haul_belongs": "belongs in {v}",

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
	"tech_progress": "{have} / {need}",
	"tech_short_any": "Not enough materials yet",
	"tech_material_source": "Materials come from the bins. Only items you put in the RIGHT bin are stored - a wrong bin loses the item.",
	"tech_rakit": "Build",
	"tech_rakit_done": "Fitted",
	"tech_close": "Close",

	# --- upgrades ---
	"upgrade_equip": "Fit",
	"upgrade_equipped": "Fitted",
	"upgrade_locked": "Locked",
	"upgrade_benefit": "+ {v}",
	"upgrade_cost": "- {v}",

	# --- endings ---
	# four tiers, one per machine built. the sheet in NEW-ASSETS/Cutscene/Endings
	# is the spec these follow.
	"end_0_title": "THE BAY WAS LEFT AS IT WAS",
	"end_0_body": "Five shifts, and not one machine ever left the workshop. The current will bring another delivery tomorrow, and there is still nothing here to meet it.",
	"end_1_title": "A FIRST MACHINE",
	"end_1_body": "One machine is running. Small stretches of the bay are beginning to clear, but most of it is still under the same water it was.",
	"end_2_title": "THE WATER IS TURNING",
	"end_2_body": "Two machines are running. Large parts of the bay are recovering and the wildlife is coming back to them. There is one more to build.",
	"end_3_title": "THE BAY CAME BACK",
	"end_3_body": "All three machines are running together. What the sea used to swallow goes back out as something usable, and the water is clear enough to count the fish again - and this time that is not a memory, it is the view.",
	"end_built": "Machines built: {have} / {need}",
	"over_retry": "Try Again",
	"over_menu": "Main Menu",

	# --- pause ---
	"pause_title": "PAUSED",
	"pause_resume": "Resume",
	"pause_menu": "Main Menu",
}

# the baseline sorting guide, in the same shape as CODES: which bin a material
# goes in and why. Fixed reference text, not per-item content - an item is
# still judged by its own .tres plus the day's rules, this only explains the
# reasoning so a new player isn't guessing.
#
# [category, what it is, why it goes there]
const GUIDANCE: Array = [
	[ItemData.Category.ORGANIC, "Food waste",
		"fruit, peel, eggshell, leftovers. It rots down, so it belongs in ORGANIC."],
	[ItemData.Category.ORGANIC, "Garden waste",
		"leaves, twigs, cuttings. Natural matter, same bin as food."],
	[ItemData.Category.ORGANIC, "Natural fibre",
		"cotton, wool, jute - a COTTON 100% shirt is plant matter and rots down."],

	[ItemData.Category.RECYCLABLE, "Paper and card",
		"newspaper, plain card, a clean paper cup. Marked PAPER or PAP. Clean and unlined only."],
	[ItemData.Category.RECYCLABLE, "Glass",
		"bottles and jars, marked GL. Glass is recyclable however many times it has been used."],
	[ItemData.Category.RECYCLABLE, "Clean plastic",
		"marked PET 1 or HDPE 2. Clean means clean - rinse it or it is not recyclable."],
	[ItemData.Category.RECYCLABLE, "Polyester and synthetic fabric",
		"marked POLYESTER. It is plastic woven into cloth, not a natural fibre, so it goes here and NOT in ORGANIC."],
	[ItemData.Category.RECYCLABLE, "Metal",
		"aluminium and steel, marked ALU. Valuable and recycled over and over."],

	[ItemData.Category.HAZARD, "Chemical residue",
		"engine oil, solvent paint, expired medicine. Whatever held it is hazardous, whatever it is made of."],
	[ItemData.Category.HAZARD, "Pesticide and toxic metals",
		"a pesticide-soaked cloth, anything marked Pb (lead). It poisons the bay if it goes anywhere else."],

	[ItemData.Category.LANDFILL, "A used cup, or anything with residue",
		"a used paper cup is soaked through. Residue means it cannot be recycled - it goes to LANDFILL, unless the residue is chemical, which makes it HAZARDOUS."],
	[ItemData.Category.LANDFILL, "Laminated packaging",
		"paper bonded to plastic or foil, e.g. PAP 22 - PE liner. The layers cannot be separated, so nothing can be recovered."],
	[ItemData.Category.LANDFILL, "Soiled tissue and the rest",
		"used tissue, and anything that is not organic, not clean enough to recycle and not chemical."],
]


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
