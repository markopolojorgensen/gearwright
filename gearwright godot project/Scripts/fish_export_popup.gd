extends Popup

# TODO do we yeet this or not?

@onready var filename_input #= $VBoxContainer/HBoxContainer/LineEdit
@onready var fish_builder = $"../../.."

func _on_button_button_down():
	var filename = "user://Saves/" + filename_input.text + ".fsh"
	var file = FileAccess.open(filename, FileAccess.WRITE)
	
	file.store_string(fish_builder.get_fish_data_string())
	file.close()
	
	var folder_path
	if OS.has_feature("editor"):
		folder_path = ProjectSettings.globalize_path("user://Saves")
	else:
		folder_path = OS.get_user_data_dir()
	OS.shell_show_in_file_manager(folder_path, true)

