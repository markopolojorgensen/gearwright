extends RefCounted
class_name GearwrightCharacter

# represents a single character in gearwright
# one gear loadout, one callsign, etc.

const item_scene = preload("res://Scenes/item.tscn")

var callsign := ""

# keys in game data json files
var frame_name := ""
var level := -1

var developments := []
var maneuvers := []
var deep_words := []

var gear_sections: Dictionary = create_gear_sections()
enum gear_section_ids {
	TORSO,
	LEFT_ARM,
	RIGHT_ARM,
	HEAD,
	LEGS,
}

var frame_stats := DataHandler.frame_stats_template.duplicate(true)
var level_stats := DataHandler.level_stats_template.duplicate(true)
var background_stats := DataHandler.background_stats_template.duplicate(true)
# {"marbles":1, "mental":1, "willpower":1, "unlocks":2, "weight_cap":2}
var custom_background := []






#region Initialization

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














#region Interrogation

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

#func get_total_equipped_weight() -> int:
	#return gear_sections.values().reduce(
			#func(sum, gear_section: GearSection):
				#return sum + gear_section.get_total_equipped_weight(),
			#0)
	#var sections := gear_sections.values()
	#var sum := 0
	#for i in range(sections.size()):
		#var gear_section: GearSection = sections[i]
		#sum += gear_section.get_total_equipped_weight()
	#return sum

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

# return value keys: label_text, explanation_text
func get_stat_label_text(stat: String) -> String:
	var snake_stat := stat.to_snake_case()
	if snake_stat in [
			"close",
			"far",
			"mental",
			"power",
			"evasion",
			"willpower",
			"ap",
			"speed",
			"sensors",
			"repair_kits",
			"weight",
			"weight_cap",
			"ballast",
			]:
		var value = call("get_%s" % snake_stat)
		return "%s: %s" % [stat, value]
	
	match snake_stat:
		"background":
			return "%s: %s" % [stat, background_stats.background]
		"marbles":
			return "%s: %s" % [stat, get_max_marbles()]
		"core_integrity":
			return "%s: %s" % [stat, frame_stats.core_integrity]
		"unlocks":
			return "%s: %s" % [stat, get_max_unlocks()]
		"":
			return ""
		_:
			push_error("GearwrightCharacter: get_stat_label_text: unknown stat: %s" % stat)
			return ""
	
	#var sl
	#sl = stat_lines["weight"]
	#sl.label.text = "%s: %s" % [sl.name, character.get_total_equipped_weight()]
	#
	#sl = stat_lines["weight_cap"]
	#sl.label.text = "%s: %s" % [sl.name, character.get_weight_cap()]
	#
	#sl = stat_lines["marbles"]
	#sl.label.text = "%s: %s" % [sl.name, character.get_max_marbles()]
	#
	#sl = stat_lines["core_integrity"]
	#sl.label.text = "%s: %s" % [sl.name, character.frame_stats.core_integrity]

func get_stat_explanation(stat: String) -> String:
	var snake_stat := stat.to_snake_case()
	if snake_stat in [
			"close",
			"far",
			"mental",
			"power",
			"evasion",
			"willpower",
			"ap",
			"speed",
			"sensors",
			"repair_kits",
			"weight",
			"weight_cap",
			"ballast",
			]:
		var info: Dictionary = call("get_%s_info" % snake_stat)
		return info_to_explanation_text(info)
	
	match snake_stat:
		"background":
			return ""
			# custom background explanation_text, maybe?
		"marbles":
			return info_to_explanation_text(get_max_marbles_info())
		"core_integrity":
			return info_to_explanation_text({frame = frame_stats.core_integrity})
		"unlocks":
			return info_to_explanation_text(get_max_unlocks_info())
		"":
			return ""
		_:
			push_error("GearwrightCharacter: get_stat_explanation: unknown stat: %s" % stat)
			return ""

func sum_array(list: Array):
	return list.reduce(func(sum, value): return sum + value, 0)

