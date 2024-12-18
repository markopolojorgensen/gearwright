extends GridContainer

@onready var repair_icon = preload("res://Scenes/repair_kit_icon.tscn")

# TODO combine this with core integrity GridContainer control
func _on_stats_list_update_repair_kits(_value):
	pass

func update(repair_kit_count: int):
	for node in get_children():
		node.queue_free()
	
	for i in range(repair_kit_count):
		add_child(repair_icon.instantiate())
