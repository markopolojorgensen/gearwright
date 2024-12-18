extends HBoxContainer

# this is a SpinBox

signal increase
signal decrease

var value: int = 0

func set_value(new_value: int):
	value = new_value
	$Label.text = str(value)

func _on_minus_texture_button_pressed() -> void:
	set_value(value - 1)
	decrease.emit()

func _on_plus_texture_button_pressed() -> void:
	set_value(value + 1)
	increase.emit()
