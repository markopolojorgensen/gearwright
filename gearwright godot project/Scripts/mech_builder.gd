extends Control

const item_scene = preload("res://Scenes/item.tscn")
# const slot_scene = preload("res://Scenes/grid_slot.tscn")

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


#@onready var containers = [
	#%ChestContainer,
	#%LeftArmContainer,
	#%RightArmContainer,
	#%HeadContainer,
	#%LegContainer,
#]

enum gear_section_ids {
	TORSO,
	LEFT_ARM,
	RIGHT_ARM,
	HEAD,
	LEGS,
}
func gear_section_id_to_name(id: int) -> String:
	match id:
		gear_section_ids.TORSO:
			return "torso"
		gear_section_ids.LEFT_ARM:
			return "left_arm"
		gear_section_ids.RIGHT_ARM:
			return "right_arm"
		gear_section_ids.HEAD:
			return "head"
		gear_section_ids.LEGS:
			return "legs"
		_:
			return "unknown gear section id: %d" % id

var gear_sections: Dictionary = create_gear_sections()

@onready var gear_section_controls = {
	gear_section_ids.HEAD:      %HeadGearSectionControl,
	gear_section_ids.TORSO:     %TorsoGearSectionControl,
	gear_section_ids.LEFT_ARM:  %LeftArmGearSectionControl,
	gear_section_ids.RIGHT_ARM: %RightArmGearSectionControl,
	gear_section_ids.LEGS:      %LegsGearSectionControl,
}

var grid_array := [] # TODO yeet this
enum Modes {EQUIP, PLACE, UNLOCK}
var mode = Modes.EQUIP
var item_held
#var current_slot

# keys: gear_section, gear_section_control, grid_slot, grid_slot_control, x, y
var current_slot_info: Dictionary
var icon_anchor: Vector2

var default_unlocks := []

var gear_data = DataHandler.get_gear_template()
var internals := {}
var current_frame := ""
var current_background := ""
var custom_background := []




#region initialization

func _ready():
	for gear_section_id in gear_section_ids.values():
		#print(gear_section_id)
		#print(typeof(gear_section_id))
		#print(gear_section_id_to_name(gear_section_id))
		#print(str(gear_section_controls[gear_section_id]))
		#print(str(gear_sections[gear_section_id]))
		gear_section_controls[gear_section_id].initialize(gear_sections[gear_section_id])
	
	#item_inventory_container.item_spawned.connect(_on_item_inventory_item_spawned)
	#for container in containers:
		#for i in container.capacity:
			#create_slot(container)

#func create_slot(container):
	#var new_slot = slot_scene.instantiate()
	#new_slot.slot_ID = grid_array.size()
	#container.add_child(new_slot)
	#grid_array.push_back(new_slot)
	#new_slot.slot_entered.connect(_on_slot_mouse_entered)
	#new_slot.slot_exited.connect(_on_slot_mouse_exited)

func create_gear_sections() -> Dictionary:
	var result := {
		gear_section_ids.TORSO:     GearSection.new(Vector2i(6, 6)),
		gear_section_ids.LEFT_ARM:  GearSection.new(Vector2i(6, 3)),
		gear_section_ids.RIGHT_ARM: GearSection.new(Vector2i(6, 3)),
		gear_section_ids.HEAD:      GearSection.new(Vector2i(3, 3)),
		gear_section_ids.LEGS:      GearSection.new(Vector2i(3, 6)),
	}
	result[gear_section_ids.TORSO].name = "Torso"
	result[gear_section_ids.TORSO].dice_string = "(6-8)"
	
	result[gear_section_ids.LEFT_ARM].name = "Left Arm"
	result[gear_section_ids.LEFT_ARM].dice_string = "(4-5)"
	
	result[gear_section_ids.RIGHT_ARM].name = "Right Arm"
	result[gear_section_ids.RIGHT_ARM].dice_string = "(9-10)"
	
	result[gear_section_ids.HEAD].name = "Head"
	result[gear_section_ids.HEAD].dice_string = "(2-3)"
	
	result[gear_section_ids.LEGS].name = "Legs"
	result[gear_section_ids.LEGS].dice_string = "(11-12)"
	
	return result

#endregion





func _process(_delta):
	if Input.is_action_just_pressed("mouse_leftclick"):
		if export_popup.visible or file_dialog.visible or screenshot_popup.visible or save_menu_popup.visible:
			return
		# FIXME make sure functionality works w/ new control signals
		#match mode:
			#Modes.EQUIP:
				#for container in containers:
					#if container.get_global_rect().has_point(get_global_mouse_position()):
						#pickup_item()
			#Modes.PLACE:
				#for container in containers:
					#if container.get_global_rect().has_point(get_global_mouse_position()):
						#place_item()
			#Modes.UNLOCK:
				#for container in containers:
					#if container.get_global_rect().has_point(get_global_mouse_position()):
						#toggle_locked()
	elif Input.is_action_just_pressed("mouse_rightclick"):
		match mode:
			Modes.PLACE:
				drop_item()

