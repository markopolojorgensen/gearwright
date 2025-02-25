extends Button

func _on_button_down():
	if DataHandler.is_data_loaded():
		get_tree().change_scene_to_file("res://actor_builders/fish_builder/fish_builder.tscn")
	else:
		global_util.popup_warning("No Data Found!", "Please import data before using the program.")




