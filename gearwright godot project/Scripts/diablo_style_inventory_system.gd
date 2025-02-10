extends Node2D
class_name DiabloStyleInventorySystem

# interacts with PartMenu, GearSectionControl, and their subcontrols.

@export var is_fish_mode := false

signal something_changed

const item_scene = preload("res://Scenes/item.tscn")

enum Modes {
	EQUIP,
	PLACE,
	UNLOCK,
}
var mode = Modes.EQUIP
var item_held

# keys:
#   gear_section_id
#   x
#   y
var current_slot_info: Dictionary
# can't assign null to these, so use current_slot_info.is_empty()
#   to find out if a slot is currently being hovered
var current_gear_section: GearSection
var current_gear_section_control: GearSectionControl
var current_grid_slot: GridSlot
var current_grid_slot_control: GridSlotControl

var control_scale: float = 1.0


func get_mode() -> String:
	return Modes.find_key(mode)









#region Leftclick Rightclick

func leftclick(character):
	match mode:
		Modes.EQUIP:
			pickup_item(character)
			#for container in containers:
				#if container.get_global_rect().has_point(get_global_mouse_position()):
					#pickup_item()
		Modes.PLACE:
			place_item(character)
			#for container in containers:
				#if container.get_global_rect().has_point(get_global_mouse_position()):
					#place_item()
		Modes.UNLOCK:
			toggle_current_slot_lock(character)
			#for container in containers:
				#if container.get_global_rect().has_point(get_global_mouse_position()):
					#toggle_locked()

func rightclick(_character):
	match mode:
		Modes.PLACE:
			drop_item()


func pickup_item(actor: GearwrightActor):
	#if not current_slot or not current_slot.installed_item:
		#return
	if current_slot_info.is_empty():
		return
	if not current_grid_slot.installed_item:
		return
	
	#var column_count = current_slot.get_parent().columns
	#item_held = current_slot.installed_item
	item_held = current_grid_slot.installed_item
	item_held.grid_anchor = null
	item_held.selected = true
	item_held.hide_legend_number()
	
	actor.unequip_internal(item_held, current_slot_info.gear_section_id)
	
	#item_removed.emit(item_held) # TODO yeet this maybe?
	#stats_container.update_weight_label_effect(item_held.item_data)
	
	#if is_slot_open(current_slot):
		#set_grids.call_deferred(current_slot)
	
	mode = Modes.PLACE
	
	something_changed.emit()
	#request_update_controls = true

func place_item(actor: GearwrightActor):
	if current_slot_info.is_empty():
		return
	
	# equip_internal does all these checks
	#if not character.is_valid_internal_equip(
			#item_held,
			#current_slot_info.gear_section_id,
			#Vector2i(current_slot_info.x, current_slot_info.y)
	#):
		#return
	
	var current_slot_cell := Vector2i(current_slot_info.x, current_slot_info.y)
	var errors := actor.equip_internal(
			item_held,
			current_slot_info.gear_section_id,
			current_slot_cell
	)
	if not errors.is_empty():
		global_util.rising_text(errors.reduce(func(accum: String, current: String):
			if accum.is_empty():
				return current
			else:
				return accum + "\n" + current
			, ""), get_global_mouse_position())
		return
	
	#var column_count = current_slot.get_parent().columns
	#var calculated_grid_id = current_slot.slot_ID + icon_anchor.x * column_count + icon_anchor.y
	#if calculated_grid_id >= grid_array.size():
		#return
	
	#var item_cells := current_character.get_item_cells(
			#item_held,
			#current_slot_info.gear_section_id,
			#current_slot_cell
	#)
	#var top_left_cell = item_cells.reduce(func(best: Vector2i, current: Vector2i):
		#best.x = min(best.x, current.x)
		#best.y = min(best.y, current.y)
		#return best
		#, Vector2i(1000, 1000))
	#var anchor_grid_slot_control: GridSlotControl = current_gear_section_control.control_grid.get_contents_v(top_left_cell)
	
	#item_held.get_parent().remove_child(item_held) # TODO maybe we need this?
	#anchor_grid_slot_control.get_parent().add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	
	#item_held.snap_to(grid_array[calculated_grid_id].global_position)
	#item_held.snap_to(anchor_grid_slot_control.global_position)
	
	#item_held.grid_anchor = current_slot
	#for grid in item_held.item_grids:
		#var grid_to_check = current_slot.slot_ID + grid[0] + grid[1] * column_count
		#grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN
		#grid_array[grid_to_check].installed_item = item_held
	#item_held.grid_anchor = anchor_grid_slot_control
	#for cell in item_cells:
		#if not current_gear_section.grid.is_within_size_v(cell):
			#continue
		#
		#var grid_slot: GridSlot = current_gear_section.grid.get_contents_v(cell)
		#assert(not grid_slot.is_locked)
		#assert(grid_slot.installed_item == null)
		#grid_slot.installed_item = item_held
	#current_grid_slot.is_primary_install_point = true
	
	#item_installed.emit(item_held) # TODO yeet?
	#internals[current_slot.slot_ID] = item_held
	
	item_held = null
	mode = Modes.EQUIP
	#stats_container.update_weight_label_effect(null)
	#clear_grid()
	
	#request_update_controls = true
	something_changed.emit()

