extends Control

@onready var part_menu: PartMenu = %PartMenu
const part_menu_tabs := ["Far", "Close", "Mental", "Active", "Passive", "Mitigation"]

func _ready():
	for tab_name in part_menu_tabs:
		part_menu.add_tab(tab_name)
	
	for item_id in DataHandler.fish_item_data.keys():
		var item_data = DataHandler.get_fish_internal_data(item_id)
		var tab_name: String = item_data.type.capitalize()
		if tab_name in part_menu_tabs:
			part_menu.add_part_to_tab(tab_name, item_id, item_data)
		else:
			var error = "unknown tab '%s' for item: %s" % [tab_name, item_id]
			push_error(error)
			print(error)
	
	part_menu.set_grid_column_count(3)
