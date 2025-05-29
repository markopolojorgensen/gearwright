extends RefCounted
class_name InternalInventory

# common element between player characters and fish
# gear sections & equipped internals

# "SECTION_ID_NAME": 0, etc.
# (like an enum)
var gear_sections := {}

var max_optics_count: int = 1

#region Initialization

func create_character_gear_sections() -> Dictionary:
	var result := {
		GearwrightActor.GSIDS.FISHER_TORSO:     GearSection.new(Vector2i(6, 6)),
		GearwrightActor.GSIDS.FISHER_LEFT_ARM:  GearSection.new(Vector2i(6, 3)),
		GearwrightActor.GSIDS.FISHER_RIGHT_ARM: GearSection.new(Vector2i(6, 3)),
		GearwrightActor.GSIDS.FISHER_HEAD:      GearSection.new(Vector2i(3, 3)),
		GearwrightActor.GSIDS.FISHER_LEGS:      GearSection.new(Vector2i(3, 6)),
	}
	result[GearwrightActor.GSIDS.FISHER_TORSO].name = "Torso"
	result[GearwrightActor.GSIDS.FISHER_TORSO].dice_string = "(6-8)"
	result[GearwrightActor.GSIDS.FISHER_TORSO].id = GearwrightActor.GSIDS.FISHER_TORSO
	
	result[GearwrightActor.GSIDS.FISHER_LEFT_ARM].name = "Left Arm"
	result[GearwrightActor.GSIDS.FISHER_LEFT_ARM].dice_string = "(4-5)"
	result[GearwrightActor.GSIDS.FISHER_LEFT_ARM].id = GearwrightActor.GSIDS.FISHER_LEFT_ARM
	
	result[GearwrightActor.GSIDS.FISHER_RIGHT_ARM].name = "Right Arm"
	result[GearwrightActor.GSIDS.FISHER_RIGHT_ARM].dice_string = "(9-10)"
	result[GearwrightActor.GSIDS.FISHER_RIGHT_ARM].id = GearwrightActor.GSIDS.FISHER_RIGHT_ARM
	
	result[GearwrightActor.GSIDS.FISHER_HEAD].name = "Head"
	result[GearwrightActor.GSIDS.FISHER_HEAD].dice_string = "(2-3)"
	result[GearwrightActor.GSIDS.FISHER_HEAD].id = GearwrightActor.GSIDS.FISHER_HEAD
	
	result[GearwrightActor.GSIDS.FISHER_LEGS].name = "Legs"
	result[GearwrightActor.GSIDS.FISHER_LEGS].dice_string = "(11-12)"
	result[GearwrightActor.GSIDS.FISHER_LEGS].id = GearwrightActor.GSIDS.FISHER_LEGS
	
	gear_sections = result
	return result

