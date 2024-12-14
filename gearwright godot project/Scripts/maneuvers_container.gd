extends VBoxContainer

# TODO

var maneuver_file_path = "user://LocalData/fisher_maneuvers.json"

signal maneuver_added(maneuver_data)
signal maneuver_removed(maneuver_data)

@onready var maneuver_container_scene = preload("res://Scenes/maneuver_menu_item.tscn")

@onready var placeholder = $ManeuverPlaceholder

var maneuvers_from_level = 0
var maneuver_data := {}
var maneuver_containers := []
var current_maneuvers := []
var bonus_mental_maneuvers = 0

func _ready():
	maneuver_data = DataHandler.maneuver_data.duplicate(true)

func add_maneuver_container():
	var temp_container = maneuver_container_scene.instantiate()
	temp_container.maneuver_data = maneuver_data.duplicate(true)
	temp_container.maneuver_added.connect(add_maneuver)
	temp_container.maneuver_removed.connect(remove_maneuver)
	maneuver_containers.append(temp_container)
	add_child(temp_container)
	for maneuver in current_maneuvers:
		temp_container.option_button.set_item_disabled(temp_container.locations_in_menu.find(maneuver), true)

func remove_maneuver_container():
	if maneuver_containers.back().current_maneuver:
		remove_maneuver(maneuver_containers.back().current_maneuver)
	maneuver_containers.back().queue_free()
	maneuver_containers.erase(maneuver_containers.back())

#func _on_level_selector_change_level(level_data, _level):
func _on_level_selector_change_level(_level: int):
	pass
	# TODO
	#maneuvers_from_level = level_data["maneuvers"]
	#adjust_maneuver_amount()

func add_maneuver(maneuver):
	current_maneuvers.append(maneuver)
	for container in maneuver_containers:
		container.option_button.set_item_disabled(container.locations_in_menu.find(maneuver), true)
	maneuver_added.emit(maneuver_data[maneuver])

func remove_maneuver(maneuver):
	current_maneuvers.erase(maneuver)
	for container in maneuver_containers:
		container.option_button.set_item_disabled(container.locations_in_menu.find(maneuver), false)
	maneuver_removed.emit(maneuver_data[maneuver])

func _on_stats_list_update_mental_maneuvers(value):
	bonus_mental_maneuvers = value
	adjust_maneuver_amount()

func adjust_maneuver_amount():
	var difference = maneuvers_from_level + bonus_mental_maneuvers - maneuver_containers.size()
	if difference == 0:
		return
	if difference > 0:
		for i in range(difference):
			add_maneuver_container()
	else:
		for i in range(difference * -1):
			remove_maneuver_container()
	
	if maneuver_containers.size() == 0:
		placeholder.show()
	else:
		placeholder.hide()
