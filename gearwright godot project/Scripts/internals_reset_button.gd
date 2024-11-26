extends Button

@onready var confirm_dialog = $InternalsResetConfirmDialog

func _on_button_down():
	confirm_dialog.popup()
