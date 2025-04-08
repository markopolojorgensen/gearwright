extends OptionButton

signal type_selected(fish_type: GearwrightFish.TYPE)

func _ready():
	var fish_type_data := DataHandler.get_merged_data(DataHandler.DATA_TYPE.FISH_TYPE)
	for type_key in fish_type_data.keys():
		add_item(type_key.capitalize())

func _on_item_selected(index):
	type_selected.emit(GearwrightFish.type_from_string(get_item_text(index)))

