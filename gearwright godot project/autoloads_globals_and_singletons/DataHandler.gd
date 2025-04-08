extends Node

var item_grid_data := {} # FIXME make this unnecesary
var fish_item_grid_data := {} # FIXME make this unnecesary

var internal_content := {}
var external_content := {}

#region paths

const external_content_path = "user://external_content/"
#const update_path = "user://latest_update.pck"

#var item_data_path          = "user://LocalData/item_data.json"
#var fish_item_data_path     = "user://LocalData/npc_item_data.json"
#var update_data_path        = "user://latest_update.pck"
#const frame_data_path       = "user://LocalData/frame_data.json"
#const background_data_path  = "user://LocalData/fisher_backgrounds.json"
#const level_data_path       = "user://LocalData/level_data.json"
#const maneuver_data_path    = "user://LocalData/fisher_maneuvers.json"
#const development_data_path = "user://LocalData/fisher_developments.json"
#const deep_word_data_path = "user://LocalData/deep_words.json"
#const fish_size_data_path = "user://LocalData/fish_size_data.json"
#const fish_type_data_path = "user://LocalData/fish_template_data.json"
#const label_data_path    = "user://LocalData/labels.json"

# external content
var item_data_path          = "user://external_content/item_data.json"
var fish_item_data_path     = "user://external_content/npc_item_data.json"
#var update_data_path        = "user://latest_update.pck"
const frame_data_path       = "user://external_content/frame_data.json"
const background_data_path  = "user://external_content/fisher_backgrounds.json"
const level_data_path       = "user://external_content/level_data.json"
const maneuver_data_path    = "user://external_content/fisher_maneuvers.json"
const development_data_path = "user://external_content/fisher_developments.json"
const deep_word_data_path = "user://external_content/deep_words.json"
const fish_size_data_path = "user://external_content/fish_size_data.json"
const fish_type_data_path = "user://external_content/fish_template_data.json"
const label_data_path    = "user://external_content/labels.json"

const gear_item_icon_dir_path = "res://actor_builders/mech_builder/gear_internal_art/"
const fish_item_icon_dir_path = "res://actor_builders/fish_builder/fish_internal_art/" 

const save_paths := {
	"Gear": {
		"fsh": "user://Saves/Gears/Files/",
		"png": "user://Saves/Gears/Images/",
	},
	"Fish": {
		"fsh": "user://Saves/Fish/Files/",
		"png": "user://Saves/Fish/Images/",
	},
}

#endregion



#region templates
const label_template := {
	"name": "Label",
	"description": "I'm homestar and this is a website",
	"label_type": "equipment",
}

const gear_data_template := { # TODO yeet?
	"callsign": "",
	"frame": "",
	"internals": {},
	"background": "",
	"custom_background": [],
	"unlocks": [],
	"developments": [],
	"maneuvers": [],
	"deep_words": [],
	"level": "1"
}

var fish_data_template := { # TODO yeet?
	"name": "",
	"size": "",
	"internals": {},
	"template": "",
	"mutations": []
}

const frame_stats_template := {
	ap = 0,
	ballast = 0,
	close = 0,
	core_integrity = 1,
	default_unlocks = [],
	evasion = 0,
	far = 0,
	gear_ability = "Please select a Frame",
	gear_ability_name = "",
	power = 0,
	repair_kits = 1,
	sensors = 0,
	speed = 0,
	weight = 0,
	weight_cap = 0,
}

# from localData/fisher_backgrounds.json
const background_stats_template := {
	background = "None",
	marbles = 0,
	mental = 0,
	willpower = 0,
	deep_words = 0,
	weight_cap = 0,
	unlocks = 0,
	description = "Please select a background",
}

# from level_data.json
const level_stats_template := {
	unlocks = 0,
	maneuvers = 0,
	developments = 0,
	weight_cap = 0,
	shore_leave_stat = 0,
}

const maneuver_stats_template := {
	name = "",
	category = "",
	ap_cost = 0,
	action_text = "",
}

# developments sometimes have other keys for stats they affect
const development_stats_template := {
	name = "",
	description = "",
	repeatable = false,
}

const item_stats_template := {
	"action_data": {},
	"ap": 0,
	"ballast": 0,
	"close": 0,
	"core": 0,
	"evasion": 0,
	"far": 0,
	"grid": [
		"[0, 0]", # this does not spark joy
	],
	"mental": 0,
	"name": "",
	"power": 0,
	"repair_kits": 0,
	"extra_rules": "",
	"section": "any",
	"sensors": 0,
	"speed": 0,
	"tags": [],
	"type": "passive",
	"weight": 0,
	"weight_cap": 0,
	"willpower": 0,
}

