extends GridContainer

@onready var core_icon = preload("res://Scenes/core_integrity_icon.tscn")

func _on_stats_list_update_core_integrity(value):
	for node in get_children():
		node.queue_free()
	
	for i in range(value):
		add_child(core_icon.instantiate())
