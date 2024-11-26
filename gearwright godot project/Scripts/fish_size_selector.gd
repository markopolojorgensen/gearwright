extends OptionButton

var small_fish_container = preload("res://Scenes/Fish Container Scenes/small_fish_container.tscn")
var medium_fish_container = preload("res://Scenes/Fish Container Scenes/medium_fish_container.tscn")
var large_fish_container = preload("res://Scenes/Fish Container Scenes/large_fish_container.tscn")
var massive_fish_container = preload("res://Scenes/Fish Container Scenes/massive_fish_container.tscn")
var leviathan_fish_container = preload("res://Scenes/Fish Container Scenes/leviathan_fish_container.tscn")
var serpent_leviathan_fish_container = preload("res://Scenes/Fish Container Scenes/serpent_leviathan_fish_container.tscn")
var siltstalker_fish_container = preload("res://Scenes/Fish Container Scenes/siltstalker_fish_container.tscn")

var fish_container_scenes := {
	"small_fish_container.tscn": small_fish_container,
	"medium_fish_container.tscn": medium_fish_container,
	"large_fish_container.tscn": large_fish_container,
	"massive_fish_container.tscn": massive_fish_container,
	"leviathan_fish_container.tscn": leviathan_fish_container,
	"serpent_leviathan_fish_container.tscn": serpent_leviathan_fish_container,
	"siltstalker_fish_container.tscn": siltstalker_fish_container
}

var fish_size_data_path = "user://LocalData/fish_size_data.json"
var fish_size_data := {}

signal load_fish_container(fish_container, size_data)

# Called when the node enters the scene tree for the first time.

func _ready():
	#var dir = DirAccess.open(fish_container_scene_path)
	#dir.list_dir_begin()
	#var file_name = dir.get_next()
	#while file_name != "":
	#	fish_container_scenes[file_name] = (load(fish_container_scene_path.path_join(file_name)))
	#	file_name = dir.get_next()
	
	if not FileAccess.file_exists(fish_size_data_path):
		printerr("file not found")
		return
	var file = FileAccess.open(fish_size_data_path, FileAccess.READ)
	var temp_data = JSON.parse_string(file.get_as_text())
	if temp_data:
		fish_size_data = temp_data
	else: 
		return
	file.close()
	
	for fish_size in fish_size_data:
		add_item(fish_size.capitalize())
	
	var container = fish_container_scenes[fish_container_scenes.keys()[fish_container_scenes.keys().find(fish_size_data.keys()[0] + "_fish_container.tscn")]]
	emit_signal.call_deferred("load_fish_container", container, fish_size_data[fish_size_data.keys()[0]])

func _on_item_selected(index):
	var container = fish_container_scenes[fish_container_scenes.keys()[fish_container_scenes.keys().find(fish_size_data.keys()[index] + "_fish_container.tscn")]]
	emit_signal.call_deferred("load_fish_container", container, fish_size_data[fish_size_data.keys()[index]])

func _on_fish_builder_new_save_loaded(a_Fish_data):
	select(fish_size_data.keys().find(a_Fish_data["size"]))
	var container = fish_container_scenes[fish_container_scenes.keys()[fish_container_scenes.keys().find(fish_size_data.keys()[fish_size_data.keys().find(a_Fish_data["size"])] + "_fish_container.tscn")]]
	emit_signal("load_fish_container", container, fish_size_data[a_Fish_data["size"]])