func info_to_explanation_text(info: Dictionary) -> String:
	var result = ""
	for key in info.keys():
		var number: int = info[key]
		var number_string := ""
		if 0 < number:
			number_string = "+%d" % number
		elif number < 0:
			number_string = "%d" % number
		else:
			number_string = "-"
		
		result += "%s: %s\n" % [key.capitalize(), number_string]
	return result

func sum_internals_for_stat(stat: String) -> int:
	return sum_array(get_equipped_items().map(
			func(info: Dictionary): return info.internal.item_data.get(stat, 0))
	)

func has_unlocks_remaining() -> bool:
	return get_unlocked_slots().size() < get_max_unlocks()

# all the reasons we can't put an item in a slot:
#   there is no item
#   there is no slot
#   it would put us over weight
#   wrong section (e.g. trying to put head gear in leg)
#   for each slot that would become occupied:
#     there's already something there
#     slot is out of bounds
#     slot is locked
func is_valid_internal_equip(item, gear_section_id: int, primary_cell: Vector2i) -> bool:
	# there is no item
	if item == null:
		return false
	
	# there is no gear section
	if not gear_section_id in gear_section_ids.values():
		return false
	
	
	# it would put us over weight
	if is_overweight_with_item(item):
		return false
	
	# wrong section (e.g. trying to put head gear in leg)
	var valid_section_ids := item_section_to_valid_section_ids(item.item_data.section)
	if not gear_section_id in valid_section_ids:
		return false
	
	var gear_section: GearSection = gear_sections[gear_section_id]
	# for each slot that would become occupied:
	var cells := get_item_cells(item, gear_section_id, primary_cell)
	for i in range(cells.size()):
		var cell: Vector2i = cells[i]
		
		# slot is out of bounds
		if not gear_section.grid.is_within_size_v(cell):
			return false
		
		var grid_slot: GridSlot = gear_section.grid.get_contents_v(cell)
		# slot is locked
		if grid_slot.is_locked:
			return false
		
		# there's already something there
		if grid_slot.installed_item != null:
			return false
	
	return true

func is_overweight_with_item(item):
	var weight := get_weight()
	if item != null:
		weight += item.item_data.weight
	if weight > get_weight_cap():
		return true
	else:
		return false

# item.item_grids -> actual coords based on an actual slot
# item.item_grids is an array
# each element is a 2-element array representing coordinates
#
# this function returns a list of Vector2i elements
# some of these might be out of bounds!
func get_item_cells(item, gear_section_id: int, primary_cell: Vector2i) -> Array:
	if item == null:
		return []
	if not gear_section_id in gear_section_ids.values():
		return []
	
	var item_cell_offsets: Array = item.item_grids.map(func(coord): return Vector2i(coord[0], coord[1]))
	var item_cells := item_cell_offsets.map(func(offset): return primary_cell + offset)
	return item_cells

# Vet your info before calling this function!
func get_grid_slot(gsid: int, x: int, y: int) -> GridSlot:
	var gear_section: GearSection = gear_sections[gsid]
	var grid_slot: GridSlot = gear_section.grid.get_contents(x, y)
	return grid_slot

#endregion











#region Stat Info

# only ask for marbles, mental, willpower, unlocks, weight_cap
func get_bg_amount(stat: String):
	const mults = {
		"marbles":1,
		"mental":1,
		"willpower":1,
		"unlocks":2,
		"weight_cap":2,
	}
	var bg_amount: int = background_stats[stat]
	if background_stats.background.to_lower() == "custom":
		bg_amount += custom_background.count(stat) * mults.get(stat, 0)
	return bg_amount

func get_max_marbles_info() -> Dictionary:
	return add_dev_info("marbles", {
		background = get_bg_amount("marbles")
	})

func get_max_marbles() -> int:
	return sum_array(get_max_marbles_info().values())


func get_close_info() -> Dictionary:
	return {
		frame = frame_stats.close,
		internals = sum_internals_for_stat("close")
	}

