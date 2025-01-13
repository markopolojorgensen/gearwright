extends PanelContainer
class_name PartMenu

signal item_spawned(item_id)

# @onready var tab_bar: TabBar = %TabBar
@onready var tab_container: TabContainer = $TabContainer

const part_list_scene := preload("res://Scenes/part_list.tscn")
const part_item_scene = preload("res://Scenes/part_menu_item.tscn")

func add_tab(tab_name: String):
	var part_list := part_list_scene.instantiate()
	part_list.name = tab_name
	tab_container.add_child(part_list)

# part_id is an index into item_data.json
# TODO or fish_item_data? where does that come from?
func add_part_to_tab(tab_name: String, part_id: String, part_data: Dictionary):
	var part := part_item_scene.instantiate()
	part.load_item.call_deferred(part_data, part_id)
	part.item_selected.connect(func(item_id: String):
		item_spawned.emit(item_id)
		)
	
	var part_list = tab_container.get_node(tab_name)
	assert(part_list != null)
	part_list.add_part(part, part_data.type)

# only affects existing grids
# only call this after add all items!
func set_grid_column_count(new_column_count: int):
	for part_list in tab_container.get_children():
		part_list.set_grid_column_count(new_column_count)