func create_fish_gear_sections(size: GearwrightFish.SIZE):
	gear_sections.clear()
	if size == GearwrightFish.SIZE.SMALL:
		gear_sections[GearwrightActor.GSIDS.FISH_BODY] = GearSection.new(Vector2i(3, 3))
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].name = ""
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].dice_string = ""
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].id = GearwrightActor.GSIDS.FISH_BODY
	elif size == GearwrightFish.SIZE.MEDIUM:
		gear_sections[GearwrightActor.GSIDS.FISH_BODY] = GearSection.new(Vector2i(6, 3))
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].name = ""
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].dice_string = ""
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].id = GearwrightActor.GSIDS.FISH_BODY
	elif size == GearwrightFish.SIZE.LARGE:
		gear_sections[GearwrightActor.GSIDS.FISH_BODY] = GearSection.new(Vector2i(6, 4))
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].name = ""
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].dice_string = ""
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].id = GearwrightActor.GSIDS.FISH_BODY
	elif size == GearwrightFish.SIZE.MASSIVE:
		gear_sections[GearwrightActor.GSIDS.FISH_BODY] = GearSection.new(Vector2i(6, 6))
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].name = ""
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].dice_string = ""
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].id = GearwrightActor.GSIDS.FISH_BODY
	elif size == GearwrightFish.SIZE.LEVIATHAN:
		gear_sections[GearwrightActor.GSIDS.FISH_TAIL] = GearSection.new(Vector2i(3, 6))
		gear_sections[GearwrightActor.GSIDS.FISH_TAIL].name = "Tail"
		gear_sections[GearwrightActor.GSIDS.FISH_TAIL].dice_string = "(2-5)"
		gear_sections[GearwrightActor.GSIDS.FISH_TAIL].id = GearwrightActor.GSIDS.FISH_TAIL
		gear_sections[GearwrightActor.GSIDS.FISH_BODY] = GearSection.new(Vector2i(6, 6))
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].name = "Body"
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].dice_string = "(6-8)"
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].id = GearwrightActor.GSIDS.FISH_BODY
		gear_sections[GearwrightActor.GSIDS.FISH_HEAD] = GearSection.new(Vector2i(3, 6))
		gear_sections[GearwrightActor.GSIDS.FISH_HEAD].name = "Head"
		gear_sections[GearwrightActor.GSIDS.FISH_HEAD].dice_string = "(9-12)"
		gear_sections[GearwrightActor.GSIDS.FISH_HEAD].id = GearwrightActor.GSIDS.FISH_HEAD
	elif size == GearwrightFish.SIZE.SERPENT_LEVIATHAN:
		gear_sections[GearwrightActor.GSIDS.FISH_TIP]  = GearSection.new(Vector2i(3, 3))
		gear_sections[GearwrightActor.GSIDS.FISH_TIP].name = "Tip"
		gear_sections[GearwrightActor.GSIDS.FISH_TIP].dice_string = "(2-3)"
		gear_sections[GearwrightActor.GSIDS.FISH_TIP].id = GearwrightActor.GSIDS.FISH_TIP
		
		gear_sections[GearwrightActor.GSIDS.FISH_TAIL] = GearSection.new(Vector2i(6, 3))
		gear_sections[GearwrightActor.GSIDS.FISH_TAIL].name = "Tail"
		gear_sections[GearwrightActor.GSIDS.FISH_TAIL].dice_string = "(4-5)"
		gear_sections[GearwrightActor.GSIDS.FISH_TAIL].id = GearwrightActor.GSIDS.FISH_TAIL
		
		gear_sections[GearwrightActor.GSIDS.FISH_BODY] = GearSection.new(Vector2i(6, 3))
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].name = "Body"
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].dice_string = "(6-8)"
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].id = GearwrightActor.GSIDS.FISH_BODY
		
		gear_sections[GearwrightActor.GSIDS.FISH_NECK] = GearSection.new(Vector2i(6, 3))
		gear_sections[GearwrightActor.GSIDS.FISH_NECK].name = "Neck"
		gear_sections[GearwrightActor.GSIDS.FISH_NECK].dice_string = "(9-10)"
		gear_sections[GearwrightActor.GSIDS.FISH_NECK].id = GearwrightActor.GSIDS.FISH_NECK
		
		gear_sections[GearwrightActor.GSIDS.FISH_HEAD] = GearSection.new(Vector2i(3, 3))
		gear_sections[GearwrightActor.GSIDS.FISH_HEAD].name = "Head"
		gear_sections[GearwrightActor.GSIDS.FISH_HEAD].dice_string = "(11-12)"
		gear_sections[GearwrightActor.GSIDS.FISH_HEAD].id = GearwrightActor.GSIDS.FISH_HEAD
		
	elif size == GearwrightFish.SIZE.SILTSTALKER_LEVIATHAN:
		gear_sections[GearwrightActor.GSIDS.FISH_LEFT_LEGS]  = GearSection.new(Vector2i(3, 4))
		gear_sections[GearwrightActor.GSIDS.FISH_LEFT_LEGS].name = "L. Legs"
		gear_sections[GearwrightActor.GSIDS.FISH_LEFT_LEGS].dice_string = "(2-3)"
		gear_sections[GearwrightActor.GSIDS.FISH_LEFT_LEGS].id = GearwrightActor.GSIDS.FISH_LEFT_LEGS
		
		gear_sections[GearwrightActor.GSIDS.FISH_BODY]       = GearSection.new(Vector2i(6, 4))
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].name = "Body"
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].dice_string = "(6-8)"
		gear_sections[GearwrightActor.GSIDS.FISH_BODY].id = GearwrightActor.GSIDS.FISH_BODY
		
		gear_sections[GearwrightActor.GSIDS.FISH_RIGHT_LEGS] = GearSection.new(Vector2i(3, 4))
		gear_sections[GearwrightActor.GSIDS.FISH_RIGHT_LEGS].name = "R. Legs"
		gear_sections[GearwrightActor.GSIDS.FISH_RIGHT_LEGS].dice_string = "(11-12)"
		gear_sections[GearwrightActor.GSIDS.FISH_RIGHT_LEGS].id = GearwrightActor.GSIDS.FISH_RIGHT_LEGS
		
		gear_sections[GearwrightActor.GSIDS.FISH_LEFT_ARM]   = GearSection.new(Vector2i(3, 4))
		gear_sections[GearwrightActor.GSIDS.FISH_LEFT_ARM].name = "L. Arm"
		gear_sections[GearwrightActor.GSIDS.FISH_LEFT_ARM].dice_string = "(4-5)"
		gear_sections[GearwrightActor.GSIDS.FISH_LEFT_ARM].id = GearwrightActor.GSIDS.FISH_LEFT_ARM
		
		gear_sections[GearwrightActor.GSIDS.FISH_RIGHT_ARM]  = GearSection.new(Vector2i(3, 4))
		gear_sections[GearwrightActor.GSIDS.FISH_RIGHT_ARM].name = "R. Arm"
		gear_sections[GearwrightActor.GSIDS.FISH_RIGHT_ARM].dice_string = "(9-10)"
		gear_sections[GearwrightActor.GSIDS.FISH_RIGHT_ARM].id = GearwrightActor.GSIDS.FISH_RIGHT_ARM
		
	else:
		var error := "failed to create fish inventory: unknown size %d '%s'" % [size, GearwrightFish.SIZE.find_key(size)]
		push_error(error)
		print(error)
		global_util.popup_warning("bad fish size?", error)
	
	assert(1 <= gear_sections.values().size())
	
	# fish don't have locks
	unlock_all()
	
	return gear_sections

