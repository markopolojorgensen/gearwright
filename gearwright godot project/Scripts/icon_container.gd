extends GridContainer

@export var icon_scene = preload("res://Scenes/core_integrity_icon.tscn")

func update(count: int):
	for node in get_children():
		node.queue_free()
	
	for i in range(count):
		add_child(icon_scene.instantiate())
