extends ColorRect

# maybe keep this around just in case we want to revert...?

@onready var option_button = $ManeuversOptionButton
@onready var plus_button = $Button

var maneuver_data := {}
var current_maneuver = ""
var locations_in_menu := []
var initial_load = false

signal maneuver_added(maneuver)
signal maneuver_removed(maneuver)

func _ready():
	locations_in_menu = maneuver_data.keys().duplicate()
	var last_category = ""
	for maneuver in maneuver_data:
		if maneuver_data[maneuver]["category"] != last_category:
			last_category = maneuver_data[maneuver]["category"]
			option_button.add_separator(last_category.capitalize())
			locations_in_menu.insert(locations_in_menu.find(maneuver), "")
		option_button.add_item(maneuver_data[maneuver]["name"])
	
	option_button.get_popup().max_size.y = 300
	option_button.get_popup().focus_exited.connect(menu_exit_focus)

func _on_button_button_down():
	option_button.show()
	var free_idx = 0
	if not initial_load:
		for i in range(option_button.item_count):
			if option_button.is_item_disabled(i) or option_button.is_item_separator(i):
				continue
			else:
				free_idx = i
				option_button.select(free_idx)
				break
		maneuver_added.emit(locations_in_menu[free_idx])
		current_maneuver = locations_in_menu[free_idx]
		set_label_text(maneuver_data[locations_in_menu[free_idx]]["name"])
		initial_load = true
	option_button.show_popup()

func _on_maneuvers_option_button_item_selected(index):
	if current_maneuver:
		maneuver_removed.emit(current_maneuver)
	
	current_maneuver = locations_in_menu[index]
	maneuver_added.emit(current_maneuver)
	
	option_button.hide()
	
	set_label_text(maneuver_data[current_maneuver]["name"])

func menu_exit_focus():
	option_button.hide()

func set_label_text(text):
	plus_button.get_children()[0].text = text
	custom_minimum_size.x = get_theme_default_font().get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, 15).x + 2
