extends OptionButton

# TODO yeet comments
#var save_path = "user://LocalData/fisher_backgrounds.json"

#var background_data := {}
#signal load_background(background_data)
signal load_background(background_name)

# Called when the node enters the scene tree for the first time.
func _ready():
	#if not FileAccess.file_exists(save_path):
		#printerr("file not found")
		#return
	#var file = FileAccess.open(save_path, FileAccess.READ)
	#var temp_data = JSON.parse_string(file.get_as_text())
	#if temp_data:
		#background_data = temp_data
	#else: 
		#return
	#file.close()
	#
	#for background in background_data:
	for background in DataHandler.background_data.keys():
		var bg = DataHandler.background_data[background]
		add_item(bg["background"])
	
	if 0 < item_count:
		_on_item_selected.call_deferred(0)
	else:
		push_warning("no backgrounds?")
	#emit_signal.call_deferred("load_background", background_data[background_data.keys()[0]])

func _on_item_selected(index):
	var background_name = get_item_text(index).to_snake_case()
	load_background.emit(background_name)
	#load_background.emit(background_data[background_name])

#func _on_mech_builder_new_save_loaded(a_User_data):
	#select(background_data.keys().find(a_User_data["background"]))
	#load_background.emit(background_data[a_User_data["background"]])
