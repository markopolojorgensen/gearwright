extends RefCounted
class_name InternalInventory

# common element between player characters and fish
# gear sections & equipped internals

# "SECTION_ID_NAME": 0, etc.
# (like an enum)
var gear_section_ids := {}
var gear_sections := {}



#region Initialization

func create_character_gear_sections() -> Dictionary:
	gear_section_ids = {
		TORSO = 0,
		LEFT_ARM = 1,
		RIGHT_ARM = 2,
		HEAD = 3,
		LEGS = 4,
	}
	
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
	
	gear_sections = result
	return result

#endregion













#region Mutation

# slot_info required keys: x, y, gear_section
# returns true on success, false on failure
func equip_internal(item, gear_section_id: int, primary_cell: Vector2i):
	#global_util.fancy_print("equip_internal: %s, primary_cell: %s" % [item.item_data.name, str(primary_cell)])
	#global_util.indent()
	if not is_valid_internal_equip(item, gear_section_id, primary_cell):
		#push_error("failed to equip item %s in gear section: %s: %s" % [
				#item.item_data.name,
				#gear_section_id_to_name(gear_section_id),
				#str(primary_cell)
		#])
		#global_util.fancy_print("invalid equip!")
		#global_util.dedent()
		return false
	
	#var item_cell_offsets: Array = item.item_grids.map(func(coord): return Vector2i(coord[0], coord[1]))
	#var item_cells := item_cell_offsets.map(func(offset): return primary_slot_coord + offset)
	#var item_cells := get_item_cells(item, gear_section_id, primary_cell)
	var item_cells: Array = item.get_relative_cells(primary_cell)
	
	if not gear_section_id in gear_section_ids.values():
		push_error("equip internal: bad gear section id")
		#global_util.fancy_print("invalid equip!")
		#global_util.dedent()
		return false
	var gear_section: GearSection = gear_sections[gear_section_id]
	
	for cell in item_cells:
		assert(gear_section.grid.is_within_size_v(cell))
		var grid_slot: GridSlot = gear_section.grid.get_contents_v(cell)
		assert(not grid_slot.is_locked)
		assert(grid_slot.installed_item == null)
		grid_slot.installed_item = item
		grid_slot.is_primary_install_point = false # defensive programming
	
	var primary_grid_slot: GridSlot = gear_section.grid.get_contents_v(primary_cell)
	primary_grid_slot.is_primary_install_point = true
	#global_util.fancy_print("equip finished successfully!")
	#global_util.dedent()
	return true

func unequip_internal(item, gear_section_id: int):
	var gear_section: GearSection = gear_sections[gear_section_id]
	for cell in gear_section.grid.get_valid_entries():
		var grid_slot: GridSlot = gear_section.grid.get_contents_v(cell)
		if grid_slot.installed_item == item:
			grid_slot.installed_item = null
			grid_slot.is_primary_install_point = false
	
	# TODO yeet comments
	#for grid in item_held.item_grids:
		#var grid_to_check = item_held.grid_anchor.slot_ID + grid[0] + grid[1] * column_count
		#grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
		#grid_array[grid_to_check].installed_item = null
		#internals.erase(grid_to_check)

func full_reset():
	unequip_all_internals()
	for gear_section_id in gear_section_ids.values():
		var gear_section: GearSection = gear_sections[gear_section_id]
		gear_section.reset()

# yeets all equipped internals
func unequip_all_internals():
	for gear_section_id in gear_section_ids.values():
		var gear_section: GearSection = gear_sections[gear_section_id]
		gear_section.unequip_all_internals()

#endregion











#region Interrogation

func is_valid_internal_equip(item, gear_section_id: int, primary_cell: Vector2i) -> bool:
	# there is no gear section
	if not gear_section_id in gear_section_ids.values():
		return false
	
	return true

