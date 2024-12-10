extends VBoxContainer

# TODO

var development_file_path = "user://LocalData/fisher_developments.json"

signal development_added(development_data)
signal development_removed(development_data)

@onready var development_container_scene = preload("res://Scenes/development_menu_item.tscn")

@onready var placeholder = $DevelopmentPlaceholder

var development_data := {}
var development_containers := []
var current_developments := []

func _ready():
	var file = FileAccess.open(development_file_path, FileAccess.READ)
	development_data = JSON.parse_string(file.get_as_text())
	file.close()

func add_development_container():
	var temp_container = development_container_scene.instantiate()
	temp_container.development_data = development_data.duplicate(true)
	temp_container.development_added.connect(add_development)
	temp_container.development_removed.connect(remove_development)
	development_containers.append(temp_container)
	add_child(temp_container)
	for development in current_developments:
		if development_data[development]["repeatable"]:
			continue
		temp_container.option_button.set_item_disabled(development_data.keys().find(development), true)

func remove_development_container():
	if development_containers.back().current_development:
		remove_development(development_containers.back().current_development)
	development_containers.back().queue_free()
	development_containers.erase(development_containers.back())

#func _on_level_selector_change_level(level_data, _level):
func _on_level_selector_change_level(new_level: int):
	var level_data: Dictionary = DataHandler.get_thing_nicely("level", new_level)
	var difference = level_data["developments"] - development_containers.size()
	if difference == 0:
		return
	if difference > 0:
		for i in range(difference):
			add_development_container()
	else:
		for i in range(difference * -1):
			remove_development_container()
	
	if development_containers.size() == 0:
		placeholder.show()
	else:
		placeholder.hide()

func add_development(development):
	current_developments.append(development)
	if development_data[development]["repeatable"]:
		pass
	else:
		for container in development_containers:
			container.option_button.set_item_disabled(development_data.keys().find(development), true)
	development_added.emit(development_data[development])

func remove_development(development):
	current_developments.erase(development)
	for container in development_containers:
		container.option_button.set_item_disabled(development_data.keys().find(development), false)
	development_removed.emit(development_data[development])
