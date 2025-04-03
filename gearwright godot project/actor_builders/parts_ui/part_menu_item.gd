extends ColorRect

@onready var item_texture = $Texture
@onready var name_label = $NameLabel
@onready var item_popup = $ItemPopup

var icon_path
var item_ID
var item_data
var hovering = false
var popup_loaded = false

signal item_selected(item_id)

func _process(_delta):
	if not Input.is_action_just_pressed("mouse_rightclick"):
		return
	if not hovering:
		return
	#if input_context_system.get_current_input_context_id() != input_context_system.INPUT_CONTEXT.MECH_BUILDER:
		#return
	
	if item_popup.visible:
		item_popup.hide()
	else:
		item_popup.position = global_position + Vector2(140, 0)
		item_popup.popup()

# must be called after being added to scene tree
func load_item(a_Item_data, a_Item_ID):
	item_ID = a_Item_ID
	item_data = a_Item_data.duplicate(true)
	icon_path = a_Item_data["icon_path"]
	#var image = Image.load_from_file(icon_path)
	#var texture = ImageTexture.create_from_image(image)
	#item_texture.texture = texture
	item_texture.texture = load(icon_path)
	name_label.text = a_Item_data["name"]
	
	item_popup.unfocusable = true

func _on_texture_button_button_down():
	item_selected.emit(item_ID)

func _on_texture_button_mouse_entered():
	if !popup_loaded:
		item_popup.set_data(item_data)
		popup_loaded = true
	hovering = true

func _on_texture_button_mouse_exited():
	hovering = false
	item_popup.hide()
