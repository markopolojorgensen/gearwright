extends Label

# TODO yeet this script

var current_background = ""
var current_frame = ""
var current_level = "1"

func update_label():
	text = "EL %s | %s | %s" % [current_level, current_background, current_frame]

func _on_level_selector_change_level(level: int):
	current_level = str(level)
	update_label()

func _on_background_selector_load_background(background_name: String):
	current_background = background_name
	update_label()

#func _on_frame_selector_load_frame(_frame_data, frame_name):
func _on_frame_selector_load_frame(frame_name: String):
	current_frame = frame_name.capitalize()
	update_label()