func get_close() -> int:
	return sum_array(get_close_info().values())

func get_far_info() -> Dictionary:
	return {
		frame = frame_stats.far,
		internals = sum_internals_for_stat("far")
	}

func get_far() -> int:
	return sum_array(get_far_info().values())

func get_mental_info() -> Dictionary:
	return add_dev_info("mental", {
		background = get_bg_amount("mental")
		# internals TODO fish have this
	})

func get_mental() -> int:
	return sum_array(get_mental_info().values())

func get_power_info() -> Dictionary:
	return {
		frame = frame_stats.power,
		internals = sum_internals_for_stat("power"),
	}

func get_power() -> int:
	return sum_array(get_power_info().values())

func get_evasion_info() -> Dictionary:
	return {
		frame = frame_stats.evasion,
		internals = sum_internals_for_stat("evasion")
	}

func get_evasion() -> int:
	return sum_array(get_evasion_info().values())

func get_willpower_info() -> Dictionary:
	return add_dev_info("willpower", {
		background = get_bg_amount("willpower"),
		# developments TODO
		# fish internals TODO
	})

func get_willpower() -> int:
	return sum_array(get_willpower_info().values())

func get_ap_info() -> Dictionary:
	return {
		frame = frame_stats.ap,
		internals = sum_internals_for_stat("ap"),
	}

func get_ap() -> int:
	return sum_array(get_ap_info().values())

func get_speed_info() -> Dictionary:
	return {
		frame = frame_stats.speed,
		internals = sum_internals_for_stat("speed"),
	}

func get_speed() -> int:
	return sum_array(get_speed_info().values())

func get_sensors_info() -> Dictionary:
	return {
		frame = frame_stats.sensors,
		internals = sum_internals_for_stat("sensors"),
	}

func get_sensors() -> int:
	return sum_array(get_sensors_info().values())

func get_repair_kits_info() -> Dictionary:
	return add_dev_info("repair_kits", {
		frame = frame_stats.repair_kits,
		internals = sum_internals_for_stat("repair_kits"),
	})

func get_repair_kits() -> int:
	return sum_array(get_repair_kits_info().values())

func get_max_unlocks_info() -> Dictionary:
	return add_dev_info("unlocks", {
		background = get_bg_amount("unlocks"),
		level = level_stats.unlocks,
	})

func get_max_unlocks() -> int:
	return sum_array(get_max_unlocks_info().values())

func get_weight_info() -> Dictionary:
	return {
		internals = sum_internals_for_stat("weight")
	}

func get_weight() -> int:
	return sum_array(get_weight_info().values())

func get_weight_cap_info() -> Dictionary:
	var result := {
		background = get_bg_amount("weight_cap"),
		frame = frame_stats.weight_cap,
		level = level_stats.weight_cap,
		# developments TODO
	}
	result = add_dev_info("weight_cap", result)
	return result

func get_weight_cap() -> int:
	return sum_array(get_weight_cap_info().values())

func get_ballast_info() -> Dictionary:
	var ballast_from_weight: int = weight_to_ballast(get_weight())
	var result = {
		frame = frame_stats.ballast,
		weight = ballast_from_weight,
		internals = sum_internals_for_stat("ballast"),
	}
	const LIGHTWEIGHT := "lightweight_modifier"
	var lightweight_info := add_dev_info(LIGHTWEIGHT, {})
	if not lightweight_info.is_empty():
		var dev_name: String = lightweight_info.keys()[0]
		var adjusted_weight: int = get_weight() - lightweight_info[dev_name]
		var ballast_from_adjusted_weight: int = weight_to_ballast(adjusted_weight)
		var ballast_effect = ballast_from_adjusted_weight - ballast_from_weight
		result[dev_name] = ballast_effect
	
	return result

func weight_to_ballast(weight: int) -> int:
	@warning_ignore("integer_division")
	var result: int = weight / 5
	return result

