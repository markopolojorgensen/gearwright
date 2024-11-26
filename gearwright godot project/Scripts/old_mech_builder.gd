extends ColorRect

# @onready var slot_scene = preload("res://Scenes/grid_slot.tscn")
# @onready var item_scene = preload("res://Scenes/item.tscn")

#@onready var head_container = $ColorRect/MarginContainer/ColorRect2/ContainerContainer/HeadContainer
#@onready var chest_container = $ColorRect/MarginContainer/ColorRect2/ContainerContainer/ChestContainer
#@onready var l_arm_container = $ColorRect/MarginContainer/ColorRect2/ContainerContainer/LeftArmContainer
#@onready var r_arm_container = $ColorRect/MarginContainer/ColorRect2/ContainerContainer/RightArmContainer
#@onready var leg_container = $ColorRect/MarginContainer/ColorRect2/ContainerContainer/LegContainer
#@onready var containers = [chest_container, l_arm_container, r_arm_container, head_container, leg_container]

# @onready var stats = $"../VBoxContainer/Stats/StatsList"
# @onready var callsign_input = $ColorRect/MarginContainer/ColorRect2/CallsignInputContainer/CallsignInput
# @onready var export_popup = $MenuHeader/SaveOptionsMenu/ExportPopup
#@onready var screenshot_popup = $MenuHeader/SaveOptionsMenu/ScreenshotPopup
#@onready var file_dialog = $MenuHeader/SaveOptionsMenu/FileDialog
#@onready var save_menu = $MenuHeader/SaveOptionsMenu
#var save_menu_popup

#@onready var developments_container = $ColorRect/MarginContainer/ColorRect2/DevelopmentsContainer
#@onready var maneuvers_container = $ColorRect/MarginContainer/ColorRect2/ManeuversContainer
#@onready var deep_words_container = $ColorRect/MarginContainer/ColorRect2/DeepWordsContainer

#var grid_array := []
#var item_held = null
#var current_slot = null
#var can_place := false
#var can_lock := false
# var icon_anchor : Vector2
#enum Modes {EQUIP, PLACE, UNLOCK}
#var mode = Modes.EQUIP

#signal item_installed(item)
#signal item_removed(item)

#var default_unlocks := []
#signal incrememnt_lock_tally(change)
#signal reset_lock_tally
#signal set_gear_ability(frame_data)
#signal new_save_loaded(user_data)

#var gear_data = DataHandler.get_gear_template()
#var internals := {}
#var custom_background := []
#var current_frame := ""
#var current_background := ""

# Called when the node enters the scene tree for the first time.
#func _ready():
	# save_menu_popup = save_menu.get_popup()
	#
	#for container in containers:
		#for i in container.capacity:
			#create_slot(container)

#func _process(_delta):
	#if Input.is_action_just_pressed("mouse_leftclick"):
		#if export_popup.visible or file_dialog.visible or screenshot_popup.visible or save_menu_popup.visible:
			#return
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
	#elif Input.is_action_just_pressed("mouse_rightclick"):
		#match mode:
			#Modes.PLACE:
				#drop_item()

#func create_slot(container):
	#var new_slot = slot_scene.instantiate()
	#new_slot.slot_ID = grid_array.size()
	#container.add_child(new_slot)
	#grid_array.push_back(new_slot)
	#new_slot.slot_entered.connect(_on_slot_mouse_entered)
	#new_slot.slot_exited.connect(_on_slot_mouse_exited)

#func _on_slot_mouse_entered(a_Slot):
	#icon_anchor = Vector2(10000, 10000)
	#current_slot = a_Slot
	#if item_held:
		#check_slot_availability(current_slot)
		#set_grids.call_deferred(current_slot)
	#if mode == Modes.UNLOCK:
		#check_lock_availability(current_slot)
		#set_lock_grids.call_deferred(current_slot)
#
#func _on_slot_mouse_exited():
	#if mode == Modes.UNLOCK:
		#current_slot.set_color(current_slot.States.TAKEN)
		#for grid in grid_array:
			#if not default_unlocks.has(grid.slot_ID):
				#grid.set_color(grid.States.DEFAULT)
	#else:
		#clear_grid()

