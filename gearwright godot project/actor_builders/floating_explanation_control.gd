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
		
		# keep within viewport
		var x_diff: float = get_global_rect().end.x - get_viewport_rect().end.x
		var y_diff: float = get_global_rect().end.y - get_viewport_rect().end.y
		var diff: Vector2 = Vector2(
				clampf(x_diff, 0, INF),
				clampf(y_diff, 0, INF)
		)
		global_position -= diff

func set_text(new_text: String):
	text = new_text
	%ExplanationLabel.text = new_text