func pickup_item():
	#if not current_slot or not current_slot.installed_item:
		#return
	if current_slot_info.is_empty():
		return
	var current_gear_section: GearSection = current_slot_info.gear_section as GearSection
	var current_grid_slot: GridSlot = current_slot_info.grid_slot as GridSlot
	if not current_grid_slot.installed_item:
		return
	
	#var column_count = current_slot.get_parent().columns
	#item_held = current_slot.installed_item
	item_held = current_grid_slot.installed_item
	item_held.selected = true
	
	# FIXME erased functionality?
	#for grid in item_held.item_grids:
		#var grid_to_check = item_held.grid_anchor.slot_ID + grid[0] + grid[1] * column_count
		#grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
		#grid_array[grid_to_check].installed_item = null
		#internals.erase(grid_to_check)
	
	item_removed.emit(item_held)
	stats_container.update_weight_label_effect(item_held.item_data)
	
	#if is_slot_open(current_slot):
		#set_grids.call_deferred(current_slot)
	
	mode = Modes.PLACE

func place_item():
	# all the reasons we can't put the held item in the current slot:
	#   there is no held item
	#   there is no current slot
	#   it would put us over weight
	#   wrong section (e.g. trying to put head gear in leg)
	#   for each slot that would become occupied:
	#     there's already something there
	#     slot is out of bounds
	#     slot is locked
	
	# there is no held item
	item_held # TODO
	
	# there is no current slot
	if current_slot_info.is_empty():
		return
	
	# it would put us over weight
	#if get_total_equipped_weight() + item_held # TODO
	
	var current_gear_section: GearSection = current_slot_info.gear_section as GearSection
	var current_grid_slot: GridSlot = current_slot_info.grid_slot as GridSlot
	
	#   wrong section (e.g. trying to put head gear in leg)
	#   for each slot that would become occupied:
	#     there's already something there
	#     slot is out of bounds
	#     slot is locked
	
	# TODO maybe uncomment?
	#var column_count = current_slot.get_parent().columns
	#var calculated_grid_id = current_slot.slot_ID + icon_anchor.x * column_count + icon_anchor.y
	#if calculated_grid_id >= grid_array.size():
		#return
	#
	#item_held.get_parent().remove_child(item_held)
	#current_slot.get_parent().add_child(item_held)
	#item_held.global_position = get_global_mouse_position()
	#
	#item_held.snap_to(grid_array[calculated_grid_id].global_position)
	#
	#item_held.grid_anchor = current_slot
	#for grid in item_held.item_grids:
		#var grid_to_check = current_slot.slot_ID + grid[0] + grid[1] * column_count
		#grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN
		#grid_array[grid_to_check].installed_item = item_held
	#
	#item_installed.emit(item_held)
	#internals[current_slot.slot_ID] = item_held
	#
	#item_held = null
	#mode = Modes.EQUIP
	#stats_container.update_weight_label_effect(null)
	#clear_grid()

func toggle_locked():
	pass
	# TODO maybe uncomment?
	#if not current_slot or not is_lock_toggleable(current_slot):
		#return
	#
	#if current_slot.locked:
		#current_slot.unlock()
		#gear_data["unlocks"].push_back(current_slot.slot_ID)
		#incrememnt_lock_tally.emit(1)
		#
	#else:
		#if !current_slot.installed_item:
			#current_slot.lock()
			#gear_data["unlocks"].erase(current_slot.slot_ID)
			#incrememnt_lock_tally.emit(-1)
	#
	#if is_lock_toggleable(current_slot):
		#set_lock_grids.call_deferred(current_slot)

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
#func is_slot_open(slot_info: Dictionary):
	#var column_count = slot.get_parent().columns
	#for grid in item_held.item_grids:
		#var grid_to_check = slot.slot_ID + grid[0] + grid[1] * column_count
		#var line_switch_check = slot.slot_ID % column_count + grid[0]
		#if line_switch_check < 0 or line_switch_check >= column_count:
			#return false
		#if grid_to_check < 0 or grid_to_check >= grid_array.size():
			#return false
		#if grid_array[grid_to_check].state == grid_array[grid_to_check].States.TAKEN or grid_array[grid_to_check].locked:
			#return false
		#if grid_array[grid_to_check].get_parent() != current_slot.get_parent():
			#return false
		#if item_held.item_data["section"] != "any" and !grid_array[grid_to_check].get_parent().get_name().ends_with(item_held.item_data["section"].capitalize() + "Container"):
			#return false
		#if not stats_container.is_under_weight_limit(item_held.item_data):
			#return false
	#
	#return true

func set_grids(slot):
	pass
	# TODO maybe uncomment?
	#var column_count = slot.get_parent().columns
	#for grid in item_held.item_grids:
		#var grid_to_check = slot.slot_ID + grid[0] + grid[1] * column_count
		#var line_switch_check = slot.slot_ID % column_count + grid[0]
		#if line_switch_check < 0 or line_switch_check >= column_count:
			#continue
		#if grid_to_check < 0 or grid_to_check >= grid_array.size():
			#continue
		#if grid_array[grid_to_check].get_parent() != current_slot.get_parent():
			#continue
		#if is_slot_open(slot):
			#grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.FREE)
			#
			#if grid[1] < icon_anchor.x:
				#icon_anchor.x = grid[1]
			#if grid[0] < icon_anchor.y:
				#icon_anchor.y = grid[0]
		#else:
			#grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.TAKEN)

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










