extends Control

# if you scale a label up it looks bad
# this uses font_size overrides to scale up instead

# TODO yeet this script, I don't think it works

var horizontal_alignment : set = set_horizontal_alignment
var text : set = set_text

func set_horizontal_alignment(ha):
	%Label.horizontal_alignment = ha

func set_text(new_text: String):
	%Label.text = new_text

func update_scale():
	pass
	#var global_scale = get_global_transform().get_scale()
	##global_util.print_once(global_scale)
	#var scale_reciprocal = Vector2(1.0, 1.0) / global_scale
	#global_util.print_once("label scale: %.2f" % new_label_scale.x)
	#global_util.print_once("new font size: %d" % new_font_size)
	#$CenterContainer.scale = scale_reciprocal
	#var new_font_size = 16 * global_scale.x
	#%Label.add_theme_font_size_override("font_size", new_font_size)
	#label.scale = new_label_scale
	
	#custom_minimum_size = %Label.size * scale_reciprocal
	$CenterContainer.size = size * (Vector2(1.0, 1.0) / $CenterContainer.scale)
	#global_util.print_once("cc size: %s" % str($CenterContainer.size))
	#global_util.print_once("scalinglabel size: %s" % str(size))
	#queue_redraw()


#func _draw() -> void:
	#var rect := get_rect()
	#rect.position = Vector2()
	#draw_rect(rect, Color.BLACK, false)

#var previous_scale

#func _ready():
	#var control := get_child(0) as Control
	#control.resized.connect(resize_self)
#
#func resize_self():
	#var control := get_child(0) as Control
	##if control.scale != previous_scale:
		## print("  asc resizing!")
		##previous_scale = control.scale
	##custom_minimum_size = .size * control.scale
	##global_util.print_once(custom_minimum_size)
#
#func _on_resized() -> void:
	## print("asc resized!")
	#resize_self()


