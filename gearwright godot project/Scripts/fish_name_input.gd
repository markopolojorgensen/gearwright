extends LineEdit

func _on_save_options_menu_new_fish_pressed():
	text = ""

# TODO FIXME WHERWASI fish_size_selector
func _on_fish_size_selector_load_fish_container(_fish_container, _size_data):
	text = ""

func _on_fish_builder_update_name(fish_name):
	text = fish_name
