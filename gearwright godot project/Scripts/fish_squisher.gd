extends ColorRect

func _on_fish_size_selector_load_fish_container(_fish_container, size_data):
	if size_data["size"] == "serpent_leviathan":
		size.x = 980
		position.x = 33
	else:
		size.x = 900
		position.x = 50
