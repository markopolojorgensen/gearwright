extends Control

signal safe_mouse_entered
signal safe_mouse_exited

var hovered := false

func _process(_delta: float) -> void:
	var mouse := get_global_mouse_position()
	var has_mouse: bool = get_global_rect().has_point(mouse)
	if has_mouse and not hovered:
		hovered = true
		#print("safe mouse entered")
		safe_mouse_entered.emit()
	elif not has_mouse and hovered:
		hovered = false
		#print("safe mouse exited")
		safe_mouse_exited.emit()
