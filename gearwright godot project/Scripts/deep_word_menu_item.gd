extends ColorRect

@onready var option_button = $DeepWordsOptionButton
@onready var plus_button = $Button

var deep_word_data := {}
var current_deep_word = ""
var initial_load = false

signal deep_word_added(deep_word)
signal deep_word_removed(deep_word)

func _ready():
	for deep_word in deep_word_data:
		option_button.add_item(deep_word_data[deep_word]["short_name"])
	
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
		deep_word_added.emit(deep_word_data.keys()[free_idx])
		current_deep_word = deep_word_data.keys()[free_idx]
		set_label_text(deep_word_data[deep_word_data.keys()[free_idx]]["short_name"])
		initial_load = true
	option_button.show_popup()

func _on_deep_words_option_button_item_selected(index):
	if current_deep_word:
		deep_word_removed.emit(current_deep_word)
	
	current_deep_word = deep_word_data.keys()[index]
	deep_word_added.emit(current_deep_word)
	
	option_button.hide()
	
	set_label_text(deep_word_data[current_deep_word]["short_name"])

func menu_exit_focus():
	option_button.hide()

func set_label_text(text):
	plus_button.get_children()[0].text = text
	custom_minimum_size.x = get_theme_default_font().get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, 15).x + 2
