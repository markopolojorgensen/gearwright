extends Control

const item_scene = preload("res://Scenes/item.tscn")
const slot_scene = preload("res://Scenes/grid_slot.tscn")

signal item_installed(item)
signal item_removed(item)

signal set_gear_ability(frame_data)

signal new_save_loaded(user_data)

signal incrememnt_lock_tally(change)
signal reset_lock_tally


#@onready var item_inventory_container: Container = %ItemInventory
@onready var stats_container: Container = %StatsVBoxContainer

@onready var export_popup: Popup = %ExportPopup
@onready var screenshot_popup: Popup = %ScreenshotPopup
@onready var file_dialog: FileDialog = %FileDialog
@onready var save_menu: MenuButton = %SaveOptionsMenu
@onready var save_menu_popup: PopupMenu = save_menu.get_popup()
@onready var callsign_line_edit: LineEdit = %CallsignLineEdit
@onready var developments_container = %DevelopmentsContainer
@onready var maneuvers_container = %ManeuversContainer
@onready var deep_words_container = %DeepWordsContainer


@onready var containers = [
	%ChestContainer,
	%LeftArmContainer,
	%RightArmContainer,
	%HeadContainer,
	%LegContainer,
]

var grid_array := []
enum Modes {EQUIP, PLACE, UNLOCK}
var mode = Modes.EQUIP
var item_held
var current_slot
var icon_anchor: Vector2

var default_unlocks := []

var gear_data = DataHandler.get_gear_template()
var internals := {}
var current_frame := ""
var current_background := ""
var custom_background := []




#region initialization

func _ready():
	#item_inventory_container.item_spawned.connect(_on_item_inventory_item_spawned)
	for container in containers:
		for i in container.capacity:
			create_slot(container)
	print(str(grid_array))
	breakpoint

func create_slot(container):
	var new_slot = slot_scene.instantiate()
	new_slot.slot_ID = grid_array.size()
	container.add_child(new_slot)
	grid_array.push_back(new_slot)
	new_slot.slot_entered.connect(_on_slot_mouse_entered)
	new_slot.slot_exited.connect(_on_slot_mouse_exited)

#endregion





func _process(_delta):
	if Input.is_action_just_pressed("mouse_leftclick"):
		if export_popup.visible or file_dialog.visible or screenshot_popup.visible or save_menu_popup.visible:
			return
		match mode:
			Modes.EQUIP:
				for container in containers:
					if container.get_global_rect().has_point(get_global_mouse_position()):
						pickup_item()
			Modes.PLACE:
				for container in containers:
					if container.get_global_rect().has_point(get_global_mouse_position()):
						place_item()
			Modes.UNLOCK:
				for container in containers:
					if container.get_global_rect().has_point(get_global_mouse_position()):
						toggle_locked()
	elif Input.is_action_just_pressed("mouse_rightclick"):
		match mode:
			Modes.PLACE:
				drop_item()

func pickup_item():
	if not current_slot or not current_slot.installed_item:
		return
	
	var column_count = current_slot.get_parent().columns
	item_held = current_slot.installed_item
	item_held.selected = true
	
	for grid in item_held.item_grids:
		var grid_to_check = item_held.grid_anchor.slot_ID + grid[0] + grid[1] * column_count
		grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
		grid_array[grid_to_check].installed_item = null
		internals.erase(grid_to_check)
	
	item_removed.emit(item_held)
	stats_container.update_weight_label_effect(item_held.item_data)
	
	if is_slot_open(current_slot):
		set_grids.call_deferred(current_slot)
	
	mode = Modes.PLACE

func place_item():
	if not current_slot or not is_slot_open(current_slot):
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
	mode = Modes.EQUIP
	stats_container.update_weight_label_effect(null)
	clear_grid()

func toggle_locked():
	if not current_slot or not is_lock_toggleable(current_slot):
		return
	
	if current_slot.locked:
		current_slot.unlock()
		gear_data["unlocks"].push_back(current_slot.slot_ID)
		incrememnt_lock_tally.emit(1)
		
	else:
		if !current_slot.installed_item:
			current_slot.lock()
			gear_data["unlocks"].erase(current_slot.slot_ID)
			incrememnt_lock_tally.emit(-1)
	
	if is_lock_toggleable(current_slot):
		set_lock_grids.call_deferred(current_slot)