func get_ballast() -> int:
	var value: int = sum_array(get_ballast_info().values())
	return clamp(value, 1, 10)

func get_deep_word_count_info() -> Dictionary:
	return add_dev_info("deep_words", {})

func get_deep_word_count() -> int:
	return sum_array(get_deep_word_count_info().values())


#func get__info() -> Dictionary:
	#return {
		#
	#}
#
#func get_() -> int:
	#return sum_array(get__info().values())

#endregion






#region Mutation

# yeets all equipped internals
# resets unlocks to nothing
# reapplies default unlocks from frame
func reset_gear_sections():
	unequip_all_internals()
	for gear_section_id in gear_section_ids.values():
		var gear_section: GearSection = gear_sections[gear_section_id]
		gear_section.reset()
	
	var default_unlocks: Array = frame_stats.default_unlocks
	for index in default_unlocks:
		#grid_array[index].unlock()
		var info := grid_array_index_to_slot_info(index)
		var grid_slot: GridSlot = get_grid_slot(info.gear_section_id, info.x, info.y)
		grid_slot.is_locked = false
		grid_slot.is_default_unlock = true

# yeets all equipped internals
func unequip_all_internals():
	for gear_section_id in gear_section_ids.values():
		var gear_section: GearSection = gear_sections[gear_section_id]
		gear_section.unequip_all_internals()

# slot_info required keys: x, y, gear_section
# returns true on success, false on failure
func equip_internal(item, gear_section_id: int, primary_cell: Vector2i):
	if not is_valid_internal_equip(item, gear_section_id, primary_cell):
		#push_error("failed to equip item %s in gear section: %s: %s" % [
				#item.item_data.name,
				#gear_section_id_to_name(gear_section_id),
				#str(primary_cell)
		#])
		return false
	
	#var item_cell_offsets: Array = item.item_grids.map(func(coord): return Vector2i(coord[0], coord[1]))
	#var item_cells := item_cell_offsets.map(func(offset): return primary_slot_coord + offset)
	var item_cells := get_item_cells(item, gear_section_id, primary_cell)
	
	if not gear_section_id in gear_section_ids.values():
		push_error("equip internal: bad gear section id")
		return false
	var gear_section: GearSection = gear_sections[gear_section_id]
	
	for cell in item_cells:
		assert(gear_section.grid.is_within_size_v(cell))
		var grid_slot: GridSlot = gear_section.grid.get_contents_v(cell)
		assert(not grid_slot.is_locked)
		assert(grid_slot.installed_item == null)
		grid_slot.installed_item = item
	
	var primary_grid_slot: GridSlot = gear_section.grid.get_contents_v(primary_cell)
	primary_grid_slot.is_primary_install_point = true
	return true

func mystery_section_to_section_id(section) -> int:
	if section is int:
		if section in gear_section_ids.values():
			return section
		else:
			push_error("unknown int gear section: %s" % str(section))
			breakpoint
			return -1
	elif section is String:
		if section in ["0", "1", "2", "3", "4"]:
			return int(section)
		var result = gear_section_name_to_id(section)
		if result == -1:
			push_error("unknown string gear section: %s" % str(section))
			breakpoint
			return -1
		else:
			return result
	else:
		push_error("unknown gear section: not int or string: %s" % str(section))
		breakpoint
		return -1

# returns true if successful
func toggle_unlock(gear_section_id: int, x: int, y: int) -> bool:
	var grid_slot := get_grid_slot(gear_section_id, x, y)
	
	# slot is a default unlock
	if grid_slot.is_default_unlock:
		return false
	
	# slot has something in it
	if grid_slot.installed_item != null:
		return false
	
	# locked, but no unlocks left
	# allow player to re-lock non-default unlocked slots
	# allow player to unlock non-default locked slots when they have unlocks left
	if grid_slot.is_locked and not has_unlocks_remaining():
		return false
	
	grid_slot.is_locked = not grid_slot.is_locked
	return true