#func check_lock_availability(a_Slot):
	#if not a_Slot.locked and default_unlocks.has(a_Slot.slot_ID):
		#can_lock = false
		#return
	#if a_Slot.installed_item:
		#can_lock = false
		#return
	#if a_Slot.locked and not stats.unlocks_remaining():
		#can_lock = false
		#return
	#can_lock = true

#func check_slot_availability(a_Slot):
	#var column_count = a_Slot.get_parent().columns
	#for grid in item_held.item_grids:
		#var grid_to_check = a_Slot.slot_ID + grid[0] + grid[1] * column_count
		#var line_switch_check = a_Slot.slot_ID % column_count + grid[0]
		#if line_switch_check < 0 or line_switch_check >= column_count:
			#can_place = false
			#return
		#if grid_to_check < 0 or grid_to_check >= grid_array.size():
			#can_place = false
			#return
		#if grid_array[grid_to_check].state == grid_array[grid_to_check].States.TAKEN or grid_array[grid_to_check].locked:
			#can_place = false
			#return
		#if grid_array[grid_to_check].get_parent() != current_slot.get_parent():
			#can_place = false
			#return
		#if item_held.item_data["section"] != "any" and !grid_array[grid_to_check].get_parent().get_name().ends_with(item_held.item_data["section"].capitalize() + "Container"):
			#can_place = false
			#return
		#if not stats.is_under_weight_limit(item_held.item_data):
			#can_place = false
			#return
		#can_place = true

#func set_lock_grids(a_Slot):
	#if can_lock:
		#grid_array[a_Slot.slot_ID].set_color(grid_array[a_Slot.slot_ID].States.FREE)
	#else: 
		#grid_array[a_Slot.slot_ID].set_color(grid_array[a_Slot.slot_ID].States.TAKEN)



#func clear_grid():
	#for grid in grid_array:
		#grid.set_color(grid.States.DEFAULT)

#func place_item():
	#if not can_place or not current_slot:
		#return
	#
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
	#emit_signal("item_installed", item_held)
	#internals[current_slot.slot_ID] = item_held
	#
	#item_held = null
	#mode = Modes.EQUIP
	#stats.update_weight_label_effect(null)
	#clear_grid()

#func pickup_item():
	#if not current_slot or not current_slot.installed_item:
		#return
	#
	#var column_count = current_slot.get_parent().columns
	#item_held = current_slot.installed_item
	#item_held.selected = true
	#
	#for grid in item_held.item_grids:
		#var grid_to_check = item_held.grid_anchor.slot_ID + grid[0] + grid[1] * column_count
		#grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
		#grid_array[grid_to_check].installed_item = null
		#internals.erase(grid_to_check)
	#
	#emit_signal("item_removed", item_held)
	#stats.update_weight_label_effect(item_held.item_data)
	#
	#check_slot_availability(current_slot)
	#set_grids.call_deferred(current_slot)
	#
	#mode = Modes.PLACE

#func drop_item():
	#if not item_held:
		#return
	#item_held.queue_free()
	#item_held = null
	#mode = Modes.EQUIP
	#stats.update_weight_label_effect(null)

#func toggle_locked():
	#if not current_slot or not can_lock:
		#return
	#
	#if current_slot.locked:
		#current_slot.unlock()
		#gear_data["unlocks"].push_back(current_slot.slot_ID)
		#emit_signal("incrememnt_lock_tally", 1)
	#else:
		#if !current_slot.installed_item:
			#current_slot.lock()
			#gear_data["unlocks"].erase(current_slot.slot_ID)
			#emit_signal("incrememnt_lock_tally", -1)
	#
	#check_lock_availability(current_slot)
	#set_lock_grids.call_deferred(current_slot)






































#func _on_frame_selector_load_frame(a_Frame_data, a_Frame_name):
	#emit_signal("set_gear_ability", a_Frame_data)
	#default_unlocks = PackedInt32Array(a_Frame_data["default_unlocks"])
	#current_frame = a_Frame_name
	#
	#for grid in grid_array:
		#grid.lock()
	#for index in default_unlocks:
		#grid_array[index].unlock()
	#gear_data["unlocks"].clear()
	#emit_signal("reset_lock_tally")
	#
	#internals_reset()
#
#func _on_unlock_toggle_button_down():
	#if item_held:
		#drop_item()
	#
	#if mode == Modes.UNLOCK:
		#clear_grid()
		#mode = Modes.EQUIP
	#else:
		#mode = Modes.UNLOCK
		#for grid in grid_array:
			#if default_unlocks.has(grid.slot_ID):
				#grid.set_color(grid.States.TAKEN)
