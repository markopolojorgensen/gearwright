extends OptionButton

signal load_frame(frame_name)

func _ready():
	for frame in DataHandler.frame_data.keys():
		add_item(frame.capitalize())
	
	if 0 < item_count:
		_on_item_selected.call_deferred(0)
	else:
		push_warning("no frames?")

func _on_item_selected(index):
	var frame_name = get_item_text(index).to_snake_case()
	load_frame.emit(frame_name)
