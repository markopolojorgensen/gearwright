extends Control

@export var enabled := false

func _process(_delta: float) -> void:
	if get_child_count() <= 0:
		return
	if not enabled:
		return
	
	var child: Control = get_child(0)
	custom_minimum_size = child.get_minimum_size() * child.scale


