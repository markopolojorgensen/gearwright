extends Control

@onready var file_dialog := $FileDialog

func _ready() -> void:
	# coming back from some other scene, yeet all history
	input_context_system.clear()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()

func _on_gear_known_saves_list_widget_file_selected(path: Variant) -> void:
	if DataHandler.is_data_loaded():
		global.path_to_shortcutted_file = path
	_on_gear_builder_button_pressed()

func _on_fish_known_saves_list_widget_file_selected(path: Variant) -> void:
	if DataHandler.is_data_loaded():
		global.path_to_shortcutted_file = path
	_on_fish_builder_button_pressed()

func _on_data_import_button_button_down() -> void:
	file_dialog.current_path = "user://"
	file_dialog.popup()

func _on_gear_builder_button_pressed() -> void:
	if DataHandler.is_data_loaded():
		get_tree().change_scene_to_file("res://actor_builders/mech_builder/mech_builder.tscn")
	else:
		global_util.popup_warning("No Data Found!", "Please import data before using the program.")

func _on_fish_builder_button_pressed() -> void:
	if DataHandler.is_data_loaded():
		get_tree().change_scene_to_file("res://actor_builders/fish_builder/fish_builder.tscn")
	else:
		global_util.popup_warning("No Data Found!", "Please import data before using the program.")






