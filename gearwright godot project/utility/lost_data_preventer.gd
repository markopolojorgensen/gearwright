extends Node2D

var saved_data
var current_data

@export var debug := false

@onready var unsaved_warning_dialog = %UnsavedWarningDialog
var _unsaved_confirm_action: Callable = func(): pass

func check_lost_data(followup: Callable):
	if debug:
		checksum()
	
	if are_changes_saved():
		followup.call()
	else:
		_unsaved_confirm_action = followup
		unsaved_warning_dialog.popup_centered()

func _on_unsaved_warning_dialog_confirmed() -> void:
	_unsaved_confirm_action.call()

func checksum():
	if saved_data == current_data:
		global_util.fancy_print("saved == current, continuing")
	else:
		global_util.fancy_print("saved != current")
		global_util.indent()
		if (saved_data is Dictionary) and (current_data is Dictionary):
			for key in current_data.keys():
				var current_value = current_data[key]
				var saved_value = saved_data.get(key, null)
				if current_value != saved_value:
					global_util.fancy_print("different values for key %s" % str(key))
					global_util.indent()
					global_util.fancy_print(str(saved_value))
					global_util.fancy_print(str(current_value))
					global_util.dedent()
		else:
			breakpoint
		global_util.dedent()

func are_changes_saved():
	return saved_data == current_data






