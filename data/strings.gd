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
	"tut_desk_tools_body": "Each one answers a different question. The MAGNIFIER reads the code stamped on a thing. The SWAB says whether a stain is chemical or just food. The RINSE actually washes a stain off. The CUTTER opens sealed crates. Every use costs shift time, so reach for the one that answers the question you actually have.",
	"tut_desk_outcome_title": "WHAT THE TOOLS TELL YOU",
	"tut_desk_outcome_body": "Every answer lands here as a chip and stays there. \"MARKING: HDPE 2\" is the label printed on the thing, free with every item - the guidebook says what each one means. \"STAIN IS: chemical\" means the swab found something that will not wash off - that item is hazardous whatever it is made of. \"RINSED CLEAN\" means the rinse worked and the thing is now clean enough to recycle. A tool that finds nothing still costs you, and that is an answer too.",
	"tut_desk_rules_title": "TODAY'S RULES",
	"tut_desk_rules_body": "The rules in force right now. A special rule always beats the plain \"what is it made of\" answer - a recyclable with a stain still on it is not recyclable until the stain is off.",
	"tut_desk_rulebook_title": "THE GUIDEBOOK",
	"tut_desk_rulebook_body": "Press this, or R, for the whole book: every rule in force today, which bin each kind of thing belongs in, and what every label and material printed on an item means. It costs nothing and you can open it as often as you want.",
	"tut_desk_bins_title": "THE FOUR BINS",
	"tut_desk_bins_body": "ORGANIC for what rots - food, garden waste, cotton and wool. RECYCLABLE for clean paper, glass, metal and clean plastic. HAZARDOUS for chemicals, and for anything a chemical soaked into. RESIDUE for the rest: still-stained things, laminated packaging, used tissue, and anything made of several materials that cannot be pulled apart.",
	"tut_desk_commit_title": "SORTING IS FINAL",
	"tut_desk_commit_body": "Click a bin and the item is gone. The right bin stores its material for the workshop; the wrong bin loses it for good. The desk will not say which - the end of the day will.",
	"tut_desk_blueprints_title": "WHAT IT IS ALL FOR",
	"tut_desk_blueprints_body": "Material from the right bins builds three machines. That is the run: sort well enough, for long enough, to get all three of them into the water.",
	"tut_desk_end_title": "THAT IS EVERYTHING",
	"tut_desk_end_body": "Look before you decide, and open the guidebook whenever you are not sure. Good luck out there.",

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
	"field_multilayer_suffix": " (laminated - the layers cannot be separated)",

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
	"rulebook_codes": "WHAT THE LABELS AND MATERIALS MEAN",
	"rulebook_codes_note": "The printed label is free, on the item card. The material under it is what the magnifier comes back with. Either one tells you what the thing is made of - never whether it is clean.",
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

# the baseline sorting guide, in the same shape as MATERIALS: which bin a material
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
		"marked HDPE 2 or PP 5. Clean means clean - rinse it or it is not recyclable."],
	[ItemData.Category.RECYCLABLE, "Polyester and synthetic fabric",
		"plastic woven into cloth, not a natural fibre, so it goes here and NOT in ORGANIC. Only the magnifier can tell it from cotton."],
	[ItemData.Category.RECYCLABLE, "Metal",
		"aluminium and steel cans. Valuable and recycled over and over."],

	[ItemData.Category.HAZARD, "Chemical stains",
		"engine oil, solvent paint, pesticide, expired medicine. They do not rinse off, so whatever soaked them up is hazardous - whatever it is made of."],
	[ItemData.Category.HAZARD, "Chemicals themselves",
		"paint, solvent, pesticide, batteries, expired medicine. Hazardous in their own right, and they poison the bay if they go in any other bin."],

	[ItemData.Category.RESIDUE, "Anything still stained",
		"a stain that has not been rinsed off cannot be composted or recycled. Rinse it and it goes back to being whatever it is made of - leave it and it lands here."],
	[ItemData.Category.RESIDUE, "Laminated packaging",
		"paper bonded to plastic or foil, e.g. PAP 22 - PE liner. The layers cannot be separated, so no rinsing helps and nothing can be recovered."],
	[ItemData.Category.RESIDUE, "Things made of several materials",
		"a toothbrush with nylon bristles stapled into a PP handle, a soft toy of fabric over polyester filling. The magnifier is what tells you - a single code on the outside does not mean the whole object is that one material."],
	[ItemData.Category.RESIDUE, "Soiled tissue and the rest",
		"used tissue, and anything that is not organic, not clean enough to recycle and not chemical."],
]


# What the player can actually read off an item - the label printed on it, or
# the material the magnifier names - and what that means for the bin. Fixed
# reference text, not per-item content, so it stays here instead of becoming
# 14 more .tres files.
#
# Only entries something in the game can actually show. This was a table of
# resin codes off real packaging, most of which no item ever carries: a page of
# PET, PVC, PA and Pb that never came up, while the two objects people got
# stuck on - the soft toy and the plastic bag - had nothing written about them
# at all. A code that appears on nothing teaches nothing. If an item starts
# carrying one, it gets a line here.
const MATERIALS: Array = [
	["PAPER  /  PAP 21", "plain paper and card with nothing bonded to it. Clean and unlined, so it is recyclable."],
	["PAP 22 - PE liner", "paper with a thin plastic film bonded onto it, the way a takeaway cup is lined. The layers cannot be pulled apart, so no amount of rinsing helps and nothing can be recovered."],
	["HDPE 2", "thick plastic - carrier bags, jerrycans, soap bottles. Recyclable once it is actually clean, which for a bag means the smears inside it too."],
	["PP 5", "stiff plastic for caps, tubs and handles. Recyclable on its own, but it is usually moulded or stapled onto something that is not."],
	["PS 6", "styrofoam. Almost never accepted for recycling."],
	["GL 70  /  GL 71", "glass. Recyclable however many times it has already been used."],
	["Cotton, natural fibre", "plant matter woven into cloth. It rots down, so a cotton shirt is organic waste."],
	["Polyester", "plastic drawn into thread and woven into cloth. It is recyclable and it is NOT organic, however much it looks and feels like the cotton shirt beside it. Nothing on the surface separates the two - that is what the magnifier is for."],
	["Fabric over filling", "a soft toy: cloth, stuffing and thread that cannot be pulled back apart into any one material. Nothing can be recovered from it, so it is residue."],
	["Handle with bristles", "a brush is a plastic handle with nylon bristles stapled into it. Several materials in one object, and the day the laminate rule is in force that puts it in residue."],
	["Chemical stain", "solvent paint, pesticide, engine oil, expired medicine. It never rinses off, and whatever soaked it up is hazardous waste - whatever that thing is made of."],
	["Food residue", "grease, sauce, coffee, ketchup, river mud. An ordinary stain: rinse it off and the item goes back to being whatever it is made of. Leave it on and it is residue."],
	["No label at all", "nothing is printed on it, so nothing is promised. An unlabelled object with more than one material in it - a soft toy, a brush - is the magnifier's job."],
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
