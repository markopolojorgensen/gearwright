extends VBoxContainer

# TODO yeet

@warning_ignore("unused_signal")
signal development_added(development_data)
@warning_ignore("unused_signal")
signal development_removed(development_data)

#@onready var development_container_scene = preload("res://Scenes/development_menu_item.tscn")
#
#@onready var placeholder = $DevelopmentPlaceholder
#
#var development_data := {}
#var development_containers := []
#var current_developments := []

func _ready():
	pass
	#development_data = DataHandler.development_data.duplicate(true)

func add_development_container():
	pass
	#var temp_container = development_container_scene.instantiate()
	#temp_container.development_data = development_data.duplicate(true)
	#temp_container.development_added.connect(add_development)
	#temp_container.development_removed.connect(remove_development)
	#development_containers.append(temp_container)
	#add_child(temp_container)
	#for development in current_developments:
		#if development_data[development]["repeatable"]:
			#continue
		#temp_container.option_button.set_item_disabled(development_data.keys().find(development), true)

func remove_development_container():
	pass
	#if development_containers.back().current_development:
		#remove_development(development_containers.back().current_development)
	#development_containers.back().queue_free()
	#development_containers.erase(development_containers.back())

#func _on_level_selector_change_level(level_data, _level):
func _on_level_selector_change_level(_new_level: int):
	pass
	#var level_data: Dictionary = DataHandler.get_thing_nicely("level", new_level)
	#var difference = level_data["developments"] - development_containers.size()
	#if difference == 0:
		#return
	#if difference > 0:
		#for i in range(difference):
			#add_development_container()
	#else:
		#for i in range(difference * -1):
			#remove_development_container()
	#
	#if development_containers.size() == 0:
		#placeholder.show()
	#else:
		#placeholder.hide()

func add_development(_development):
	pass
	#current_developments.append(development)
	#if development_data[development]["repeatable"]:
		#pass
	#else:
		#for container in development_containers:
			#container.option_button.set_item_disabled(development_data.keys().find(development), true)
	#development_added.emit(development_data[development])

func remove_development(_development):
	pass
	#current_developments.erase(development)
	#for container in development_containers:
		#container.option_button.set_item_disabled(development_data.keys().find(development), false)
	#development_removed.emit(development_data[development])
