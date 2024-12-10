extends OptionButton

# TODO yeet comments
#var save_path = "user://LocalData/frame_data.json"
#
#var frame_data = {}
#signal load_frame(frame_data, frame_name)
signal load_frame(frame_name)

# Called when the node enters the scene tree for the first time.
func _ready():
	#if not FileAccess.file_exists(save_path):
		#printerr("file not found")
		#return
	#var file = FileAccess.open(save_path, FileAccess.READ)
	#var temp_data = JSON.parse_string(file.get_as_text())
	#if temp_data:
		#frame_data = temp_data
	#else: 
		#return
	#file.close()
	#
	for frame in DataHandler.frame_data.keys():
		add_item(frame.capitalize())
	
	if 0 < item_count:
		_on_item_selected.call_deferred(0)
	else:
		push_warning("no frames?")
	#	#load_frame.emit.call_deferred(frame_data[frame_data.keys()[0]], frame_data.keys()[0])

func _on_item_selected(index):
	var frame_name = get_item_text(index).to_snake_case()
	#load_frame.emit(frame_data[frame_name], frame_name)
	load_frame.emit(frame_name)

#func _on_mech_builder_new_save_loaded(a_User_data):
	#select(frame_data.keys().find(a_User_data["frame"]))
	#load_frame.emit(frame_data[a_User_data["frame"]], a_User_data["frame"])
