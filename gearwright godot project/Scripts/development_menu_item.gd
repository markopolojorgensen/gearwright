extends ColorRect

# WHEREWASI

@onready var option_button = $DevelopmentsOptionButton
@onready var plus_button = $Button

var development_data := {}
var current_development = ""
var initial_load = false

signal development_added(development)
signal development_removed(development)

func _ready():
	development_data = DataHandler.development_data.duplicate(true)
	for development in development_data:
		option_button.add_item(development_data[development]["name"])
	
	option_button.get_popup().max_size.y = 300
	option_button.get_popup().focus_exited.connect(menu_exit_focus)

func _on_button_button_down():
	option_button.show()
	var free_idx = 0
	if not initial_load:
		for i in range(option_button.item_count):
			if option_button.is_item_disabled(i):
				continue
			else:
				free_idx = i
				option_button.select(free_idx)
				break
		development_added.emit(development_data.keys()[free_idx])
		current_development = development_data.keys()[free_idx]
		set_label_text(development_data[current_development]["name"])
		initial_load = true
	option_button.show_popup()

func _on_developments_option_button_item_selected(index):
	if current_development:
		development_removed.emit(current_development)
	
	current_development = development_data.keys()[index]
	development_added.emit(current_development)
	
	option_button.hide()
	
	set_label_text(development_data[current_development]["name"])

func menu_exit_focus():
	option_button.hide()

func set_label_text(text):
	plus_button.get_children()[0].text = text
	custom_minimum_size.x = get_theme_default_font().get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, 15).x + 2