func add_development(name: String):
	DataHandler.get_development_data(name) # trigger popup
	developments.append(name)

func remove_development(name: String):
	developments.erase(name)

# returns a dictionary of relevant developments
# keys are development names, values are development stat blocks
func find_devs_that_modify(stat: String) -> Dictionary:
	var result = {}
	for dev_name in developments:
		var dev_stats: Dictionary = DataHandler.get_development_data(dev_name)
		if dev_stats.has(stat):
			result[dev_name] = dev_stats
	return result

# modify stat info dictionary with development stats
func add_dev_info(stat_name: String, stat_info: Dictionary) -> Dictionary:
	var devs := find_devs_that_modify(stat_name)
	for dev_name in devs.keys():
		var dev: Dictionary = devs[dev_name]
		stat_info[dev.name] = dev[stat_name]
	return stat_info

#endregion






#region save & load

func load_frame(name: String):
	print("applying frame: %s" % name)
	frame_name = name
	frame_stats = DataHandler.get_thing_nicely("frame", name)
	reset_gear_sections()

func load_background(bg_name: String):
	print("applying background: %s" % bg_name)
	custom_background.clear()
	background_stats = DataHandler.get_thing_nicely("background", bg_name)

# might be int, might be string
func set_level(new_level):
	if new_level is String:
		new_level = int(new_level)
	level = new_level
	print("applying level: %d" % level)
	level_stats = DataHandler.get_thing_nicely("level", str(level))

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

func marshal() -> Dictionary:
	var result := {
		callsign = callsign,
		frame = frame_name,
		background = background_stats.background,
		level = str(level)
	}
	
	result.custom_background = custom_background
	
	var unlocks_info = []
	for real_slot_info in get_unlocked_slots():
		var json_slot_info = make_slot_info(real_slot_info.gear_section_id, real_slot_info.grid_slot_coords)
		unlocks_info.append(json_slot_info)
	result.unlocks = unlocks_info
	
	result.internals = get_equipped_items(false)
	
	# TODO developments
	# TODO manuevers
	# TODO deep words
	
	result.gearwright_version = version.VERSION
	
	return result
	
	#for grid in internals.keys():
		#gear_data["internals"][str(grid)] = internals[grid].item_data["name"].to_snake_case()
	#
	#gear_data["frame"] = current_frame
	#gear_data["background"] = current_background
	#gear_data["callsign"] = callsign_line_edit.text
	#gear_data["custom_background"] = custom_background
	#gear_data["developments"] = developments_container.current_developments
	#gear_data["maneuvers"] = maneuvers_container.current_maneuvers
	#gear_data["deep_words"] = deep_words_container.current_deep_words
	#
	#return str(gear_data).replace("\\", "")

# for JSON-able slots
func make_slot_info(gear_section_id: int, cell: Vector2i) -> Dictionary:
	return {
		gear_section_name = gear_section_id_to_name(gear_section_id),
		gear_section_id = gear_section_id,
		x = cell.x,
		y = cell.y,
	}

#endregion




#region static functions

static func gear_section_id_to_name(id: int) -> String:
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

static func gear_section_name_to_id(name: String) -> int:
	match name:
		"torso":
			return gear_section_ids.TORSO
		"left_arm":
			return gear_section_ids.LEFT_ARM
		"right_arm":
			return gear_section_ids.RIGHT_ARM
		"head":
			return gear_section_ids.HEAD
		"legs":
			return gear_section_ids.LEGS
		_:
			return -1

# section_name is from item_data.json
# returns a list of valid gear_section_ids based on that name
static func item_section_to_valid_section_ids(section_name: String) -> Array:
	match section_name:
		"leg":
			return [gear_section_ids.LEGS]
		"arm":
			var arms = [
				gear_section_ids.LEFT_ARM,
				gear_section_ids.RIGHT_ARM,
			]
			return arms
		"head":
			return [gear_section_ids.HEAD]
		"chest":
			return [gear_section_ids.TORSO]
		"any":
			return gear_section_ids.values()
		_:
			push_error("gearwright_character: unknown item section: %s" % section_name)
			return []