#
#
#
#func install_item(a_Item_ID, a_Index):
	#if !DataHandler.item_data.has(a_Item_ID):
		#return
	#
	#icon_anchor = Vector2(10000, 10000)
	#var column_count = grid_array[a_Index].get_parent().columns
	#var new_item = item_scene.instantiate()
	#grid_array[a_Index].get_parent().add_child(new_item)
	#new_item.load_item(a_Item_ID.to_snake_case())
	#
	#new_item.grid_anchor = grid_array[a_Index]
	#
	#for grid in new_item.item_grids:
		#if grid[1] < icon_anchor.x: icon_anchor.x = grid[1]
		#if grid[0] < icon_anchor.y: icon_anchor.y = grid[0]
		#var grid_to_check = a_Index + grid[0] + grid[1] * column_count
		#grid_array[a_Index].state = grid_array[grid_to_check].States.TAKEN
		#grid_array[a_Index].installed_item = new_item
	#
	#var calculated_grid_id = a_Index + icon_anchor.x * column_count + icon_anchor.y
	#new_item.snap_to(grid_array[calculated_grid_id].global_position)
	#internals[a_Index] = new_item
	#emit_signal("item_installed", new_item)
#
#func internals_reset():
	#for slot in internals:
		#for grid in internals[slot].item_grids:
			#var grid_to_check = slot + grid[0] + grid[1] * grid_array[slot].get_parent().columns
			#grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
			#grid_array[grid_to_check].installed_item = null
		#emit_signal("item_removed", internals[slot])
		#internals[slot].queue_free()
	#internals.clear()
#
#func _on_save_options_menu_new_gear_pressed():
	#get_tree().reload_current_scene()
	##for grid in grid_array:
	##	grid.lock()
	##for index in default_unlocks:
	##	grid_array[index].unlock()
	##emit_signal("reset_lock_tally")
	#
	##internals_reset()
	##gear_data = DataHandler.get_gear_template()
#
#func get_user_data_string():
	#for grid in internals.keys():
		#gear_data["internals"][str(grid)] = internals[grid].item_data["name"].to_snake_case()
	#
	#gear_data["frame"] = current_frame
	#gear_data["background"] = current_background
	#gear_data["callsign"] = callsign_input.text
	#gear_data["custom_background"] = custom_background
	#gear_data["developments"] = developments_container.current_developments
	#gear_data["maneuvers"] = maneuvers_container.current_maneuvers
	#gear_data["deep_words"] = deep_words_container.current_deep_words
	#
	#return str(gear_data).replace("\\", "")
#
#func _on_level_selector_change_level(_a_Level_data, a_Level):
	#gear_data["level"] = a_Level
#
#func _on_save_options_menu_load_save_data(a_New_data):
	#drop_item()
	#gear_data = DataHandler.get_gear_template()
	#
	#emit_signal("new_save_loaded", a_New_data)
	#
	#var temp_unlocks = PackedInt32Array(a_New_data["unlocks"])
	#for index in temp_unlocks:
		#if index in gear_data["unlocks"]:
			#continue
		#
		#grid_array[index].unlock()
		#gear_data["unlocks"].push_back(index)
		#emit_signal("incrememnt_lock_tally", 1)
	#
	#for grid in a_New_data["internals"]:
		#print("installing " + a_New_data["internals"][grid])
		#install_item(a_New_data["internals"][grid], int(grid))
#
#func _on_background_selector_load_background(a_Background_data):
	#current_background = a_Background_data["background"].to_snake_case()
	#custom_background.clear()
#
#func _on_internals_reset_confirm_dialog_confirmed():
	#internals_reset()
#
#func _on_hardpoints_reset_confirm_dialog_confirmed():
	#for grid in grid_array:
		#grid.lock()
	#for index in default_unlocks:
		#grid_array[index].unlock()
	#emit_signal("reset_lock_tally")
	#
	#internals_reset()
	#gear_data["unlocks"].clear()
#
#func _on_background_edit_menu_background_stat_updated(stat, _value, was_added):
	#if was_added:
		#custom_background.append(stat)
	#else:
		#custom_background.erase(stat)
