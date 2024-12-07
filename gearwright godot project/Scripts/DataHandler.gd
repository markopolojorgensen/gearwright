extends Node

var item_data = {}
var item_grid_data := {}

var fish_item_data = {}
var fish_item_grid_data := {}

var item_data_path = "user://LocalData/item_data.json"
var fish_item_data_path = "user://LocalData/npc_item_data.json"
var update_data_path = "user://latest_update.pck"

const gear_data_template := {
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

var fish_data_template := {
	"name": "",
	"size": "",
	"internals": {},
	"template": "",
	"mutations": []
}

# Called when the node enters the scene tree for the first time.
func _ready():
	item_data = load_data(item_data_path)
	fish_item_data = load_data(fish_item_data_path)
	
	set_grid_and_icon_data()

func load_data(a_path):
	ProjectSettings.load_resource_pack(update_data_path, true)
	if not FileAccess.file_exists(a_path):
		printerr("file not found")
	var file = FileAccess.open(a_path, FileAccess.READ)
	var temp_data = JSON.parse_string(file.get_as_text())
	file.close()
	return temp_data

func get_gear_template():
	return gear_data_template.duplicate(true)

func get_fish_template():
	return fish_data_template.duplicate(true)

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
