extends MenuButton
class_name SaveLoadMenuButton

signal button_selected(button_id: BUTTON_IDS)

enum BUTTON_IDS {
	NEW_ACTOR,
	SAVE_TO_FILE,
	SAVE_TO_PNG,
	LOAD_FROM_FILE,
	SAVES_FOLDER,
	IMAGES_FOLDER,
}

@export var new_actor_text = "New Gear"

func _ready() -> void:
	get_popup().set_item_text(BUTTON_IDS.NEW_ACTOR, new_actor_text)
	get_popup().id_pressed.connect(func(id: int):
		if id == BUTTON_IDS.NEW_ACTOR:
			input_context_system.clear()
			get_tree().reload_current_scene()
		elif id == BUTTON_IDS.SAVES_FOLDER:
			global.open_folder("Saves")
		elif id == BUTTON_IDS.IMAGES_FOLDER:
			global.open_folder("Screenshots")
		else:
			button_selected.emit(id)
		)


