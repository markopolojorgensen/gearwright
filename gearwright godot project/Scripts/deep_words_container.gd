extends VBoxContainer

var deep_word_file_path = "user://LocalData/deep_words.json"

signal deep_word_added(deep_word_data)
signal deep_word_removed(deep_word_data)

@onready var deep_word_container_scene = preload("res://Scenes/deep_word_menu_item.tscn")

@onready var placeholder = $DeepWordPlaceholder

var deep_word_data := {}
var deep_word_containers := []
var current_deep_words := []

func _ready():
	var file = FileAccess.open(deep_word_file_path, FileAccess.READ)
	deep_word_data = JSON.parse_string(file.get_as_text())
	file.close()

func add_deep_word_container():
	var temp_container = deep_word_container_scene.instantiate()
	temp_container.deep_word_data = deep_word_data.duplicate(true)
	temp_container.deep_word_added.connect(add_deep_word)
	temp_container.deep_word_removed.connect(remove_deep_word)
	deep_word_containers.append(temp_container)
	add_child(temp_container)
	for deep_word in current_deep_words:
		temp_container.option_button.set_item_disabled(deep_word_data.keys().find(deep_word), true)

func remove_deep_word_container():
	if deep_word_containers.back().current_deep_word:
		remove_deep_word(deep_word_containers.back().current_deep_word)
	deep_word_containers.back().queue_free()
	deep_word_containers.erase(deep_word_containers.back())

func add_deep_word(deep_word):
	current_deep_words.append(deep_word)
	for container in deep_word_containers:
		container.option_button.set_item_disabled(deep_word_data.keys().find(deep_word), true)
	deep_word_added.emit(deep_word_data[deep_word])

func remove_deep_word(deep_word):
	current_deep_words.erase(deep_word)
	for container in deep_word_containers:
		container.option_button.set_item_disabled(deep_word_data.keys().find(deep_word), false)
	deep_word_removed.emit(deep_word_data[deep_word])

func _on_stats_list_update_deep_words(deep_words_known):
	var difference = deep_words_known - deep_word_containers.size()
	if difference == 0:
		return
	if difference > 0:
		for i in range(difference):
			add_deep_word_container()
	else:
		for i in range(difference * -1):
			remove_deep_word_container()
	
	if deep_word_containers.size() == 0:
		placeholder.show()
	else:
		placeholder.hide()

func _on_mech_builder_new_save_loaded(user_data):
	if user_data.keys().has("deep_words"):
		for deep_word in user_data["deep_words"]:
			add_preselected_container(deep_word)

func add_preselected_container(_deep_word):
	pass