#region Reactivity

# Grid Slots

func _on_slot_mouse_entered(slot_info: Dictionary):
	icon_anchor = Vector2(10000, 10000)
	#current_slot = a_Slot
	current_slot_info = slot_info
	update_gear_section_controls()
	
	#if item_held:
		#if is_slot_open(current_slot):
			#set_grids.call_deferred(current_slot)
	#if mode == Modes.UNLOCK:
		#if is_slot_open(current_slot):
			#set_lock_grids.call_deferred(current_slot)

func _on_slot_mouse_exited(slot_info: Dictionary):
	if slot_info == current_slot_info:
		current_slot_info = {}
	update_gear_section_controls()
	#if mode == Modes.UNLOCK:
		#current_slot.set_color(current_slot.States.TAKEN)
		#for grid in grid_array:
			#if not default_unlocks.has(grid.slot_ID):
				#grid.set_color(grid.States.DEFAULT)
	#else:
		#clear_grid()

# entered
func _on_head_gear_section_control_slot_entered(slot_info: Dictionary) -> void:
	_on_slot_mouse_entered(slot_info)

func _on_chest_gear_section_control_slot_entered(slot_info: Dictionary) -> void:
	_on_slot_mouse_entered(slot_info)

func _on_left_arm_gear_section_control_slot_entered(slot_info: Dictionary) -> void:
	_on_slot_mouse_entered(slot_info)

func _on_right_arm_gear_section_control_slot_entered(slot_info: Dictionary) -> void:
	_on_slot_mouse_entered(slot_info)

func _on_legs_gear_section_control_slot_entered(slot_info: Dictionary) -> void:
	_on_slot_mouse_entered(slot_info)

# exited
func _on_head_gear_section_control_slot_exited(slot_info: Dictionary) -> void:
	_on_slot_mouse_exited(slot_info)

func _on_chest_gear_section_control_slot_exited(slot_info: Dictionary) -> void:
	_on_slot_mouse_exited(slot_info)

func _on_left_arm_gear_section_control_slot_exited(slot_info: Dictionary) -> void:
	_on_slot_mouse_exited(slot_info)

func _on_right_arm_gear_section_control_slot_exited(slot_info: Dictionary) -> void:
	_on_slot_mouse_exited(slot_info)

func _on_legs_gear_section_control_slot_exited(slot_info: Dictionary) -> void:
	_on_slot_mouse_exited(slot_info)





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
	
	gear_sections = create_gear_sections()
	update_gear_section_controls()
	# TODO there may be some bugs here about not clearing references to old sections/slots/controls
	
	for index in default_unlocks:
		#grid_array[index].unlock()
		var info := grid_array_index_to_gear_section_coords(index)
		var gear_section: GearSection = info.gear_section as GearSection
		var grid_slot: GridSlot = gear_section.grid.get_contents(info.x, info.y)
		grid_slot.locked = false
	
	gear_data["unlocks"].clear()
	reset_lock_tally.emit()
	
	internals_reset()

# returns dictionary with keys gear_section_id, gear_section, x, y
func grid_array_index_to_gear_section_coords(index: int) -> Dictionary:
	assert(0 <= index)
	var result := {}
	var adjusted_index = -1
	if index < 36:
		adjusted_index = index
		result.gear_section_id = gear_section_ids.TORSO
	elif index < 54:
		adjusted_index = index - 36
		result.gear_section_id = gear_section_ids.LEFT_ARM
	elif index < 72:
		adjusted_index = index - 54
		result.gear_section_id = gear_section_ids.RIGHT_ARM
	elif index < 81:
		adjusted_index = index - 72
		result.gear_section_id = gear_section_ids.HEAD
	elif index < 99:
		adjusted_index = index - 81
		result.gear_section_id = gear_section_ids.LEGS
	else:
		push_error("grid array index out of bounds: %d" % index)
		breakpoint
	
	var gear_section: GearSection = gear_sections[result.gear_section_id]
	result.gear_section = gear_section
	var x: int = adjusted_index % gear_section.grid.size.x
	@warning_ignore("integer_division")
	var y: int = adjusted_index / gear_section.grid.size.x
	result.x = x
	result.y = y
	assert(0 <= result.x)
	assert(0 <= result.y)
	assert(result.x < gear_section.grid.size.x)
	assert(result.y < gear_section.grid.size.y)
	return result



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







#region Rendering

func update_gear_section_controls():
	for gear_section_control in gear_section_controls.values():
		gear_section_control.update()
	
	if current_slot_info.is_empty():
		return
	
	# TODO update current slot!
	push_warning("update current slot..?")




#endregion







#region Data Interrogation
# functions that look at model side of things: GearSections, GridSlots, etc.

func get_total_equipped_weight():
	var sections := gear_sections.values()
	var sum := 0
	for i in range(sections.size()):
		var gear_section: GearSection = sections[i]
		sum += gear_section.get_total_equipped_weight()
	return sum

#endregion









