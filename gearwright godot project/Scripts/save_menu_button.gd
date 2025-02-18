extends MenuButton
class_name SaveLoadMenuButton

signal button_selected(button_id: BUTTON_IDS)

# var buttons_to_add := ["New Gear", "Save to File", "Load from File", "Open Saves Folder", "Screenshot", "Open Screenshot Folder"]

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
		button_selected.emit(id)
		)


