extends Node

@onready var data_dir = "res://Data"

var dirs_to_check := ["LocalData", "Saves", "Screenshots"]

func _ready():
	for directory in dirs_to_check:
		directory = "user://".path_join(directory)
		if !DirAccess.dir_exists_absolute(directory):
			DirAccess.make_dir_recursive_absolute(directory)
	
	# I don't know why this exists
	var dir = DirAccess.open(data_dir)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not FileAccess.file_exists("user://LocalData".path_join(file_name)):
			var file = FileAccess.open("user://LocalData".path_join(file_name), FileAccess.WRITE)
			var data = FileAccess.open(data_dir.path_join(file_name), FileAccess.READ).get_as_text()
			file.store_string(data)
			file.close()
		file_name = dir.get_next()
