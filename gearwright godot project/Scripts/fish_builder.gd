extends Control

@onready var part_menu: PartMenu = %PartMenu
const part_menu_tabs := ["Far", "Close", "Mental", "Active", "Passive", "Mitigation"]

@onready var inventory: DiabloStyleInventorySystem = $DiabloStyleInventorySystem

var request_update_controls: bool = false


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

func _process(delta: float) -> void:
	if request_update_controls:
		request_update_controls = false
		update_controls()

func update_controls():
	#inventory.fancy_update(current_character, gear_section_controls)
	pass

func _on_diablo_style_inventory_system_something_changed() -> void:
	request_update_controls = true



