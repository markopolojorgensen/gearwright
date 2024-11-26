extends Node2D

@onready var icon = $Icon
@onready var item_popup = $ItemPopup

var item_grids := []
var selected = false
var grid_anchor = null
var item_data := {}

var hovering = false
var popup_loaded = false

var x_offset = 0
var y_offset = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position() - Vector2(x_offset - 5, y_offset + 5), 60 * delta)
		
	if Input.is_action_just_pressed("mouse_rightclick") && hovering:
		if item_popup.visible:
			item_popup.hide()
		else:
			item_popup.position = global_position + Vector2(140, 0)
			item_popup.popup()
	

func load_item(a_itemID : String):
	item_data = DataHandler.item_data[a_itemID]
	
	var image = Image.load_from_file(item_data["icon_path"])
	var texture = ImageTexture.create_from_image(image)
	icon.texture = texture
	
	for grid in DataHandler.item_grid_data[a_itemID]:
		var converter_array := []
		for i in grid:
			converter_array.push_back(int(i))
		item_grids.push_back(converter_array)
	
	var lowest_x = 0
	var lowest_y = 0
	
	for coordinate in item_grids:
		if coordinate[0] < lowest_x:
			lowest_x = coordinate[0]
		if coordinate[1] < lowest_y:
			lowest_y = coordinate[1]
	
	x_offset = ((41 * icon.scale.x)/2) + 11 + (-30 * lowest_x)
	y_offset = ((39 * icon.scale.y)/2) + (-30 * lowest_y)
	
	item_popup.unfocusable = true

func snap_to(destination: Vector2):
	var tween = get_tree().create_tween()
	
	tween.tween_property(self, "global_position", destination, 0.01).set_trans(Tween.TRANS_SINE)
	selected = false

func _on_icon_mouse_entered():
	if !popup_loaded:
		item_popup.set_data(item_data)
		popup_loaded = true
	hovering = true

func _on_icon_mouse_exited():
	hovering = false
	item_popup.hide()