func toggle_current_slot_lock(character):
	if current_slot_info.is_empty():
		return
	
	character.toggle_unlock(
			current_slot_info.gear_section_id,
			current_slot_info.x,
			current_slot_info.y
	)
	
	## slot is a default unlock
	#if current_grid_slot.is_default_unlock:
		#return
	## slot has something in it
	#if current_grid_slot.installed_item != null:
		#return
	#
	## locked, but no unlocks left
	## allow player to re-lock non-default unlocked slots
	## allow player to unlock non-default locked slots when they have unlocks left
	#if (current_grid_slot.is_locked) and (not current_character.has_unlocks_remaining()):
		#return
	#
	#current_grid_slot.is_locked = not current_grid_slot.is_locked
	#gear_data["unlocks"] = get_unlocked_slots()
	
	#request_update_controls = true
	something_changed.emit()
	
	
	#if not current_slot or not is_lock_toggleable(current_slot):
		#return
	#
	#if current_slot.is_locked:
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
	#request_update_controls = true
	something_changed.emit()

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
		#if grid_array[grid_to_check].state == grid_array[grid_to_check].States.TAKEN or grid_array[grid_to_check].is_locked:
			#return false
		#if grid_array[grid_to_check].get_parent() != current_slot.get_parent():
			#return false
		#if item_held.item_data["section"] != "any" and !grid_array[grid_to_check].get_parent().get_name().ends_with(item_held.item_data["section"].capitalize() + "Container"):
			#return false
		#if not stats_container.is_under_weight_limit(item_held.item_data):
			#return false
	#
	#return true

#func set_grids(slot):
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

#func clear_grid():
	#for grid in grid_array:
		#grid.set_color(grid.States.DEFAULT)

# used to be check_lock_availability, modified can_lock
#func is_lock_toggleable(slot):
	#if not slot.is_locked and default_unlocks.has(slot.slot_ID):
		#return false
	#if slot.installed_item:
		#return false
	#if slot.is_locked and not stats_container.unlocks_remaining():
		#return false
	#return true

#func set_lock_grids(slot):
	#if is_lock_toggleable(slot):
		#grid_array[slot.slot_ID].set_color(grid_array[slot.slot_ID].States.FREE)
	#else: 
		#grid_array[slot.slot_ID].set_color(grid_array[slot.slot_ID].States.TAKEN)

#endregion






#region Mutation

func toggle_unlock_mode():
	if item_held:
		drop_item()
	
	if mode == Modes.UNLOCK:
		#clear_grid()
		mode = Modes.EQUIP
	else:
		mode = Modes.UNLOCK
		#for grid in grid_array:
			#if default_unlocks.has(grid.slot_ID):
				#grid.set_color(grid.States.TAKEN)

#endregion







#region Rendering

func fancy_update(character, gear_section_controls: Dictionary):
	# updates controls on data from gear_section / grid_slot
	# also clears all highlights / filters
	for gear_section_id in gear_section_controls.keys():
		if not character.has_gear_section(gear_section_id):
			continue
		var gear_section: GearSection = character.get_gear_section(gear_section_id)
		var gear_section_control: GearSectionControl = gear_section_controls[gear_section_id]
		gear_section_control.update(gear_section)
	
	update_internal_items(character, gear_section_controls)
	
	update_place_mode(character, gear_section_controls)
	update_unlock_mode(character, gear_section_controls)

func update_internal_items(character, gear_section_controls: Dictionary):
	# gsid -> gear_section_id
	var internals: Array = character.get_equipped_items()
	for i in range(internals.size()):
		#  
		#   slot (gear_section_id, gear_section_name, x, y)
		#   internal_name
		#   internal: actual Item value
		var internal_info: Dictionary = internals[i]
		var gsid: int = internal_info.slot.gear_section_id
		var primary_cell := Vector2i(internal_info.slot.x, internal_info.slot.y)
		var item = internal_info.internal
		#var item_cells: Array = character.get_item_cells(item, gsid, primary_cell)
		var item_cells: Array = item.get_relative_cells(primary_cell)
		var top_left_cell = item_cells.reduce(func(best: Vector2i, current: Vector2i):
			best.x = min(best.x, current.x)
			best.y = min(best.y, current.y)
			return best
			, Vector2i(1000, 1000))
		var gear_section_control: GearSectionControl = gear_section_controls[gsid]
		var anchor_grid_slot_control: GridSlotControl = gear_section_control.control_grid.get_contents_v(top_left_cell)
		item.snap_to(anchor_grid_slot_control.global_position)
		item.grid_anchor = anchor_grid_slot_control



