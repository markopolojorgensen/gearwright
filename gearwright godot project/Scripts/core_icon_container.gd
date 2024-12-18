extends GridContainer

@onready var core_icon = preload("res://Scenes/core_integrity_icon.tscn")

# TODO yeet
func _on_stats_list_update_core_integrity(_value):
	pass

func update(core_integrity: int):
	for node in get_children():
		node.queue_free()
	
	for i in range(core_integrity):
		add_child(core_icon.instantiate())