const fish_internal_template := {
	"action_data": {
		"ap_cost": 0,
		"attribute": "",
		"range": 0,
		"damage": 0,
		"marble_damage": 0,
		"action_text": "idk my bff jill",
	},
	"ap": 0,
	"close": 0,
	"core": 0,
	"evasion": 0,
	"far": 0,
	"grid": [
	  "[0, 0]",
	],
	"mental": 0,
	"name": "default fish internal",
	"power": 0,
	"extra_rules": "",
	"sensors": 0,
	"speed": 0,
	"tags": [],
	"type": "passive",
	"ballast": 0,
	"weight": 1,
	"willpower": 0,
}

const deep_word_template := {
	"short_name": "deep word",
	"full_name": "deep word, yo",
	"fathomless": 1,
	"ap_cost": 0,
	"action_text": "Speak now or forever eat your peas.",
}

const fish_size_template := {
	"size": "none",
	"weight": 0,
	"ap": 0,
	"close": 1,
	"far": 1,
	"mental": 1,
	"evasion": 1,
	"willpower": 1,
	"speed": 1,
	"sensors": 1,
	"power": 1,
}

const fish_type_template := {
	"template": "none",
	"weight": 0,
	"mutations": 0,
	"mutation_cap": 0,
	"extra_rules": "",
}

#endregion

enum DATA_TYPE {
	BACKGROUND,
	FRAME,
	LEVEL,
	DEVELOPMENT,
	MANEUVER,
	INTERNAL,
	DEEP_WORD,
	FISH_INTERNAL,
	FISH_SIZE,
	FISH_TYPE,
	FISHER_LABEL,
}

func _ready():
	# make sure directories exist
	var dirs_to_check := [
		external_content_path,
	]
	for dict in save_paths.values():
		dirs_to_check.append_array(dict.values())
	for directory in dirs_to_check:
		if !DirAccess.dir_exists_absolute(directory):
			DirAccess.make_dir_recursive_absolute(directory) 
	
	load_all_data()

func load_all_data():
	internal_content[DATA_TYPE.BACKGROUND]    = load("res://autoloads_globals_and_singletons/data/fisher_backgrounds.json").data
	internal_content[DATA_TYPE.FRAME]         = load("res://autoloads_globals_and_singletons/data/frame_data.json").data
	internal_content[DATA_TYPE.LEVEL]         = load("res://autoloads_globals_and_singletons/data/level_data.json").data
	internal_content[DATA_TYPE.DEVELOPMENT]   = load("res://autoloads_globals_and_singletons/data/fisher_developments.json").data
	internal_content[DATA_TYPE.MANEUVER]      = load("res://autoloads_globals_and_singletons/data/fisher_maneuvers.json").data
	internal_content[DATA_TYPE.INTERNAL]      = load("res://autoloads_globals_and_singletons/data/item_data.json").data
	internal_content[DATA_TYPE.DEEP_WORD]     = load("res://autoloads_globals_and_singletons/data/deep_words.json").data
	#internal_content[DATA_TYPE.FISH_INTERNAL] = load("res://autoloads_globals_and_singletons/data/npc_item_data.json").data
	internal_content[DATA_TYPE.FISH_INTERNAL] = {}
	#internal_content[DATA_TYPE.FISH_SIZE]     = load("res://autoloads_globals_and_singletons/data/fish_size_data.json").data
	internal_content[DATA_TYPE.FISH_SIZE]     = {}
	#internal_content[DATA_TYPE.FISH_TYPE]     = load("res://autoloads_globals_and_singletons/data/fish_template_data.json").data
	internal_content[DATA_TYPE.FISH_TYPE]     = {}
	internal_content[DATA_TYPE.FISHER_LABEL]  = load("res://autoloads_globals_and_singletons/data/labels.json").data
	
	var external_dir_info := global_util.dir_contents(external_content_path)
	for dir in external_dir_info.dirs:
		global_util.fancy_print(external_content_path.path_join(dir))
		# WHEREWASI TODO FIXME
	
	# okay, external content
	#
	# prefer internal content first
	# if something isn't there, check the external data
	# also need a new abstraction layer for getting all data (e.g. for list of internals)
	#
	# how does loading multiple externals work
	#   probably merges their stuff with existing stuff (prefer new stuff)
	#   homebrew authors should just prevent collisions
	#   importing needs some thought, since all external 
	#
	# no more .pck files for the love of god
	# just an assets folder with images
	
	
	#ProjectSettings.load_resource_pack(update_data_path, true)
	
	#item_data        = load_data(item_data_path)
	#fish_item_data   = load_data(fish_item_data_path)
	#frame_data       = load_data(frame_data_path)
	#background_data  = load_data(background_data_path)
	#level_data       = load_data(level_data_path)
	#maneuver_data    = load_data(maneuver_data_path)
	#development_data = load_data(development_data_path)
	#deep_word_data   = load_data(deep_word_data_path)
	#fish_size_data   = load_data(fish_size_data_path)
	#fish_type_data   = load_data(fish_type_data_path)
	#label_data       = load_data(label_data_path)
	
	# set grid and icon data
	set_grid_and_icon_data(internal_content[DATA_TYPE.INTERNAL], gear_item_icon_dir_path)
	set_grid_and_icon_data(internal_content[DATA_TYPE.FISH_INTERNAL], fish_item_icon_dir_path)

