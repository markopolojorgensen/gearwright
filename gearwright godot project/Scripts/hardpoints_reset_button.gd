extends Button

@onready var confirm_dialog = $HardpointsResetConfirmDialog

func _on_button_down():
	confirm_dialog.popup()
