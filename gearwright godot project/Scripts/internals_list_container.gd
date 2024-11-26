extends GridContainer

var internal_menu_item_scene = preload("res://Scenes/internal_menu_item.tscn")

var internals := []
var label_dict := {}
var items := []

func _on_fish_builder_item_installed(item):
	var item_name = item.item_data["name"]
		
	if not item_name in internals:
		var new_label = internal_menu_item_scene.instantiate()
		add_child(new_label)
		new_label.name_label.text = item_name
	
		var temp_font_size = 17
	
		var min_x = 80
		while get_theme_default_font().get_multiline_string_size(item_name, HORIZONTAL_ALIGNMENT_LEFT, min_x, temp_font_size, 1).x > min_x:
			temp_font_size = temp_font_size - 1
	
		new_label.name_label.set("theme_override_font_sizes/font_size", temp_font_size)
		label_dict[item_name] = new_label
	
	internals.append(item_name)
	items.append(item)
	item.set_number_label(internals.find(item_name) + 1)
	
	update_labels()

func _on_fish_builder_item_removed(item):	
	var item_name = item.item_data["name"]
	internals.remove_at(internals.rfind(item_name))
	
	if not internals.has(item_name):
		label_dict[item_name].queue_free()
		label_dict.erase(item_name)
	
	items.erase(item)
	
	update_labels()

func update_labels():
	var highlander_internals := []
	for internal in internals:
		if internal not in highlander_internals:
			highlander_internals.append(internal)
	
	for menu_item in label_dict.values():
		menu_item.number_label.text = str(highlander_internals.find(menu_item.name_label.text) + 1) + "."
	for item in items:
		item.set_number_label(highlander_internals.find(item.item_data["name"]) + 1)


func _on_fish_builder_clear_internal_list():
	internals.clear()
	items.clear()
	label_dict.clear()
	for child in get_children():
		child.queue_free()