# returns a list of dictionaries
#  keys:
#   slot (gear_section_id, gear_section_name, x, y)
#   internal_name: snake-case'd internal names (for marshalling)
#   internal: actual Item value (only if include_item_values is true)
func get_equipped_items(include_item_values := true) -> Array:
	var internals_list := []
	for gear_section_id in gear_sections.keys():
		var gear_section: GearSection = gear_sections[gear_section_id]
		for cell in gear_section.grid.get_valid_entries():
			var grid_slot: GridSlot = gear_section.grid.get_contents_v(cell)
			if (grid_slot.installed_item != null) and (grid_slot.is_primary_install_point):
				var internal_name = grid_slot.installed_item.item_data.name.to_snake_case()
				var internal_info := {
					slot = make_slot_info(gear_section_id, cell),
					internal_name = internal_name,
				}
				if include_item_values:
					internal_info.internal = grid_slot.installed_item
				internals_list.append(internal_info)
	return internals_list

# returns a list of dictionaries
#   keys are gear_section_id and grid_slot_coords
# does not include slots that are unlocked by default on the frame
# (these are only slots that the player has unlocked)
func get_unlocked_slots() -> Array:
	var result := []
	for id in gear_sections.keys():
		var gear_section: GearSection = gear_sections[id]
		for coords in gear_section.grid.get_valid_entries():
			# coords is a vector2i
			var grid_slot: GridSlot = gear_section.grid.get_contents_v(coords)
			if (not grid_slot.is_locked) and (not grid_slot.is_default_unlock):
				var info = {
					gear_section_id = id, # int
					grid_slot_coords = coords, # vector2i
				}
				result.append(info)
	return result

func sum_internals_for_stat(stat: String) -> int:
	return global_util.sum_array(get_equipped_items().map(
			func(info: Dictionary): return info.internal.item_data.get(stat, 0))
	)

# Vet your info before calling this function!
func get_grid_slot(gsid: int, x: int, y: int) -> GridSlot:
	var gear_section: GearSection = gear_sections[gsid]
	var grid_slot: GridSlot = gear_section.grid.get_contents(x, y)
	return grid_slot

# returns make_slot_info() result
func grid_array_index_to_slot_info(index: int) -> Dictionary:
	assert(0 <= index)
	var gear_section_id: int = -1
	var adjusted_index: int = -1
	if index < 36:
		adjusted_index = index
		gear_section_id = gear_section_ids.TORSO
	elif index < 54:
		adjusted_index = index - 36
		gear_section_id = gear_section_ids.LEFT_ARM
	elif index < 72:
		adjusted_index = index - 54
		gear_section_id = gear_section_ids.RIGHT_ARM
	elif index < 81:
		adjusted_index = index - 72
		gear_section_id = gear_section_ids.HEAD
	elif index < 99:
		adjusted_index = index - 81
		gear_section_id = gear_section_ids.LEGS
	else:
		push_error("grid array index out of bounds: %d" % index)
		breakpoint
	
	var gear_section: GearSection = gear_sections[gear_section_id]
	#result.gear_section = gear_section
	var x: int = adjusted_index % gear_section.grid.size.x
	@warning_ignore("integer_division")
	var y: int = adjusted_index / gear_section.grid.size.x
	#result.x = x
	#result.y = y
	#result.grid_slot = gear_section.grid.get_contents(x, y)
	assert(0 <= x)
	assert(0 <= y)
	assert(x < gear_section.grid.size.x)
	assert(y < gear_section.grid.size.y)
	return make_slot_info(gear_section_id, Vector2i(x, y))

#endregion





#region Utility

# for JSON-able slots
# FIXME unduplicate in gearwright charactter and internal inventory
func make_slot_info(gear_section_id: int, cell: Vector2i) -> Dictionary:
	return {
		gear_section_name = gear_section_id_to_name(gear_section_id),
		gear_section_id = gear_section_id,
		x = cell.x,
		y = cell.y,
	}

#endregion