func set_grid_and_icon_data(item_data: Dictionary, icon_dir_path: String):
	if item_data == null:
		return
	for item in item_data.keys():
		var temp_grid_array := []
		for point in item_data[item]["grid"]:
			temp_grid_array.push_back(point.split(","))
		item_grid_data[item] = temp_grid_array
		#item_data[item]["icon_path"] = "res://Assets/ItemSprites/" + item_data[item]["name"] + ".png"
		# "res://actor_builders/mech_builder/gear_internal_art/Actuators I.png"
		#fish_item_data[item]["icon_path"] = "res://Assets/FishItemSprites/" + fish_item_data[item]["name"] + ".png"
		# "res://actor_builders/fish_builder/fish_internal_art/Adrenal Engine +3.png"
		item_data[item]["icon_path"] = icon_dir_path + item_data[item]["name"] + ".png"

func is_gear_data_loaded():
	return not internal_content[DATA_TYPE.INTERNAL].is_empty()

func is_fish_data_loaded():
	return not internal_content[DATA_TYPE.FISH_INTERNAL].is_empty()

func load_data(path):
	var text := global_util.file_to_string(path)
	if text.is_empty():
		#push_warning("%s was empty, data import necessary!" % path)
		print("%s was empty, data import necessary!" % path)
		return {}
	return JSON.parse_string(text)

# pops up error messages if things go badly
func get_thing_nicely(data_type: DATA_TYPE, key):
	var default
	match data_type:
		DATA_TYPE.BACKGROUND:
			default = background_stats_template.duplicate(true)
		DATA_TYPE.FRAME:
			default = frame_stats_template.duplicate(true)
		DATA_TYPE.LEVEL:
			key = str(key) # might be an int
			default = level_stats_template.duplicate(true)
		DATA_TYPE.DEVELOPMENT:
			default = development_stats_template.duplicate(true)
		DATA_TYPE.MANEUVER:
			default = maneuver_stats_template.duplicate(true)
		DATA_TYPE.INTERNAL:
			default = item_stats_template.duplicate(true)
		DATA_TYPE.DEEP_WORD:
			default = deep_word_template.duplicate(true)
		DATA_TYPE.FISH_INTERNAL:
			default = fish_internal_template
		DATA_TYPE.FISH_SIZE:
			default = fish_size_template
		DATA_TYPE.FISH_TYPE:
			default = fish_type_template
		DATA_TYPE.FISHER_LABEL:
			default = label_template
		_:
			push_error("DataHandler: unknown data type: %s '%s'" % [data_type, DATA_TYPE.find_key(data_type)])
			breakpoint
	
	var internal_data: Dictionary = internal_content[data_type]
	var external_data: Dictionary = external_content.get(data_type, {})
	if internal_data.has(key):
		return internal_data[key]
	elif external_data.has(key):
		return external_data[key]
	else:
		var data_name = DATA_TYPE.find_key(data_type).capitalize()
		var title := "Bad %s" % data_name
		var message := "Failed to find %s data for '%s'\n(Have you imported the game data from the main menu?)" % [data_name, key]
		
		push_error("%s: %s" % [title, message])
		print("%s: %s" % [title, message])
		#global_util.popup_warning(title, message)
		return default

# merged internal and external data
func get_merged_data(data_type: DATA_TYPE) -> Dictionary:
	var data: Dictionary = internal_content[data_type]
	data.merge(external_content.get(data_type, {}), false)
	return data

