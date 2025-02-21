extends Node

var item_data = {}
var item_grid_data := {} # FIXME make this unnecesary

var fish_item_data = {}
var fish_item_grid_data := {} # FIXME make this unnecesary

var frame_data := {}
var background_data := {}
var level_data := {}
var maneuver_data := {}
var development_data := {}
var deep_word_data := {}
var fish_size_data := {}
var fish_type_data := {}

var item_data_path          = "user://LocalData/item_data.json"
var fish_item_data_path     = "user://LocalData/npc_item_data.json"
var update_data_path        = "user://latest_update.pck"
const frame_data_path       = "user://LocalData/frame_data.json"
const background_data_path  = "user://LocalData/fisher_backgrounds.json"
const level_data_path       = "user://LocalData/level_data.json"
const maneuver_data_path    = "user://LocalData/fisher_maneuvers.json"
const development_data_path = "user://LocalData/fisher_developments.json"
const deep_word_data_path = "user://LocalData/deep_words.json"
const fish_size_data_path = "user://LocalData/fish_size_data.json"
const fish_type_data_path = "user://LocalData/fish_template_data.json"

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
}

func _ready():
	load_all_data()

func load_all_data():
	item_data        = load_data(item_data_path)
	fish_item_data   = load_data(fish_item_data_path)
	frame_data       = load_data(frame_data_path)
	background_data  = load_data(background_data_path)
	level_data       = load_data(level_data_path)
	maneuver_data    = load_data(maneuver_data_path)
	development_data = load_data(development_data_path)
	deep_word_data   = load_data(deep_word_data_path)
	fish_size_data   = load_data(fish_size_data_path)
	fish_type_data   = load_data(fish_type_data_path)
	
	set_grid_and_icon_data()

func is_data_loaded():
	return not item_data.is_empty()

func load_data(path):
	ProjectSettings.load_resource_pack(update_data_path, true)
	if not FileAccess.file_exists(path):
		printerr("file not found")
		push_error("file not found: %s" % path)
	var file = FileAccess.open(path, FileAccess.READ)
	var text := file.get_as_text()
	file.close()
	if text.is_empty():
		push_warning("%s was empty, data import necessary!" % path)
		return {}
	return JSON.parse_string(text)

func get_gear_template():
	return gear_data_template.duplicate(true)

func get_fish_template(): # TODO yeet?
	return fish_data_template.duplicate(true)

# pops up error messages if things go badly
func get_thing_nicely(data_type: DATA_TYPE, key):
	var data
	var default
	match data_type:
		DATA_TYPE.BACKGROUND:
			data = background_data
			default = background_stats_template.duplicate(true)
		DATA_TYPE.FRAME:
			data = frame_data
			default = frame_stats_template.duplicate(true)
		DATA_TYPE.LEVEL:
			key = str(key) # might be an int
			data = level_data
			default = level_stats_template.duplicate(true)
		DATA_TYPE.DEVELOPMENT:
			data = development_data
			default = development_stats_template.duplicate(true)
		DATA_TYPE.MANEUVER:
			data = maneuver_data
			default = maneuver_stats_template.duplicate(true)
		DATA_TYPE.INTERNAL:
			data = item_data
			default = item_stats_template.duplicate(true)
		DATA_TYPE.DEEP_WORD:
			data = deep_word_data
			default = deep_word_template.duplicate(true)
		DATA_TYPE.FISH_INTERNAL:
			data = fish_item_data
			default = fish_internal_template
		DATA_TYPE.FISH_SIZE:
			data = fish_size_data
			default = fish_size_template
		DATA_TYPE.FISH_TYPE:
			data = fish_type_data
			default = fish_type_template
		_:
			push_error("DataHandler: unknown data type: %s '%s'" % [data_type, DATA_TYPE.find_key(data_type)])
			breakpoint
	
	if data.has(key):
		return data[key]
	else:
		var data_name = DATA_TYPE.find_key(data_type).capitalize()
		var title := "Bad %s" % data_name
		var message := "Failed to find %s data for '%s'\n(Have you imported the game data from the main menu?)" % [data_name, key]
		
		push_error("%s: %s" % [title, message])
		print("%s: %s" % [title, message])
		global_util.popup_warning(title, message)
		return default

func get_development_data(dev_name: String):
	return get_thing_nicely(DATA_TYPE.DEVELOPMENT, dev_name)

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



func set_grid_and_icon_data():
	if item_data:
		for item in item_data.keys():
			var temp_grid_array := []
			for point in item_data[item]["grid"]:
				temp_grid_array.push_back(point.split(","))
			item_grid_data[item] = temp_grid_array
			item_data[item]["icon_path"] = "res://Assets/ItemSprites/" + item_data[item]["name"] + ".png"
	
	if fish_item_data:
		for item in fish_item_data.keys():
			var temp_grid_array := []
			for point in fish_item_data[item]["grid"]:
				temp_grid_array.push_back(point.split(","))
			fish_item_grid_data[item] = temp_grid_array
			fish_item_data[item]["icon_path"] = "res://Assets/FishItemSprites/" + fish_item_data[item]["name"] + ".png"


func get_perk_info(perk_type: PerkOptionButton.PERK_TYPE) -> Dictionary:
	var result := {}
	match perk_type:
		PerkOptionButton.PERK_TYPE.DEVELOPMENT:
			for key in development_data.keys():
				result[key] = development_data[key].name
		PerkOptionButton.PERK_TYPE.MANEUVER:
			for key in maneuver_data.keys():
				var maneuver: Dictionary = maneuver_data[key]
				var category: String = maneuver.category
				if not result.has(category):
					result[category] = []
				result[category].append({
					key: maneuver_data[key].name,
				})
		PerkOptionButton.PERK_TYPE.DEEP_WORD:
			for key in deep_word_data.keys():
				result[key] = deep_word_data[key].short_name
		_:
			push_error("DataHandler: bad perk type: %d" % perk_type)
	return result







