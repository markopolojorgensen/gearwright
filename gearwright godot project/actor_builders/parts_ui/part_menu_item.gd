extends ColorRect

@onready var item_texture: TextureRect = $Texture
@onready var name_label = $NameLabel

var is_item_popup_active := false
var item_popup
const item_popup_scene = preload("res://actor_builders/inventory_system/item_popup.tscn")

var icon_path: String
var item_ID
var item_data
var hovering = false

signal item_selected(item_id)

func _input(event: InputEvent) -> void:
	if not hovering:
		return
	
	if event.is_action_pressed("mouse_rightclick"):
		toggle_item_popup()

func toggle_item_popup():
	if is_item_popup_active:
		item_popup.hide()
		item_popup.queue_free()
		is_item_popup_active = false
	else:
		item_popup = item_popup_scene.instantiate()
		item_popup.position = global_position + Vector2(140, 0)
		add_child(item_popup)
		item_popup.set_data(item_data)
		is_item_popup_active = true

# must be called after being added to scene tree
func load_item(a_Item_data, a_Item_ID):
	item_ID = a_Item_ID
	item_data = a_Item_data.duplicate(true)
	icon_path = a_Item_data["icon_path"]
	#var image = Image.load_from_file(icon_path)
	#var texture = ImageTexture.create_from_image(image)
	#item_texture.texture = texture
	icon_path = icon_path as String
	item_texture.texture = global.load_item_icon(icon_path)
	name_label.text = a_Item_data["name"]

func _on_texture_button_button_down():
	item_selected.emit(item_ID)

func _on_texture_button_mouse_entered():
	hovering = true

func _on_texture_button_mouse_exited():
	hovering = false
	if is_item_popup_active:
		toggle_item_popup()
