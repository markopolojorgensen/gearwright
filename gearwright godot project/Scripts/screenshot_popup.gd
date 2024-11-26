extends Popup

@onready var filename_input = $VBoxContainer/HBoxContainer/LineEdit
@onready var callsign_input = $"../../../ColorRect/MarginContainer/ColorRect2/CallsignInputContainer/CallsignInput"

signal screenshot_name_confirm

func _on_button_button_down():
	emit_signal("screenshot_name_confirm", filename_input.text)

func _on_about_to_popup():
	filename_input.text = callsign_input.text
