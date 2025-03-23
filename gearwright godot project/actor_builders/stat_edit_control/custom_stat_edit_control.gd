extends HBoxContainer

# this is a SpinBox

signal increase
signal decrease

var value: int = 0 : set = set_value
var max_value: int = -1 : set = set_max_value
@export var use_max_value := false

func set_value(new_value: int):
	value = new_value
	update_label()

func set_max_value(new_max_value: int):
	max_value = new_max_value
	update_label()

func update_label():
	if use_max_value:
		$Label.text = "%d/%d" % [value, max_value]
	else:
		$Label.text = str(value)
	

func _on_minus_texture_button_pressed() -> void:
	set_value(value - 1)
	decrease.emit()

func _on_plus_texture_button_pressed() -> void:
	set_value(value + 1)
	increase.emit()