#endregion













#region Mutation

# slot_info required keys: x, y, gear_section
# returns array of String errors
# empty array -> no problems
func equip_internal(item, gear_section_id: int, primary_cell: Vector2i, enforce_tags: bool) -> Array:
	#global_util.fancy_print("equip_internal: %s, primary_cell: %s" % [item.item_data.name, str(primary_cell)])
	#global_util.indent()
	var errors := check_internal_equip_validity(item, gear_section_id, primary_cell, enforce_tags)
	if not errors.is_empty():
		return errors

	var item_cells: Array = item.get_relative_cells(primary_cell)
	
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
	return []

func unequip_internal(item, gear_section_id: int):
	var gear_section: GearSection = gear_sections[gear_section_id]
	for cell in gear_section.grid.get_valid_entries():
		var grid_slot: GridSlot = gear_section.grid.get_contents_v(cell)
		if grid_slot.installed_item == item:
			grid_slot.installed_item = null
			grid_slot.is_primary_install_point = false

func full_reset():
	unequip_all_internals()
	for gear_section_id in get_active_gear_section_ids():
		var gear_section: GearSection = gear_sections[gear_section_id]
		gear_section.reset()

# yeets all equipped internals
func unequip_all_internals():
	for gear_section_id in get_active_gear_section_ids():
		var gear_section: GearSection = gear_sections[gear_section_id]
		gear_section.unequip_all_internals()

# fish don't have unlocks
func unlock_all():
	for gear_section in gear_sections.values():
		if gear_section != null:
			gear_section.unlock_all()

#endregion











#region Interrogation

