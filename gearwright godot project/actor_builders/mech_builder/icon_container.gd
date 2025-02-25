extends GridContainer

@export var icon_scene = preload("res://actor_builders/mech_builder/core_integrity_icon.tscn")

func update(count: int):
	for node in get_children():
		node.queue_free()
	
	for i in range(count):
		add_child(icon_scene.instantiate())
