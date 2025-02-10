extends Label

# TODO yeet this script

var current_template = ""
var current_size = ""

var sizes_to_label_as_fish = ["small", "medium", "large", "massive"]

func update_label():
	text = current_template + " " + current_size

func _on_fish_size_selector_load_fish_container(_fish_container, _size_data):
	pass
	#current_size = size_data["size"].capitalize()
	#
	#if size_data["size"] in sizes_to_label_as_fish:
		#current_size += " Fish"
	#
	#update_label()

func _on_template_selector_load_template(_template):
	pass
	#current_template = template["template"].capitalize()
	#update_label()
