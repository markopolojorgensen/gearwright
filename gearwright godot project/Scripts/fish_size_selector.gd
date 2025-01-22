extends OptionButton

signal fish_size_selected(fish_size: GearwrightFish.SIZE)

func _ready() -> void:
	for size_name in DataHandler.fish_size_data.keys():
		add_item(size_name.capitalize())

func _on_item_selected(index: int) -> void:
	fish_size_selected.emit(GearwrightFish.size_from_string(get_item_text(index)))