# returns a list of strings
# each string shows a problem
# returns an empty list if there are no problems
#
# reasons you can't equip something:
#  no gear section
#  slot is out of bounds
#  slot is locked
#  slot already has something
#  exceeds limited tag
func check_internal_equip_validity(item, gear_section_id: int, primary_cell: Vector2i, enforce_tags: bool) -> Array:
	var errors := []
	
	# there is no gear section
	if not gear_section_id in get_active_gear_section_ids():
		errors.append("No gear section '%d'" % gear_section_id)
		return errors
	
	var gear_section: GearSection = gear_sections[gear_section_id]
	# for each slot that would become occupied:
	var cells: Array = item.get_relative_cells(primary_cell)
	var error_outside_grid := false
	var error_locked_slot := false
	var error_overlap := false
	for i in range(cells.size()):
		var cell: Vector2i = cells[i]
		
		# slot is out of bounds
		if not gear_section.grid.is_within_size_v(cell):
			error_outside_grid = true
			continue # can't check a slot that's not real
		
		var grid_slot: GridSlot = gear_section.grid.get_contents_v(cell)
		# slot is locked
		if grid_slot.is_locked:
			error_locked_slot = true
		
		# there's already something there
		if grid_slot.installed_item != null:
			error_overlap = true
	
	if error_outside_grid:
		errors.append("Not within grid")
	if error_locked_slot:
		errors.append("Hardpoint is locked")
	if error_overlap:
		errors.append("Overlaps existing internal")
	
	
	# only tags beyond this point! (limited, bulky, etc)
	if not enforce_tags:
		return errors
	
	var item_tags = item.item_data.tags
	var limit: int = -1
	var is_bulky := false
	var is_optics := false
	var is_engine := false
	var is_unwieldy := false
	for tag in item_tags:
		tag = (tag as String).to_lower()
		if "limited" in tag:
			limit = int(tag.get_slice(" ", 1))
		elif "bulky" in tag:
			is_bulky = true
		elif "optic" in tag:
			is_optics = true
		elif "engine" in tag:
			is_engine = true
		elif "unwieldy" in tag:
			is_unwieldy = true
	
	
	# Limited tag
	if 1 <= limit:
		var item_name: String = item.item_data.name.to_snake_case()
		item_name = collapse_armor_names(item_name)
		var count: int = 1 # include the one we're adding
		var equipped_item_infos := get_equipped_items()
		for equipped_item_info in equipped_item_infos:
			var equipped_item_name: String = equipped_item_info.internal_name
			equipped_item_name = collapse_armor_names(equipped_item_name)
			if equipped_item_name == item_name:
				count += 1
		if limit < count:
			errors.append("Exceeds Limited count (%s: %d)" % [item_name.capitalize(), limit])
	
	if is_optics:
		errors.append_array(check_tag_count("optics", max_optics_count))
	if is_engine:
		errors.append_array(check_tag_count("engine", 1))
	if is_unwieldy:
		errors.append_array(check_tag_count("unwieldy", 1))
	
	if is_bulky:
		var equipped_item_infos: Array = get_equipped_items_by_gs()[gear_section_id]
		for equipped_item_info in equipped_item_infos:
			var other_tags = equipped_item_info.internal.item_data.tags
			var is_other_bulky := false
			for tag in other_tags:
				if "bulky" in tag.to_lower():
					is_other_bulky = true
			if not is_other_bulky:
				continue
			
			var other_primary_cell := Vector2i(equipped_item_info.slot.x, equipped_item_info.slot.y)
			var other_cells = equipped_item_info.internal.get_relative_cells(other_primary_cell)
			var bulky_violation := false
			for cell in cells:
				if bulky_violation:
					break
				for other_cell in other_cells:
					if bulky_violation:
						break
					if Vector2(cell).distance_squared_to(Vector2(other_cell)) <= 2.0:
						bulky_violation = true
			if bulky_violation:
				errors.append("Bulky: Adjacent to %s" % equipped_item_info.internal.item_data.name)
	
	if DataHandler.is_curio(item.item_data):
		for equipped_item_info in get_equipped_items():
			if DataHandler.is_curio(equipped_item_info.internal.item_data):
				errors.append("Already has curio %s" % equipped_item_info.internal.item_data.name)
	
	return errors

func collapse_armor_names(item_name: String) -> String:
	const trouble_names := [
		"horizontal_armored_scales",
		"vertical_armored_scales",
		"horizontal_armor",
		"vertical_armor",
	]
	if item_name in trouble_names:
		return item_name.replace("horizontal_", "").replace("vertical_", "")
	else:
		return item_name

func check_tag_count(tag_name: String, max_count: int) -> Array:
	var equipped_item_infos := get_equipped_items()
	var other_count: int = 0
	var errors := []
	for equipped_item_info in equipped_item_infos:
		var other_tags = equipped_item_info.internal.item_data.tags
		for tag in other_tags:
			if tag_name in tag.to_lower():
				other_count += 1
				var equipped_item_name: String = equipped_item_info.internal.item_data.name
				errors.append("%s: already has %s" % [tag_name.capitalize(), equipped_item_name])
				break
	if max_count < (other_count + 1):
		return errors
	else:
		return []

# returns a list of dictionaries
#  keys:
#   slot (gear_section_id, gear_section_name, x, y)
#   internal_name: snake-case'd internal names (for marshalling)
#   internal: actual Item value (only if include_item_values is true)
#
# FIXME: this and get_equipped_items_by_gs are dangerous
# this function uses make_slot_info
# get_equipped_items_by_gs doesn't
func get_equipped_items(include_item_values := true) -> Array:
	var internals_list := []
	for gear_section_id in gear_sections.keys():
		var gear_section: GearSection = gear_sections[gear_section_id]
		for cell in gear_section.grid.get_valid_entries():
			var grid_slot: GridSlot = gear_section.grid.get_contents_v(cell)
			if (grid_slot.installed_item != null) and (grid_slot.is_primary_install_point):
				var internal_name = grid_slot.installed_item.item_data.name.to_snake_case()
				var internal_info := {
					slot = global.make_slot_info(gear_section_id, cell),
					internal_name = internal_name,
				}
				if include_item_values:
					internal_info.internal = grid_slot.installed_item
				internals_list.append(internal_info)
	return internals_list

