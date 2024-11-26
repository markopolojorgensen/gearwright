extends VBoxContainer

@onready var menu_item_scene = preload("res://Scenes/part_menu_item.tscn")
@onready var internals_scroll_scene = preload("res://Scenes/internals_scroll_container.tscn")
@onready var internals_grid_scene = preload("res://Scenes/fish_internals_grid.tscn")
@onready var margin_container = $MarginContainer

@onready var fish_builder = $"../../../VBoxContainer/HBoxContainer/FishBuilder"

var section_list := {"far": null, "close": null, "mental": null, "active": null, "passive": null, "mitigation": null}

func _ready():
	for part in section_list:
		var new_scroll = internals_scroll_scene.instantiate()
		var new_grid = internals_grid_scene.instantiate()
		new_scroll.add_child(new_grid)
		margin_container.add_child(new_scroll)
		new_grid.spawn_item.connect(fish_builder.on_item_inventory_spawn_item)
		section_list[part] = new_grid
	
	var item_array := []
	for item in DataHandler.fish_item_data:
		item_array.append(DataHandler.fish_item_data[item])
	
	item_array.sort_custom(func(a, b): return a["name"] < b["name"])
	
	for item in item_array:
		if not section_list.has(item["type"]):
			continue
		var new_entry = menu_item_scene.instantiate()
		section_list[item["type"]].add_child(new_entry)
		new_entry.load_item(item, DataHandler.fish_item_data.find_key(item))

func change_visibility(label):
	for section in section_list:
		if !section_list[section]:
			return
		
		if section == label:
			section_list[section].get_parent().visible = true
		else:
			section_list[section].get_parent().visible = false


func _on_tab_bar_tab_chosen(label):
	change_visibility.call_deferred(label)
