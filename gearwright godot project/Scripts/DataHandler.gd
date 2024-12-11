extends Node

var item_data = {}
var item_grid_data := {}

var fish_item_data = {}
var fish_item_grid_data := {}

var frame_data := {}
var background_data := {}
var level_data := {}
var maneuver_data := {}
var development_data := {}

var item_data_path          = "user://LocalData/item_data.json"
var fish_item_data_path     = "user://LocalData/npc_item_data.json"
var update_data_path        = "user://latest_update.pck"
const frame_data_path       = "user://LocalData/frame_data.json"
const background_data_path  = "user://LocalData/fisher_backgrounds.json"
const level_data_path       = "user://LocalData/level_data.json"
const maneuver_data_path    = "user://LocalData/fisher_maneuvers.json"
const development_data_path = "user://LocalData/fisher_developments.json"

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

# Called when the node enters the scene tree for the first time.
func _ready():
	item_data = load_data(item_data_path)
	fish_item_data = load_data(fish_item_data_path)
	frame_data = load_data(frame_data_path)
	background_data = load_data(background_data_path)
	level_data = load_data(level_data_path)
	maneuver_data = load_data(maneuver_data_path)
	development_data = load_data(development_data_path)
	
	set_grid_and_icon_data()

func load_data(path):
	ProjectSettings.load_resource_pack(update_data_path, true)
	if not FileAccess.file_exists(path):
		printerr("file not found")
		push_error("file not found: %s" % path)
	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	return data

func get_gear_template():
	return gear_data_template.duplicate(true)

func get_fish_template():
	return fish_data_template.duplicate(true)

# pops up error messages if things go badly
# TODO data_type should be an enum
func get_thing_nicely(data_type: String, key):
	var data
	var default
	match data_type:
		"background":
			data = background_data
			default = background_stats_template.duplicate(true)
		"frame":
			data = frame_data
			default = frame_stats_template.duplicate(true)
		"level":
			key = str(key) # might be an int
			data = level_data
			default = level_stats_template.duplicate(true)
		"development":
			data = development_data
			default = development_stats_template.duplicate(true)
		"maneuver":
			data = maneuver_data
			default = maneuver_stats_template.duplicate(true)
		"internal":
			data = item_data
			default = item_stats_template.duplicate(true)
		_:
			push_error("DataHandler: unknown data type: %s" % data_type)
			breakpoint
	
	if data.has(key):
		return data[key]
	else:
		var title := "Bad %s" % data_type.capitalize()
		var message := "Failed to find %s data for '%s'\n(Have you imported the game data from the main menu?)" % [data_type, key]
		global_util.popup_warning(title, message)
		return default

func get_development_data(dev_name: String):
	return get_thing_nicely("development", dev_name)






func set_grid_and_icon_data():
	if item_data:
		for item in item_data.keys():
			var temp_grid_array := []
			for point in item_data[item]["grid"]:
				temp_grid_array.push_back(point.split(","))
			item_grid_data[item] = temp_grid_array
			item_data[item]["icon_path"] = "res://Assets/ItemSprites/" + item_data[item]["name"] + ".png"
	
	if fish_item_data:
		pass
		# TODO make sure this works
		#for item in fish_item_data.keys():
			#var temp_grid_array := []
			#for point in fish_item_data[item]["grid"]:
				#temp_grid_array.push_back(point.split(","))
			#fish_item_grid_data[item] = temp_grid_array
			#fish_item_data[item]["icon_path"] = "res://Assets/FishItemSprites/" + fish_item_data[item]["name"] + ".png"

func reload_items():
	item_data = load_data(item_data_path)
	fish_item_data = load_data(fish_item_data_path)
	
	set_grid_and_icon_data()
