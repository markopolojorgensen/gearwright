extends Label

# FIXME Label's mouse_entered and mouse_exited cause flickering...?
# if you do want to use built-in mouse signals, don't forget mouse_filter:
#   label.mouse_filter = Control.MOUSE_FILTER_PASS
signal safe_mouse_entered
signal safe_mouse_exited

@export var stat_name := ""
var hovered = false

#label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
#label.custom_minimum_size.x = 180
#label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
#label.text = stat_name

func _ready():
	text = stat_name

func _process(_delta: float) -> void:
	if stat_name.is_empty():
		return
	
	var mouse := get_global_mouse_position()
	var has_mouse: bool = get_global_rect().has_point(mouse)
	if has_mouse and not hovered:
		hovered = true
		#print("%s: entered" % stat_name)
		safe_mouse_entered.emit()
	elif not has_mouse and hovered:
		hovered = false
		#print("%s: exited" % stat_name)
		safe_mouse_exited.emit()
