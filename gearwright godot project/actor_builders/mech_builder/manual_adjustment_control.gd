extends PanelContainer

signal increase
signal decrease

func _ready() -> void:
	get_spin_box().increase.connect(func(): increase.emit())
	get_spin_box().decrease.connect(func(): decrease.emit())

func get_spin_box() -> Control:
	return %CustomStatEditControl
