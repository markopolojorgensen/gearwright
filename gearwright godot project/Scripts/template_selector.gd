extends OptionButton

signal type_selected(fish_type: GearwrightFish.TYPE)

func _ready():
	for type_key in DataHandler.fish_type_data.keys():
		add_item(type_key.capitalize())

func _on_item_selected(index):
	type_selected.emit(GearwrightFish.type_from_string(get_item_text(index)))