func update_place_mode(actor: GearwrightActor, gear_section_controls: Dictionary):
	if mode != Modes.PLACE:
		return
	if item_held == null:
		return
	
	# correct section
	var item_section = item_held.item_data.get("section", null)
	# fish internals have no section
	if item_section != null:
		var valid_section_ids := GearwrightCharacter.item_section_to_valid_section_ids(item_section)
		for gear_section_id in gear_section_controls.keys():
			var gear_section_control: GearSectionControl = gear_section_controls[gear_section_id]
			if gear_section_id in valid_section_ids:
				gear_section_control.clear_grey_out()
			else:
				gear_section_control.grey_out()
	
	# no hovered slot
	if current_slot_info.is_empty():
		return
	
	var gsid: int = current_slot_info.gear_section_id
	var primary_cell := Vector2i(current_slot_info.x, current_slot_info.y)
	#var item_cells: Array = character.get_item_cells(item_held, gsid, primary_cell)
	var item_cells: Array = item_held.get_relative_cells(primary_cell)
	var grid_slot_controls := item_cells.map(func(cell):
		if current_gear_section_control.control_grid.is_within_size_v(cell):
			return current_gear_section_control.control_grid.get_contents_v(cell)
		else:
			return null
		)
	grid_slot_controls = grid_slot_controls.filter(func(gsc): return gsc != null)
	if actor.check_internal_equip_validity(item_held, gsid, primary_cell).is_empty():
		for grid_slot_control in grid_slot_controls:
			if grid_slot_control != null:
				grid_slot_control.color_good()
	else:
		for grid_slot_control in grid_slot_controls:
			if grid_slot_control != null:
				grid_slot_control.color_bad()

func update_unlock_mode(character, gear_section_controls: Dictionary):
	if mode != Modes.UNLOCK:
		return
	
	# default frame unlocks
	for gsid in gear_section_controls.keys():
		var gear_section_control: GearSectionControl = gear_section_controls[gsid]
		var gear_section: GearSection = character.get_gear_section(gsid)
		var cells := gear_section.grid.get_valid_entries()
		for cell in cells:
			# cell is Vector2i
			var grid_slot: GridSlot = gear_section.grid.get_contents_v(cell)
			var grid_slot_control: GridSlotControl = gear_section_control.control_grid.get_contents_v(cell)
			if grid_slot.is_default_unlock:
				grid_slot_control.color_bad()
	
	update_current_unlock_highlight(character)

func update_current_unlock_highlight(character):
	if current_slot_info.is_empty():
		return
	
	if current_grid_slot.is_default_unlock:
		return
	
	if current_grid_slot.is_locked:
		if character.has_unlocks_remaining():
			current_grid_slot_control.color_good()
		else:
			current_grid_slot_control.color_bad()
	else:
		# not a default unlock, not locked, should be allowed to re-lock it
		current_grid_slot_control.color_good()


#endregion







#region "Reactivity"

func on_slot_mouse_entered(slot_info: Dictionary, character):
	current_slot_info = {}
	current_slot_info.x = slot_info.x
	current_slot_info.y = slot_info.y
	current_slot_info.gear_section_id = slot_info.gear_section_id
	current_gear_section         = character.get_gear_section(slot_info.gear_section_id)
	current_gear_section_control = slot_info.gear_section_control
	current_grid_slot         = current_gear_section.grid.get_contents(slot_info.x, slot_info.y)
	current_grid_slot_control = slot_info.grid_slot_control

func on_slot_mouse_exited(slot_info: Dictionary):
	if (
			(slot_info.x == current_slot_info.x)
			and (slot_info.y == current_slot_info.y)
			and (slot_info.gear_section_id == current_slot_info.gear_section_id)
	):
		current_slot_info = {}

func on_part_menu_item_spawned(item_id: Variant) -> void:
	if item_held:
		return
	var new_item = item_scene.instantiate()
	new_item.scale = Vector2(1.0, 1.0) * control_scale
	add_child(new_item)
	new_item.load_item(item_id, not is_fish_mode)
	new_item.selected = true
	item_held = new_item
	mode = Modes.PLACE

#endregion

