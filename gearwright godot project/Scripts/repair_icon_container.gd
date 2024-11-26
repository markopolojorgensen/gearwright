extends GridContainer

@onready var repair_icon = preload("res://Scenes/repair_kit_icon.tscn")

func _on_stats_list_update_repair_kits(value):
	for node in get_children():
		node.queue_free()
	
	for i in range(value):
		add_child(repair_icon.instantiate())