class UnmarshalSession:
	var errors := []
	var info := {}
	
	func get_info(key, default = ""):
		if info.has(key):
			return info[key]
		else:
			errors.append("No %s info found!" % key)
			return default

static func unmarshal(info: Dictionary) -> GearwrightCharacter:
	var sesh := UnmarshalSession.new()
	sesh.info = info
	if not info.has("gearwright_version"):
		sesh.errors.append("No Version Detected!")
		sesh.errors.append("This character may have been made with a previous version of gearwright. Some things will not load properly.")
		#global_util.popup_warning()
	elif info.get("gearwright_version", "") != version.VERSION:
		sesh.errors.append("Different Version Detected!")
		sesh.errors.append("This character was made with a different version of gearwright. Some things may not load properly.")
		#global_util.popup_warning("Different Version Detected!", "This character was made with a different version of gearwright. Some things may not load properly.")
	
	var ch := GearwrightCharacter.new()
	ch.callsign = sesh.get_info("callsign")
	ch.load_frame(sesh.get_info("frame"))
	ch.load_background(sesh.get_info("background"))
	ch.set_level(sesh.get_info("level", 1))
	
	ch.custom_background = sesh.get_info("custom_background", [])
	
	var unlocks_info: Array = sesh.get_info("unlocks", [])
	var old_version_error := false
	for unlock_info in unlocks_info:
		# old style
		if not unlock_info is Dictionary:
			if not old_version_error:
				sesh.errors.append("Unlocks save format is from a previous version, attempting conversion")
				old_version_error = true
			unlock_info = ch.grid_array_index_to_slot_info(int(unlock_info))
		# unlock_info should now be in make_slot_info format
		
		if not ch.toggle_unlock(unlock_info.gear_section_id, unlock_info.x, unlock_info.y):
			sesh.errors.append("  failed to unlock %s" % str(unlock_info))
		
		#var grid_slot: GridSlot = ch.get_grid_slot(unlock_info.gear_section_id, unlock_info.x, unlock_info.y)
		#grid_slot.is_locked = false
	
	#var unlocks_info = []
	#for real_slot_info in get_unlocked_slots():
		#var json_slot_info = make_slot_info(real_slot_info.gear_section_id, real_slot_info.grid_slot_coords)
		#unlocks_info.append(json_slot_info)
	#result.unlocks = unlocks_info
	
	
	var internals = sesh.get_info("internals", [])
	if internals is Dictionary:
		sesh.errors.append("Internals save format is from a previous version, attempting conversion")
		var new_internals = []
		for key in internals.keys():
			var json_slot_info: Dictionary = ch.grid_array_index_to_slot_info(int(key))
			var new_internal_info = {
				slot = json_slot_info,
				internal = internals[key],
			}
			new_internals.append(new_internal_info)
		internals = new_internals
	for i in range(internals.size()):
		# internal_info.slot: dictionary
		#   gear_section, x, y
		# internal_info.internal: string
		var internal_info: Dictionary = internals[i]
		var new_internal = item_scene.instantiate()
		new_internal.load_item(internal_info.internal)
		var gear_section_id: int = int(internal_info.slot.gear_section_id)
		var primary_cell := Vector2i(internal_info.slot.x, internal_info.slot.y)
		if not ch.equip_internal(new_internal, gear_section_id, primary_cell):
			sesh.errors.append("  failed to install internal: %s" % internal_info)
	
	# TODO developments
	# TODO manuevers
	# TODO deep words
	
	if not sesh.errors.is_empty():
		global_util.popup_warning("Load Errors:", sesh.errors.reduce(
				func(result: String, message: String):
					if result.is_empty():
						return message
					else:
						return result + "\n" + message
					, "")
		)
	
	return ch

#endregion




