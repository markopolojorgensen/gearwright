extends ColorRect

# TODO yeet this script

@onready var slot_scene = preload("res://Scenes/fish_grid_slot.tscn")
@onready var item_scene = preload("res://Scenes/fish_item.tscn")

@onready var stats #= $FishSquisher/MarginContainer/ColorRect2/MarginContainer/HBoxContainer/VBoxContainer2/Stats/FishStatsList
@onready var name_input #= $FishSquisher/MarginContainer/ColorRect2/MarginContainer/HBoxContainer/VBoxContainer/FishNameInputContainer/FishNameInput
@onready var export_popup #= $MenuHeader/SaveOptionsMenu/ExportPopup
@onready var file_dialog #= $MenuHeader/SaveOptionsMenu/FileDialog
@onready var screenshot_popup #= $MenuHeader/SaveOptionsMenu/ScreenshotPopup
@onready var container_container #= $FishSquisher/MarginContainer/ColorRect2/MarginContainer/HBoxContainer/VBoxContainer/ContainerContainer

@onready var size_selector #= $MenuHeader/FishSizeSelectContainer/FishSizeSelector
@onready var template_selector #= $VBoxContainer2/HBoxContainer2/TemplateSelector

var grid_array := []
var item_held = null
var current_slot = null
var can_place := false
var icon_anchor : Vector2

signal item_installed(item)
signal item_removed(item)

signal new_save_loaded(user_data)
signal update_name(name)

@warning_ignore("unused_signal")
signal clear_internal_list()

var fish_data = DataHandler.get_fish_template()
var current_container_scene
var fish_containers := []

var internals := {}
var mutations := []
var current_size := ""
var current_template := ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	#if export_popup.visible or file_dialog.visible or screenshot_popup.visible:
			#return
	#if Input.is_action_just_pressed("mouse_leftclick"):
		#if item_held:
			#for container in fish_containers:
					#if container.get_global_rect().has_point(get_global_mouse_position()):
						#place_item()
		#else:
			#for container in fish_containers:
				#if container.get_global_rect().has_point(get_global_mouse_position()):
					#pickup_item()
	#elif Input.is_action_just_pressed("mouse_rightclick"):
		#drop_item()

# safe to yeet
func _on_fish_size_selector_load_fish_container(_fish_container, _size_stats):
	pass
	#internals_reset()
	#
	#if current_container_scene:
		#remove_container_scene()
	#
	#current_container_scene = fish_container.instantiate()
	#container_container.add_child(current_container_scene)
	#current_container_scene.visible = true
	#fish_containers = current_container_scene.get_children()
	#
	#generate_fish_grids(fish_containers)
	#
	#fish_data = DataHandler.get_fish_template()
	#current_size = size_stats["size"]

func generate_fish_grids(containers):
	var big_containers := []
	
	# don't look at this don't look at this don't look at this
	for container in containers:
		if container is GridContainer:
			generate_fish_grids(container.get_children())
		if not container is GridSection:
			continue
		if container.columns == 3:
			for i in container.capacity:
				create_slot(container)
		else:
			big_containers.append(container)
	
	for container in big_containers:
		for i in container.capacity:
			create_slot(container)

func remove_container_scene():
	grid_array.clear()
	current_container_scene.queue_free()

func create_slot(container):
	var new_slot = slot_scene.instantiate()
	new_slot.slot_ID = grid_array.size()
	container.add_child(new_slot)
	grid_array.push_back(new_slot)
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)

func _on_slot_mouse_entered(a_Slot):
	icon_anchor = Vector2(10000, 10000)
	current_slot = a_Slot
	if item_held:
		check_slot_availability(current_slot)
		set_grids.call_deferred(current_slot)
	pass
	
func _on_slot_mouse_exited():
	clear_grid()

func check_slot_availability(a_Slot):
	var column_count = a_Slot.get_parent().columns
	for grid in item_held.item_grids:
		var grid_to_check = a_Slot.slot_ID + grid[0] + grid[1] * column_count
		var line_switch_check = a_Slot.slot_ID % column_count + grid[0]
		if line_switch_check < 0 or line_switch_check >= column_count:
			can_place = false
			return
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			can_place = false
			return
		if grid_array[grid_to_check].state == grid_array[grid_to_check].States.TAKEN:
			can_place = false
			return
		if grid_array[grid_to_check].get_parent() != current_slot.get_parent():
			can_place = false
			return
		can_place = true

func set_grids(a_Slot):
	var column_count = a_Slot.get_parent().columns
	for grid in item_held.item_grids:
		var grid_to_check = a_Slot.slot_ID + grid[0] + grid[1] * column_count
		var line_switch_check = a_Slot.slot_ID % column_count + grid[0]
		if line_switch_check < 0 or line_switch_check >= column_count:
			continue
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			continue
		if grid_array[grid_to_check].get_parent() != current_slot.get_parent():
			continue
		if can_place:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.FREE)
			
			if grid[1] < icon_anchor.x: icon_anchor.x = grid[1]
			if grid[0] < icon_anchor.y: icon_anchor.y = grid[0]
		else:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.TAKEN)

