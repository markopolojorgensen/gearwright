extends Button

@onready var background_edit_popup = $BackgroundEditPopup

func _on_background_selector_load_background(background_data):
	if background_data["background"] == "Custom":
		visible = true
	else:
		visible = false

func _on_button_down():
	if background_edit_popup.visible:
		background_edit_popup.hide()
		text = "Edit Background"
	else:
		background_edit_popup.popup()
		text = "Save"

func _on_background_edit_popup_focus_exited():
	text = "Edit Background"
