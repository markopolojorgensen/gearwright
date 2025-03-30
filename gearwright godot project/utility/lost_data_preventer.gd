extends Node2D

var saved_data
var current_data

@onready var unsaved_warning_dialog = %UnsavedWarningDialog
var _unsaved_confirm_action: Callable = func(): pass

func check_lost_data(followup: Callable):
	if saved_data == current_data:
		followup.call()
	else:
		_unsaved_confirm_action = followup
		unsaved_warning_dialog.popup_centered()

func _on_unsaved_warning_dialog_confirmed() -> void:
	_unsaved_confirm_action.call()