func get_development_data(dev_name: String):
	return get_thing_nicely(DATA_TYPE.DEVELOPMENT, dev_name)

func is_development_name(dev_name: String) -> bool:
	var dev_data: Dictionary = get_merged_data(DATA_TYPE.DEVELOPMENT)
	for dev_id in dev_data.keys():
		var dev_info: Dictionary = dev_data[dev_id]
		if dev_info.name == dev_name:
			return true
	return false

func get_maneuver_data(man_name: String):
	return get_thing_nicely(DATA_TYPE.MANEUVER, man_name)

func get_deep_word_data(word: String):
	return get_thing_nicely(DATA_TYPE.DEEP_WORD, word)

func get_internal_data(internal_name: String):
	return get_thing_nicely(DATA_TYPE.INTERNAL, internal_name)

func get_fish_internal_data(internal_name: String):
	return get_thing_nicely(DATA_TYPE.FISH_INTERNAL, internal_name)

func get_fish_size_data(size_name: String):
	return get_thing_nicely(DATA_TYPE.FISH_SIZE, size_name)

func get_fish_type_data(type_name: String):
	return get_thing_nicely(DATA_TYPE.FISH_TYPE, type_name.to_snake_case())

func get_label_data(label_id: String):
	return get_thing_nicely(DATA_TYPE.FISHER_LABEL, label_id)

# returns a dictionary
# key: perk "id" (snake case name)
# value: perk pretty name
func get_perk_info(perk_type: PerkOptionButton.PERK_TYPE) -> Dictionary:
	var result := {}
	match perk_type:
		PerkOptionButton.PERK_TYPE.DEVELOPMENT:
			var dev_data := get_merged_data(DATA_TYPE.DEVELOPMENT)
			for key in dev_data.keys():
				result[key] = dev_data[key].name
		PerkOptionButton.PERK_TYPE.MANEUVER:
			var man_data := get_merged_data(DATA_TYPE.MANEUVER)
			for key in man_data.keys():
				var maneuver: Dictionary = man_data[key]
				var category: String = maneuver.category
				if not result.has(category):
					result[category] = []
				result[category].append({
					key: man_data[key].name,
				})
		PerkOptionButton.PERK_TYPE.DEEP_WORD:
			var deep_word_data := get_merged_data(DATA_TYPE.DEEP_WORD)
			for key in deep_word_data.keys():
				result[key] = deep_word_data[key].short_name
		_:
			push_error("DataHandler: bad perk type: %d" % perk_type)
	return result

# returns true on success, false on failure
func load_fsh_file(path: String) -> bool:
	var zipreader = ZIPReader.new()
	var _err = zipreader.open(path)
	var files_to_import = zipreader.get_files()
	global_util.fancy_print("loading fsh file...")
	global_util.indent()
	
	var fsh_name: String = path.split("/")[-1]
	fsh_name = fsh_name.replacen(".fsh", "")
	var external_content_fsh_dir := external_content_path.path_join(fsh_name)
	DirAccess.make_dir_recursive_absolute(external_content_fsh_dir)
	
	for file_name in files_to_import:
		global_util.fancy_print("looking at %s" % file_name)
		global_util.indent()
		file_name = file_name as String
		var split_path := file_name.split("/")
		var split_file_name := split_path[-1] # remove directory
		global_util.fancy_print("-> %s" % split_file_name)
		
		if file_name.ends_with(".pck"):
			global_util.fancy_print("pck file, ignoring")
			#var data = zipreader.read_file(file_name)
			#var dest_file := FileAccess.open(update_path, FileAccess.WRITE)
			#dest_file.store_buffer(data)
			#dest_file.close()
		elif file_name.ends_with(".json"):
			global_util.fancy_print("json file")
			var data = zipreader.read_file(file_name).get_string_from_utf8()
			var dest_file := FileAccess.open(external_content_fsh_dir.path_join(split_file_name), FileAccess.WRITE)
			if dest_file == null:
				global_util.popup_warning(error_string(FileAccess.get_open_error()), "Failed to open file for writing: %s" % file_name)
				return false
			dest_file.store_string(data)
			dest_file.close()
		else:
			global_util.fancy_print("ignoring")
			# TODO copy assets..?
		global_util.dedent()
	
	global_util.dedent()
	global_util.fancy_print("...finished loading fsh file")
	
	load_all_data()
	return true