# returns a dictionary
#  keys: gsid
#  value: list of dictionaries:
#   slot: Vector2i coords
#   internal_name: snake-case'd internal names (for marshalling)
#   internal: actual Item value (only if include_item_values is true)
func get_equipped_items_by_gs(include_item_values := true) -> Dictionary:
	var result := {}
	for gear_section_id in gear_sections.keys():
		var internals_list := []
		var gear_section: GearSection = gear_sections[gear_section_id]
		for cell in gear_section.grid.get_valid_entries():
			var grid_slot: GridSlot = gear_section.grid.get_contents_v(cell)
			if (grid_slot.installed_item != null) and (grid_slot.is_primary_install_point):
				var internal_name = grid_slot.installed_item.item_data.name.to_snake_case()
				var internal_info := {
					slot = cell,
					internal_name = internal_name,
				}
				if include_item_values:
					internal_info.internal = grid_slot.installed_item
				internals_list.append(internal_info)
		result[gear_section_id] = internals_list
	return result

# returns a list of dictionaries
#   keys are gear_section_id and grid_slot_coords
# does not include slots that are unlocked by default on the frame
# (these are only slots that the player has unlocked)
#
# as far as I can tell this is only used for counting how many unlocked slots there are
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

# used for marshalling
# returns a dictionary
#  key: gsid
#  value: Array of Vector2i slot coordinates
func get_unlocked_slots_by_gear_section() -> Dictionary:
	var result := {}
	for gsid in gear_sections.keys():
		var gear_section: GearSection = gear_sections[gsid]
		var gear_section_unlocks = []
		for coords in gear_section.grid.get_valid_entries():
			# coords is a vector2i
			var grid_slot: GridSlot = gear_section.grid.get_contents_v(coords)
			if (not grid_slot.is_locked) and (not grid_slot.is_default_unlock):
				gear_section_unlocks.append(coords)
		#if not gear_section_unlocks.is_empty():
		result[gsid] = gear_section_unlocks
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
# this method explodes if you try to call it on a fish character
func grid_array_index_to_slot_info(index: int) -> Dictionary:
	assert(0 <= index)
	var gear_section_id: int = -1
	var adjusted_index: int = -1
	if index < 36:
		adjusted_index = index
		gear_section_id = GearwrightActor.GSIDS.FISHER_TORSO
	elif index < 54:
		adjusted_index = index - 36
		gear_section_id = GearwrightActor.GSIDS.FISHER_LEFT_ARM
	elif index < 72:
		adjusted_index = index - 54
		gear_section_id = GearwrightActor.GSIDS.FISHER_RIGHT_ARM
	elif index < 81:
		adjusted_index = index - 72
		gear_section_id = GearwrightActor.GSIDS.FISHER_HEAD
	elif index < 99:
		adjusted_index = index - 81
		gear_section_id = GearwrightActor.GSIDS.FISHER_LEGS
	else:
		push_error("grid array index out of bounds: %d" % index)
		breakpoint
	
	var gear_section: GearSection = gear_sections[gear_section_id]
	var x: int = adjusted_index % gear_section.grid.size.x
	@warning_ignore("integer_division")
	var y: int = adjusted_index / gear_section.grid.size.x
	assert(0 <= x)
	assert(0 <= y)
	assert(x < gear_section.grid.size.x)
	assert(y < gear_section.grid.size.y)
	return global.make_slot_info(gear_section_id, Vector2i(x, y))

func get_active_gear_section_ids() -> Array:
	return gear_sections.keys()

func _to_string() -> String:
	return "<InternalInventory: %d gear sections (%d active), %d equipped internals | sections: %s>" % \
			[
				gear_sections.keys().size(),
				get_active_gear_section_ids().size(),
				get_equipped_items().size(),
				gear_sections.keys(),
			]

# used for fish validity checks
func get_empty_hardpoint_count() -> int:
	var result: int = 0
	for gsid in gear_sections.keys():
		var gear_section: GearSection = gear_sections[gsid]
		for coords in gear_section.grid.get_valid_entries():
			# coords is a vector2i
			var grid_slot: GridSlot = gear_section.grid.get_contents_v(coords)
			if (not grid_slot.is_locked) and (grid_slot.installed_item == null):
				result += 1
	return result

#endregion






