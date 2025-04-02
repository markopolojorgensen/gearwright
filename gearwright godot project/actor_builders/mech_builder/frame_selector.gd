extends OptionButton

signal load_frame(frame_name)

func _ready():
	for frame in DataHandler.frame_data.keys():
		add_item(frame.capitalize())

func _on_item_selected(index):
	var frame_name = get_item_text(index).to_snake_case()
	load_frame.emit(frame_name)
