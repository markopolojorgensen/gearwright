extends Popup

@onready var filename_input #= $VBoxContainer/HBoxContainer/LineEdit
@onready var fish_name_input #= $"../../../FishSquisher/MarginContainer/ColorRect2/MarginContainer/HBoxContainer/VBoxContainer/FishNameInputContainer/FishNameInput"

signal screenshot_name_confirm

func _on_button_button_down():
	screenshot_name_confirm.emit(filename_input.text)

func _on_about_to_popup():
	filename_input.text = fish_name_input.text