func drop_item():
	if not item_held:
		return
	item_held.queue_free()
	item_held = null
	mode = Modes.EQUIP
	stats_container.update_weight_label_effect(null)

# func check_slot_availability(a_Slot):
# I modified this from the original, not sure if it works anymore lmao
# references to can_place should use this instead I guess
# not sure that is_slot_open is actually a good name, hmmmm
func is_slot_open(slot):
	var column_count = slot.get_parent().columns
	for grid in item_held.item_grids:
		var grid_to_check = slot.slot_ID + grid[0] + grid[1] * column_count
		var line_switch_check = slot.slot_ID % column_count + grid[0]
		if line_switch_check < 0 or line_switch_check >= column_count:
			return false
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			return false
		if grid_array[grid_to_check].state == grid_array[grid_to_check].States.TAKEN or grid_array[grid_to_check].locked:
			return false
		if grid_array[grid_to_check].get_parent() != current_slot.get_parent():
			return false
		if item_held.item_data["section"] != "any" and !grid_array[grid_to_check].get_parent().get_name().ends_with(item_held.item_data["section"].capitalize() + "Container"):
			return false
		if not stats_container.is_under_weight_limit(item_held.item_data):
			return false
	
	return true

func set_grids(slot):
	var column_count = slot.get_parent().columns
	for grid in item_held.item_grids:
		var grid_to_check = slot.slot_ID + grid[0] + grid[1] * column_count
		var line_switch_check = slot.slot_ID % column_count + grid[0]
		if line_switch_check < 0 or line_switch_check >= column_count:
			continue
		if grid_to_check < 0 or grid_to_check >= grid_array.size():
			continue
		if grid_array[grid_to_check].get_parent() != current_slot.get_parent():
			continue
		if is_slot_open(slot):
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.FREE)
			
			if grid[1] < icon_anchor.x:
				icon_anchor.x = grid[1]
			if grid[0] < icon_anchor.y:
				icon_anchor.y = grid[0]
		else:
			grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.TAKEN)

func clear_grid():
	for grid in grid_array:
		grid.set_color(grid.States.DEFAULT)

# used to be check_lock_availability, modified can_lock
func is_lock_toggleable(slot):
	if not slot.locked and default_unlocks.has(slot.slot_ID):
		return false
	if slot.installed_item:
		return false
	if slot.locked and not stats_container.unlocks_remaining():
		return false
	return true

func set_lock_grids(slot):
	if is_lock_toggleable(slot):
		grid_array[slot.slot_ID].set_color(grid_array[slot.slot_ID].States.FREE)
	else: 
		grid_array[slot.slot_ID].set_color(grid_array[slot.slot_ID].States.TAKEN)










#region reactivity

func _on_slot_mouse_entered(a_Slot):
	icon_anchor = Vector2(10000, 10000)
	current_slot = a_Slot
	if item_held:
		if is_slot_open(current_slot):
			set_grids.call_deferred(current_slot)
	if mode == Modes.UNLOCK:
		if is_slot_open(current_slot):
			set_lock_grids.call_deferred(current_slot)

func _on_slot_mouse_exited(_slot):
	if mode == Modes.UNLOCK:
		current_slot.set_color(current_slot.States.TAKEN)
		for grid in grid_array:
			if not default_unlocks.has(grid.slot_ID):
				grid.set_color(grid.States.DEFAULT)
	else:
		clear_grid()

func _on_item_inventory_item_spawned(item_id):
	if item_held:
		return
	var new_item = item_scene.instantiate()
	add_child(new_item)
	new_item.load_item(item_id)
	new_item.selected = true
	item_held = new_item
	mode = Modes.PLACE
	stats_container.update_weight_label_effect(item_held.item_data)



func _on_level_selector_change_level(_a_Level_data, a_Level):
	gear_data["level"] = a_Level

func _on_save_options_menu_load_save_data(a_New_data):
	drop_item()
	gear_data = DataHandler.get_gear_template()
	
	new_save_loaded.emit(a_New_data)
	
	var temp_unlocks = PackedInt32Array(a_New_data["unlocks"])
	for index in temp_unlocks:
		if index in gear_data["unlocks"]:
			continue
		
		grid_array[index].unlock()
		gear_data["unlocks"].push_back(index)
		incrememnt_lock_tally.emit(1)
	
	for grid in a_New_data["internals"]:
		print("installing " + a_New_data["internals"][grid])
		install_item(a_New_data["internals"][grid], int(grid))

