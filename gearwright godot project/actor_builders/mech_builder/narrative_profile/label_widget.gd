extends Container

signal fancy_mouse_entered
signal fancy_mouse_exited
signal button_pressed

@export_enum("Plus", "X") var button_texture_style := "Plus"
@export var plus_normal := preload("res://actor_builders/stat_edit_control/plus_icon.png")
@export var plus_pressed := preload("res://actor_builders/stat_edit_control/plus_icon_dark.png")
@export var x_normal := preload("res://actor_builders/stat_edit_control/x_icon_00.png")
@export var x_pressed := preload("res://actor_builders/stat_edit_control/x_icon_01.png")

@onready var texture_button: TextureButton = %TextureButton
var is_mouse_inside := false

func _ready():
	match button_texture_style:
		"Plus":
			texture_button.texture_normal = plus_normal
			texture_button.texture_pressed = plus_pressed
		"X":
			texture_button.texture_normal = x_normal
			texture_button.texture_pressed = x_pressed
	
	texture_button.mouse_entered.connect(update_mouse_status)
	texture_button.mouse_exited.connect(update_mouse_status)
	mouse_entered.connect(update_mouse_status)
	mouse_exited.connect(update_mouse_status)
	
	if global_util.was_run_directly(self):
		fancy_mouse_entered.connect(func():
			print("mouse in")
			)
		fancy_mouse_exited.connect(func():
			print("mouse out")
			)
		button_pressed.connect(func():
			print("pressed")
			)


func update_mouse_status():
	if not (is_instance_valid(self) and is_inside_tree() and not is_queued_for_deletion()):
		return
	
	var has_mouse = get_global_rect().has_point(get_global_mouse_position())
	if has_mouse and not is_mouse_inside:
		fancy_mouse_entered.emit()
		%Highlight.show()
	elif not has_mouse and is_mouse_inside:
		fancy_mouse_exited.emit()
		%Highlight.hide()
	is_mouse_inside = has_mouse

func set_text(text: String):
	%Label.text = text

func _on_texture_button_pressed() -> void:
	button_pressed.emit()
