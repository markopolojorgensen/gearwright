extends PanelContainer

var text: String : set = set_text

func _process(_delta: float) -> void:
	if text.is_empty():
		hide()
	else:
		show()
		size = Vector2()
		global_position = get_global_mouse_position()
		global_position.x -= size.x

func set_text(new_text: String):
	text = new_text
	%ExplanationLabel.text = new_text

