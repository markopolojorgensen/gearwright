extends Node2D


func _ready() -> void:
	$FileDialog.popup_centered()




func _on_file_dialog_file_selected(path: String) -> void:
	print("file_selected: %s" % str(path))

func _on_file_dialog_canceled() -> void:
	print("cancelled")


# emitted whenever the ok button is pushed, even if there's a followup popup
# confirmed will not tell you when the window is hidden, use file_selected and canceled for that
func _on_file_dialog_confirmed() -> void:
	print("confirmed")


func _on_file_dialog_custom_action(action: StringName) -> void:
	print("custom action: %s" % str(action))
