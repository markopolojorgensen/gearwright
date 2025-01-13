extends ColorRect

@onready var item_texture = $Texture
@onready var name_label = $NameLabel
@onready var item_popup = $ItemPopup

var icon_path
var item_ID
var item_data
var hovering = false
var popup_loaded = false

#signal item_selected(data)
signal item_selected(item_id)

func _process(_delta):
	if Input.is_action_just_pressed("mouse_rightclick") && hovering:
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
	var image = Image.load_from_file(icon_path)
	var texture = ImageTexture.create_from_image(image)
	item_texture.texture = texture
	name_label.text = a_Item_data["name"]
	
	item_popup.unfocusable = true

func _on_texture_button_button_down():
	#get_parent().on_item_selected(item_ID)
	item_selected.emit(item_ID)

func _on_texture_button_mouse_entered():
	if !popup_loaded:
		item_popup.set_data(item_data)
		popup_loaded = true
	hovering = true

func _on_texture_button_mouse_exited():
	hovering = false
	item_popup.hide()
