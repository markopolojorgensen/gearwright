class_name Item
extends Node2D

const item_popup_scene := preload("res://actor_builders/inventory_system/item_popup.tscn")
var item_popup: Control
var is_item_popup_active := false

# used to be onready, but items no longer get added to the tree before they
#  are used.
var icon: TextureRect

var initialized := false
# list of pairs
#   e.g. [-1, 0]
var item_grids := []
var selected = false
var grid_anchor = null # GridSlotControl
var item_data := {}

var hovering = false
var popup_loaded = false

#var x_offset = 0
#var y_offset = 0
#var offset := Vector2()
# not necessarily a valid cell for this item
var top_left_corner_cell := Vector2i()

const raw_grid_cell_size := Vector2(100.0, 100.0)
var world_cell_size: Vector2

func initialize() -> void:
	$LegendNumberControl.hide()
	icon = $Icon
	world_cell_size = raw_grid_cell_size * icon.scale
	initialized = true
	hide_weight()

func _process(delta):
	if selected:
		var cell_offset: Vector2 = Vector2(top_left_corner_cell) - Vector2(0.5, 0.5)
		var scaled_offset: Vector2 = cell_offset * world_cell_size * scale
		global_position = lerp(global_position, get_global_mouse_position() + scaled_offset, 60 * delta)

# FIXME This should be more resilient
# garbage in shouldn't cause crashes
func load_item(a_itemID : String, is_player_item := true):
	if not initialized:
		initialize()
	if is_player_item:
		item_data = DataHandler.get_thing_nicely(DataHandler.DATA_TYPE.INTERNAL, a_itemID)
	else:
		item_data = DataHandler.get_thing_nicely(DataHandler.DATA_TYPE.FISH_INTERNAL, a_itemID)
	
	#var image = Image.load_from_file(item_data.get("icon_path", ""))
	#var texture = ImageTexture.create_from_image(image)
	#icon.texture = texture
	icon.texture = global.load_item_icon(item_data.icon_path)
	
	#var item_grid_data = DataHandler.item_grid_data
	#if not is_player_item:
		#item_grid_data = DataHandler.fish_item_grid_data
	
	var temp_grid_array := []
	for point in item_data["grid"]:
		temp_grid_array.push_back(point.split(","))
	
	# grid is an array of strings
	#   e.g. ["[-1", "0]"]
	#for grid in item_grid_data[a_itemID]:
	for grid in temp_grid_array:
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
	
	# not necessarily a cell that is part of the internal!
	top_left_corner_cell = Vector2i(lowest_x, lowest_y)
	

func snap_to(destination: Vector2):
	var tween = get_tree().create_tween()
	
	tween.tween_property(self, "global_position", destination, 0.05).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	selected = false

func toggle_popup():
	if is_item_popup_active:
		item_popup.hide()
		item_popup.queue_free()
		is_item_popup_active = false
	else:
		item_popup = item_popup_scene.instantiate()
		item_popup.position = Vector2(icon.get_global_rect().end.x + 16, icon.get_global_rect().position.y)# + Vector2(140, 0)
		add_child(item_popup)
		item_popup.set_data(item_data)
		is_item_popup_active = true

func hide_popup():
	if is_item_popup_active:
		toggle_popup()

func show_weight():
	var cell_offset = Vector2(get_filled_cell(false) - top_left_corner_cell)
	$WeightContainer.position = cell_offset * world_cell_size
	$WeightContainer.show()
	
	%WeightLabel.text = str(int(item_data.get("weight", 0)))

func hide_weight():
	$WeightContainer.hide()



# returns list of Vector2i
func get_item_grids_as_cells() -> Array:
	# item_grids is an array
	# each element is a 2-element array representing coordinates
	return item_grids.map(func(coord): return Vector2i(coord[0], coord[1]))

# this function returns a list of Vector2i elements
# some of these might be out of bounds!
func get_relative_cells(primary_cell: Vector2i) -> Array:
	var item_cell_offsets: Array = get_item_grids_as_cells()
	var item_cells := item_cell_offsets.map(func(offset): return primary_cell + offset)
	return item_cells

func set_legend_number(number: int, make_visible := true):
	%LegendNumberLabel.text = str(number)
	if make_visible:
		$LegendNumberControl.show()
	else:
		$LegendNumberControl.hide()
	
	var cell_offset = Vector2(get_filled_cell() - top_left_corner_cell)
	$LegendNumberControl.position = cell_offset * world_cell_size
	#$LegendNumberControl.scale = Vector2(1.5, 1.5) / scale # TODO maybe adjust this

func hide_legend_number():
	$LegendNumberControl.hide()

func show_legend_number():
	$LegendNumberControl.show()

# returns a cell filled by this internal
# returns either the top left most valid cell
#  or the middle-most top left valid cell
func get_filled_cell(top_left := true) -> Vector2i:
	var top_left_cells = get_item_grids_as_cells().filter(func(cell: Vector2i):
		if (cell.x <= 0) and (cell.y <= 0):
			return true
		)
	top_left_cells.sort_custom(func(a: Vector2i, b: Vector2i):
		var b_dist = b.distance_squared_to(Vector2i())
		var a_dist = a.distance_squared_to(Vector2i())
		if top_left:
			return b_dist < a_dist
		else:
			return a_dist < b_dist
		)
	return top_left_cells.front()


