# all player-facing text. item names and rule text are in the .tres files,
# everything else is here.
# some of the wording in here is rough, needs a pass from someone who actually
# writes well
class_name Strings
extends RefCounted

const TABLE: Dictionary = {
	# --- menu ---
	"menu_hint": "Click anywhere to begin  \u00b7  Esc for settings",

	# --- tutorial ---
	# One entry per step in TutorialSteps. The overlay looks up
	# "tut_<key>_title" and "tut_<key>_body", so adding a step is a step dict
	# plus two lines here and nothing else.
	"tut_next": "Next",
	"tut_done": "Got it",
	"tut_progress": "{n} / {total}",

	"tut_claw_intro_title": "THE CLAW MACHINE",
	"tut_claw_intro_body": "This is the cockpit. The claw goes down, brings things up, and everything it brings up waits for you at the sorting desk. First, what the panel is telling you.",
	"tut_claw_day_title": "THE DAY",
	"tut_claw_day_body": "Which shift you are on. There are five, and each one brings its own rules and its own delivery from the current.",
	"tut_claw_power_title": "SHIFT TIME",
	"tut_claw_power_body": "Your power for the day. Every drop of the claw, every tool you use and every item you bin spends some of it. When it runs out the shift ends, wherever you got to.",
	"tut_claw_cost_title": "COST PER DROP",
	"tut_claw_cost_body": "What one drop costs out of that shift time. Reaching for something you did not need is the quickest way to run the meter down.",
	"tut_claw_quota_title": "THE QUOTA",
	"tut_claw_quota_body": "How many items you have sorted, against how many the day asks for. Sorted, not grabbed - a thing sitting on the desk does not count yet, and the shift cannot end until the day's number is met.",
	"tut_claw_move_title": "MOVE THE RAIL",
	"tut_claw_move_body": "Slide the claw left and right with these, or with A and D. Line it up over the piece you want.",
	"tut_claw_grab_title": "DROP THE CLAW",
	"tut_claw_grab_body": "Sends the claw down. Space or S does the same. The grip is not certain - heavy, awkward things slip, and a slip still costs you the drop.",
	"tut_claw_sorting_title": "TO THE SORTING DESK",
	"tut_claw_sorting_body": "Press this, or Tab, to go and deal with what you have pulled up. You can move between the tank and the desk as often as you like - switching is free.",

	"tut_desk_intro_title": "THE SORTING DESK",
	"tut_desk_intro_body": "This is where the day is actually won or lost. Nothing here will tell you whether you got one right - you find that out when the day closes.",
	"tut_desk_inventory_title": "COLLECTED ITEMS",
	"tut_desk_inventory_body": "Everything the claw brought up. Click one to put it under the lens. Work through them in whatever order you like.",
	"tut_desk_item_title": "LOOK BEFORE YOU DECIDE",
	"tut_desk_item_body": "The item as it appears, and what it appears to be. That is a guess, not a fact - a paper cup with a plastic lining looks exactly like one without.",
	"tut_desk_tools_title": "THE TOOLS",
	"tut_desk_tools_body": "Each one answers a different question. The MAGNIFIER tells you what a thing is really made of, under whatever is printed on the outside. The SWAB says whether a stain is chemical or just food. The RINSE actually washes a stain off. The CUTTER opens sealed crates. Every use costs shift time, so reach for the one that answers the question you actually have.",
	"tut_desk_outcome_title": "WHAT THE TOOLS TELL YOU",
	"tut_desk_outcome_body": "Every answer lands here as a chip and stays there. \"MARKING: paper\" is simply what is printed on the thing, free with every item - a claim, not a fact. \"MADE OF: paper with a thin plastic film bonded to the inside\" is what the magnifier came back with, and that is how a cup that says paper turns out to be lined. \"STAIN IS: chemical\" means the swab found something that will not wash off - that item is hazardous whatever it is made of. \"RINSED CLEAN\" means the rinse worked and the thing is now clean enough to recycle. A tool that finds nothing still costs you, and that is an answer too.",
	"tut_desk_rules_title": "TODAY'S RULES",
	"tut_desk_rules_body": "The rules in force right now. A special rule always beats the plain \"what is it made of\" answer - a recyclable with a stain still on it is not recyclable until the stain is off.",
	"tut_desk_rulebook_title": "THE GUIDEBOOK",
	"tut_desk_rulebook_body": "Press this, or R, for the whole book: every rule in force today and which bin each kind of thing belongs in. It costs nothing and you can open it as often as you want.",
	"tut_desk_bins_title": "THE FOUR BINS",
	"tut_desk_bins_body": "ORGANIC for what rots - food, garden waste, cotton and wool. RECYCLABLE for clean paper, glass and clean plastic. HAZARDOUS for chemicals, and for anything a chemical soaked into. RESIDUE for the rest: still-stained things, laminated packaging, used tissue, and anything made of several materials that cannot be pulled apart.",
	"tut_desk_commit_title": "SORTING IS FINAL",
	"tut_desk_commit_body": "Click a bin and the item is gone. The right bin stores its material for the workshop; the wrong bin loses it for good. The desk will not say which - the end of the day will.",
	"tut_desk_blueprints_title": "WHAT IT IS ALL FOR",
	"tut_desk_blueprints_body": "Material from the right bins builds three machines. That is the run: sort well enough, for long enough, to get all three of them into the water.",
	"tut_desk_end_title": "THAT IS EVERYTHING",
	"tut_desk_end_body": "Look before you decide, and open the guidebook whenever you are not sure. Good luck out there.",

	# the end-of-day screen. the tab switch in the middle is a step the player
	# has to answer with a real press - see TutorialSteps.AFTER_DAY.
	"tut_after_intro_title": "END OF THE DAY",
	"tut_after_intro_body": "The claw is parked and the day's books are closed. Nothing more can be sorted now - this screen is where you find out how it went, and where you decide what to do with what you brought back. There are two tabs at the top, and they do very different jobs.",
	"tut_after_missed_title": "WHAT WAS MISSED",
	"tut_after_missed_body": "One row for every item that went in the wrong bin: what it was, the bin you chose, and the bin it belonged in. This is the only place the game ever tells you - the desk stays quiet on purpose. A day with nothing wrong on it says so instead.",
	"tut_after_recovered_title": "WHAT THE DAY PAID OUT",
	"tut_after_recovered_body": "Only the items that went in the RIGHT bin become material, counted here by bin. A wrong bin is not a smaller payout - that item is gone for good and never appears on this list. What is here is the store the second tab spends.",
	"tut_after_summary_title": "THE DAY IN NUMBERS",
	"tut_after_summary_body": "Whether you met the day's target, how many you got right and wrong, how many were left in the water, and how much shift time it took. Missing a target is not the end of a run by itself - running out of days with the machines unbuilt is.",
	"tut_after_switch_title": "NOW OPEN TECHNOLOGY",
	"tut_after_switch_body": "That is the whole of this page. The other tab is where everything you just recovered actually gets spent, and it is the half of this screen most people never open. Press Technology at the top - the tour waits here until you do.",
	"tut_after_tech_sheet_title": "THE BLUEPRINT",
	"tut_after_tech_sheet_body": "One machine per sheet: its name, what it is for, and a drawing of it. The faint lines on the drawing are the parts that are not built yet, and each one fills in as you build it - so the sheet is the progress bar as well as the picture.",
	"tut_after_tech_paging_title": "THE OTHER SHEETS",
	"tut_after_tech_paging_body": "There are three machines and these arrows move between them. Getting all three built and into the water is the run - that is what every day of sorting is for.",
	"tut_after_tech_parts_title": "THE PARTS",
	"tut_after_tech_parts_body": "A machine goes together one part at a time. Each row names a part, what it costs and out of which bins, and carries its own Build button. The cost turns red when your store will not cover it, and the button stays dead until it will.",
	"tut_after_tech_pool_title": "WHAT YOU HAVE",
	"tut_after_tech_pool_body": "Your whole store, bin by bin, carried across every day of the run. None of it expires - a part you cannot afford tonight is a part you can afford after another day of sorting well.",
	"tut_after_tech_build_title": "SWITCHING IT ON",
	"tut_after_tech_build_body": "Once every part is fitted, this assembles the machine, and the line beside it says what that changes about the claw. A machine you build stays on for the rest of the run - nothing to fit, nothing to choose, no way to turn it off again.",
	"tut_after_next_title": "ON TO TOMORROW",
	"tut_after_next_body": "This starts the next day whenever you are ready. Read what you want off this screen first: once tomorrow begins, today's report is gone.",

	# --- settings ---
	"settings_title": "SETTINGS",
	"settings_open": "Settings",
	"settings_master": "Master Volume",
	"settings_music": "Music",
	"settings_sfx": "Sound Effects",
	"settings_vfx": "Visual Effect Intensity",
	"settings_back": "Back",
	"settings_menu": "Main Menu",
	"settings_exit": "Exit Game",
	"settings_tutorial": "Show the Tutorial Again",
	"settings_tutorial_armed": "The tour will run again",

	# --- opening cutscene ---
	# eleven beats over five stills. the arc: what the bay was, the first thing
	# that did not belong, the delivery that followed, us going down to look, and
	# the three sheets that are the answer.
	"cutscene_advance": "Click or press Enter  \u00b7  Esc to skip",
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
	"day_quota": "Quota",
	"machines_title": "Cost per drop",
	"day_budget": "Shift time",
	"day_tools": "Tools",
	"day_tools_locked": "none yet",
	"day_begin": "Lower the Claw",

	# --- claw phase ---
	"budget_too_low": "Not enough shift time for that",
	"shift_end": "End Shift",
	# the shift only ends once the day's quota is sorted - right or wrong, they
	# find out which at the report
	"shift_end_locked": "Sort {n} more before the shift can end",
	"shift_end_locked_button": "Sort {n} more",
	"shift_to_desk": "To the Sorting Desk",
	"shift_to_claw": "To the Claw Machine",
	"shift_over": "Shift time is up",
	"shift_nothing_sorted": "Shift over, and not one thing sorted. Nothing reaches the workshop today.",
	"shift_sea_cleared": "Every last piece out of the water and into a bin. The seabed is clear.",
	"claw_rail_locked": "Rail is resetting - it can be moved again in a moment",
	"claw_drop_button": "DROP  ({n})",
	"claw_slipped": "Slipped! It fell back down.",

	# --- desk phase ---
	"desk_inventory": "Collected items",
	"desk_empty": "Everything has been sorted",
	"desk_no_selection": "Pick an item before choosing a bin",
	"desk_rulebook_button": "Rulebook (R)",
	"tools_locked": "No tools available today",
	"tools_armed": "{tool} ready - click the item",
	"evidence_title": "EVIDENCE LOG",
	"reveal_nothing": "Nothing on this one for that tool.",
	# --- the rinse. it changes the item instead of reading it ---
	"rinse_clean": "The stain washed straight off. It is clean now.  (shift time -{n})",
	"rinse_hazard": "It will not come off - that is not food. Whatever soaked in is still in there.  (shift time -{n})",
	"rinse_none": "Nothing came off. There was no stain on it to begin with.  (shift time -{n})",
	"rinse_already": "Already rinsed. There is nothing left on it.",
	"rinse_toast_clean": "Rinsed clean",
	"rinse_toast_hazard": "That stain is chemical - it does not rinse off",
	"inspect_found": "Found: {v}   (shift time -{n})",
	"inspect_coarse": "There is something, but it did not read clearly. Use the tool once more to read it. (shift time -{n})",
	"inspect_nothing": "Nothing on this one for that tool. The shift time is spent anyway -{n}.",
	"inspect_rules_title": "RULES IN FORCE TODAY",
	"tools_cost_label": "costs {n}",
	"tools_not_today": "not today",

	# --- evidence chips ---
	"chip_material": "LOOKS LIKE: {v}",
	"chip_label": "MARKING: {v}",
	"chip_weight": "WEIGHT: {v} kg",
	"chip_no_label": "no marking",
	"chip_stain": "STAIN: {v}",
	"chip_stain_type": "STAIN IS: {v}",
	"chip_stain_hazardous": "STAIN: {v}",
	"chip_true_material": "MADE OF: {v}",
	"chip_rinsed": "RINSED CLEAN",
	"field_stain_yes": "still on it",
	"field_stain_no": "clean",
	"field_stain_hazard": "chemical, will not wash off",
	"field_stain_washable": "washes off",
	"field_none": "none",
	"field_multilayer_suffix": " (the layers cannot be separated, so nothing is recovered)",

	# --- mystery box ---
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
	"bin_residue": "RESIDUE",

	# --- rulebook ---
	"rulebook_title": "RULEBOOK",
	"rulebook_where": "WHERE THINGS GO",
	"rulebook_where_note": "The baseline sorting guide. A special rule above always beats this - a recyclable with a stain still on it is not recyclable until the stain is off.",
	"rulebook_close": "Close",
	"rulebook_empty": "No special rules today",
	"rulebook_general": "GENERAL",

	# --- day report ---
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
	"report_perfect": "No mistakes. Nice work.",

	# --- after-day screen ---
	"after_title": "END OF DAY {n}",
	"after_tab_result": "The Day",
	"after_tab_tech": "Technology",
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
	# what a machine bolts onto the claw - it switches itself on when it is
	# built, so these are a promise and then a statement of fact
	"tech_unlocks": "Build it and it fits {v}:  {effect}",
	"tech_fitted": "{v} is running:  {effect}",
	"tech_part_todo": "Not built yet",
	"tech_part_done": "Fitted",
	"tech_progress": "{have} / {need}",
	"tech_material_source": "Materials come from the bins. Only items you put in the RIGHT bin are stored - a wrong bin loses the item.",
	"tech_rakit": "Build",
	"tech_rakit_done": "Fitted",
	"tech_close": "Close",

	# --- upgrades ---

	# --- endings ---
	# four tiers, one per machine built, matching the four ending paintings the
	# designer delivered (assets/ui/endings/, installed as env/ending_<tier>.png).
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

# the baseline sorting guide: which bin a material goes in and why. Fixed
# reference text, not per-item content - an item is still judged by its own
# .tres plus the day's rules, this only explains the reasoning so a new player
# isn't guessing.
#
# Every line has to name things the player will actually be handed. A guide
# that promises a bin for metal cans or for a tin of paint, when the game
# contains neither, teaches a rule that can only ever be wrong.
#
# [category, what it is, why it goes there]
const GUIDANCE: Array = [
	[ItemData.Category.ORGANIC, "Food waste",
		"fruit, peel, eggshell, leftovers. It rots down, so it belongs in ORGANIC."],
	[ItemData.Category.ORGANIC, "Garden waste",
		"leaves, twigs, cuttings. Natural matter, same bin as food."],
	[ItemData.Category.ORGANIC, "Natural fibre",
		"cotton, wool, jute - a cotton shirt is plant matter and rots down."],

	[ItemData.Category.RECYCLABLE, "Paper and card",
		"newspaper, plain card, a clean paper cup. Clean, and plain paper only - nothing bonded onto it."],
	[ItemData.Category.RECYCLABLE, "Glass",
		"bottles and jars. Glass is recyclable however many times it has been used."],
	[ItemData.Category.RECYCLABLE, "Clean plastic",
		"bags, bottles, tubs, handles. Clean means clean - rinse it or it is not recyclable."],
	[ItemData.Category.RECYCLABLE, "Polyester and synthetic fabric",
		"plastic woven into cloth, not a natural fibre, so it goes here and NOT in ORGANIC. Only the magnifier can tell it from cotton."],

	[ItemData.Category.HAZARD, "Chemical stains",
		"engine oil, solvent paint, pesticide, expired medicine. They do not rinse off, so whatever soaked them up is hazardous - whatever it is made of."],

	[ItemData.Category.RESIDUE, "Anything still stained",
		"a stain that has not been rinsed off cannot be composted or recycled. Rinse it and it goes back to being whatever it is made of - leave it and it lands here."],
	[ItemData.Category.RESIDUE, "Laminated packaging",
		"paper with a thin plastic or foil film bonded onto it, the way a takeaway cup is lined. The layers cannot be pulled apart, so no rinsing helps and nothing can be recovered."],
	[ItemData.Category.RESIDUE, "Things made of several materials",
		"a toothbrush with nylon bristles stapled into a plastic handle, a soft toy of fabric over polyester filling. The magnifier is what tells you - one word printed on the outside does not mean the whole object is that one material."],
	[ItemData.Category.RESIDUE, "Soiled tissue and the rest",
		"used tissue, and anything that is not organic, not clean enough to recycle and not chemical."],
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
		ItemData.Category.RESIDUE: return t("bin_residue")
	return "?"
