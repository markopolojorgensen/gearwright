extends PanelContainer

@export_enum("Fish", "Gear") var save_type := "Gear"

signal file_selected(path)

func _ready() -> void:
	%Label.text = "Known %s Saves" % save_type
	
	var path: String = DataHandler.save_paths[save_type]["fsh"]
	
	var dir_info: Dictionary = global_util.dir_contents(path)
	# file does not include path
	for file in dir_info.files:
		file = file as String
		var button := Button.new()
		button.text = file.replace(".fsh", "").left(25)
		button.custom_minimum_size.y = 28
		%ButtonList.add_child(button)
		button.pressed.connect(func():
			file_selected.emit(path + file)
			)
	
	#if dir_info.files.is_empty():
		#hide()

