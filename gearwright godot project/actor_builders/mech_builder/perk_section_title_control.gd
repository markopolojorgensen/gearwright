extends VBoxContainer

@export var title := "Deep Words"

signal decrease
signal increase

func _ready() -> void:
	%Label.text = title
	hide_manual_adjustment_control()
	%ManualAdjustmentControl.get_spin_box().decrease.connect(func():
		decrease.emit()
		)
	%ManualAdjustmentControl.get_spin_box().increase.connect(func():
		increase.emit()
		)

func show_manual_adjustment_control():
	%ManualAdjustmentControl.show()
	#size_flags_horizontal = Control.SIZE_EXPAND_FILL

func hide_manual_adjustment_control():
	%ManualAdjustmentControl.hide()
	#size_flags_horizontal = Control.SIZE_SHRINK_CENTER