func install_item(a_Item_ID, a_Index):
	if !DataHandler.item_data.has(a_Item_ID):
		return
	
	icon_anchor = Vector2(10000, 10000)
	var column_count = grid_array[a_Index].get_parent().columns
	var new_item = item_scene.instantiate()
	grid_array[a_Index].get_parent().add_child(new_item)
	new_item.load_item(a_Item_ID.to_snake_case())
	
	new_item.grid_anchor = grid_array[a_Index]
	
	for grid in new_item.item_grids:
		if grid[1] < icon_anchor.x: icon_anchor.x = grid[1]
		if grid[0] < icon_anchor.y: icon_anchor.y = grid[0]
		var grid_to_check = a_Index + grid[0] + grid[1] * column_count
		grid_array[a_Index].state = grid_array[grid_to_check].States.TAKEN
		grid_array[a_Index].installed_item = new_item
	
	var calculated_grid_id = a_Index + icon_anchor.x * column_count + icon_anchor.y
	new_item.snap_to(grid_array[calculated_grid_id].global_position)
	internals[a_Index] = new_item
	item_installed.emit(new_item)

func _on_unlock_toggle_button_down():
	if item_held:
		drop_item()
	
	if mode == Modes.UNLOCK:
		clear_grid()
		mode = Modes.EQUIP
	else:
		mode = Modes.UNLOCK
		for grid in grid_array:
			if default_unlocks.has(grid.slot_ID):
				grid.set_color(grid.States.TAKEN)

func _on_background_selector_load_background(a_Background_data):
	current_background = a_Background_data["background"].to_snake_case()
	custom_background.clear()

func _on_background_edit_menu_background_stat_updated(stat, _value, was_added):
	if was_added:
		custom_background.append(stat)
	else:
		custom_background.erase(stat)

func _on_export_popup_export_requested(filename: String) -> void:
	var path = "user://Saves/" + filename + ".fsh"
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	file.store_string(get_user_data_string())
	file.close()
	
	var folder_path
	if OS.has_feature("editor"):
		folder_path = ProjectSettings.globalize_path("user://Saves")
	else:
		folder_path = OS.get_user_data_dir().path_join("Saves")
	OS.shell_show_in_file_manager(folder_path, true)

func get_user_data_string():
	for grid in internals.keys():
		gear_data["internals"][str(grid)] = internals[grid].item_data["name"].to_snake_case()
	
	gear_data["frame"] = current_frame
	gear_data["background"] = current_background
	gear_data["callsign"] = callsign_line_edit.text
	gear_data["custom_background"] = custom_background
	gear_data["developments"] = developments_container.current_developments
	gear_data["maneuvers"] = maneuvers_container.current_maneuvers
	gear_data["deep_words"] = deep_words_container.current_deep_words
	
	return str(gear_data).replace("\\", "")









func _on_internals_reset_confirm_dialog_confirmed():
	internals_reset()

func _on_save_options_menu_new_gear_pressed():
	get_tree().reload_current_scene()
	#for grid in grid_array:
	#	grid.lock()
	#for index in default_unlocks:
	#	grid_array[index].unlock()
	#emit_signal("reset_lock_tally")
	
	#internals_reset()
	#gear_data = DataHandler.get_gear_template()

func _on_frame_selector_load_frame(a_Frame_data, a_Frame_name):
	set_gear_ability.emit(a_Frame_data)
	default_unlocks = PackedInt32Array(a_Frame_data["default_unlocks"])
	current_frame = a_Frame_name
	
	for grid in grid_array:
		grid.lock()
	for index in default_unlocks:
		grid_array[index].unlock()
	gear_data["unlocks"].clear()
	reset_lock_tally.emit()
	
	internals_reset()

func _on_hardpoints_reset_confirm_dialog_confirmed():
	for grid in grid_array:
		grid.lock()
	for index in default_unlocks:
		grid_array[index].unlock()
	reset_lock_tally.emit()
	
	internals_reset()
	gear_data["unlocks"].clear()

func internals_reset():
	for slot in internals:
		for grid in internals[slot].item_grids:
			var grid_to_check = slot + grid[0] + grid[1] * grid_array[slot].get_parent().columns
			grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
			grid_array[grid_to_check].installed_item = null
		item_removed.emit(internals[slot])
		internals[slot].queue_free()
	internals.clear()

#endregion















# seems like a lot of the stuff below this line should be in the reactive section, hmmm








