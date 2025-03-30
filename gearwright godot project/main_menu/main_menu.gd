extends Control

func _ready() -> void:
	# coming back from some other scene, yeet all history
	input_context_system.clear()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()





