extends Popup

# TODO yeet this script

@onready var filename_input = $VBoxContainer/HBoxContainer/LineEdit
@onready var callsign_input = %CallsignLineEdit

signal screenshot_name_confirm

func _on_button_button_down():
	screenshot_name_confirm.emit(filename_input.text)

func _on_about_to_popup():
	filename_input.text = callsign_input.text
