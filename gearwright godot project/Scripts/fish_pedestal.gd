extends Control

# TODO FIXME WHERWASI fish_size_selector
func _on_fish_size_selector_load_fish_container(_fish_container, size_data):
	if size_data["size"] == "siltstalker":
		custom_minimum_size.y = 20
	else:
		custom_minimum_size.y = 40