func clear_grid():
	for grid in grid_array:
		grid.set_color(grid.States.DEFAULT)

func place_item():
	if not can_place or not current_slot:
		return
	
	var column_count = current_slot.get_parent().columns
	var calculated_grid_id = current_slot.slot_ID + icon_anchor.x * column_count + icon_anchor.y
	if calculated_grid_id >= grid_array.size():
		return
		
	item_held.get_parent().remove_child(item_held)
	current_slot.get_parent().add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	
	item_held.snap_to(grid_array[calculated_grid_id].global_position)
	
	item_held.grid_anchor = current_slot
	for grid in item_held.item_grids:
		var grid_to_check = current_slot.slot_ID + grid[0] + grid[1] * column_count
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN
		grid_array[grid_to_check].installed_item = item_held
	
	item_installed.emit(item_held)
	internals[current_slot.slot_ID] = item_held
	
	item_held = null
	clear_grid()

func pickup_item():
	if not current_slot or not current_slot.installed_item:
		return
	
	var column_count = current_slot.get_parent().columns
	item_held = current_slot.installed_item
	item_held.selected = true
	item_held.hide_number_label()
	
	for grid in item_held.item_grids:
		var grid_to_check = item_held.grid_anchor.slot_ID + grid[0] + grid[1] * column_count
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
		grid_array[grid_to_check].installed_item = null
		internals.erase(grid_to_check)
	
	check_slot_availability(current_slot)
	set_grids.call_deferred(current_slot)
	
	item_removed.emit(item_held)

func drop_item():
	if not item_held:
		return
	item_held.queue_free()
	item_held = null

func on_item_inventory_spawn_item(a_Item_ID):
	if item_held:
		return
	var new_item = item_scene.instantiate()
	add_child(new_item)
	new_item.load_item(a_Item_ID)
	new_item.selected = true
	item_held = new_item

func install_item(a_Item_ID, a_Index):
	icon_anchor = Vector2(10000, 10000)
	var column_count = grid_array[a_Index].get_parent().columns
	var new_item = item_scene.instantiate()
	add_child(new_item)
	new_item.load_item(a_Item_ID.to_snake_case())
	
	for grid in new_item.item_grids:
		if grid[1] < icon_anchor.x: icon_anchor.x = grid[1]
		if grid[0] < icon_anchor.y: icon_anchor.y = grid[0]
	
	var calculated_grid_id = grid_array[a_Index].slot_ID + icon_anchor.x * column_count + icon_anchor.y
	if calculated_grid_id >= grid_array.size():
		return
	
	new_item.get_parent().remove_child(new_item)
	grid_array[calculated_grid_id].get_parent().add_child(new_item)
	
	new_item.snap_to(grid_array[calculated_grid_id].global_position)
	
	new_item.grid_anchor = grid_array[a_Index]
	for grid in new_item.item_grids:
		var grid_to_check = a_Index + grid[0] + grid[1] * column_count
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN
		grid_array[grid_to_check].installed_item = new_item
	
	item_installed.emit(new_item)
	internals[a_Index] = new_item

func internals_reset():
	for slot in internals:
		for grid in internals[slot].item_grids:
			var grid_to_check = slot + grid[0] + grid[1] * grid_array[slot].get_parent().columns
			grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
			grid_array[grid_to_check].installed_item = null
		item_removed.emit(internals[slot])
		internals[slot].queue_free()
	internals.clear()

# this has been disconnected and rerouted, safe to yeet
func _on_save_options_menu_new_fish_pressed():
	get_tree().reload_current_scene()
	#for grid in grid_array:
	#	grid.lock()
	#for index in default_unlocks:
	#	grid_array[index].unlock()
	#emit_signal("reset_lock_tally")
	
	#internals_reset()
	#gear_data = DataHandler.get_gear_template()

func get_fish_data_string():
	fish_data["internals"] = {}
	for grid in internals.keys():
		fish_data["internals"][str(grid)] = internals[grid].item_data["name"].to_snake_case()
	
	fish_data["size"] = current_size
	fish_data["template"] = current_template
	fish_data["name"] = name_input.text
	fish_data["mutations"] = mutations
	
	return str(fish_data).replace("\\", "")

# TODO move this to new fish builder
func _on_save_options_menu_load_save_data(a_New_data):
	drop_item()
	internals_reset()
	fish_data = DataHandler.get_fish_template()
	
	new_save_loaded.emit(a_New_data)
	update_name.emit(a_New_data["name"])
	
	for grid in a_New_data["internals"]:
		print("installing " + a_New_data["internals"][grid] + " at " + grid)
		install_item.call_deferred(a_New_data["internals"][grid], int(grid))

func _on_internals_reset_confirm_dialog_confirmed():
	internals_reset()

func _on_mutation_menu_mutation_updated(stat, _value, was_added):
	if was_added:
		mutations.append(stat)
	else:
		mutations.erase(stat)

func _on_template_selector_load_template(_template):
	pass
	#current_template = template["template"]
