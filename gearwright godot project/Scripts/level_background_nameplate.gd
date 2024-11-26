extends Label

var current_background = ""
var current_frame = ""
var current_level = "1"

func update_label():
	text = "EL %s | %s | %s" % [current_level, current_background, current_frame]

func _on_level_selector_change_level(_level_data, level):
	current_level = level
	update_label()

func _on_background_selector_load_background(background_data):
	current_background = background_data["background"]
	update_label()

func _on_frame_selector_load_frame(_frame_data, frame_name):
	current_frame = frame_name.capitalize()
	update_label()
