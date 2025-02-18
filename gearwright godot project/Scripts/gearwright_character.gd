extends GearwrightActor
class_name GearwrightCharacter

# represents a single character in gearwright
# one gear loadout, one callsign, etc.

# keys in game data json files
var frame_name := ""
var level := -1

var developments := []
var maneuvers := []
var deep_words := []

var frame_stats := DataHandler.frame_stats_template.duplicate(true)
var level_stats := DataHandler.level_stats_template.duplicate(true)
var background_stats := DataHandler.background_stats_template.duplicate(true)
# {"marbles":1, "mental":1, "willpower":1, "unlocks":2, "weight_cap":2}
var custom_background := []
const custom_background_caps := {
	"marbles":    2,
	"willpower":  4,
	"mental":     4,
	"unlocks":    1,
	"weight_cap": 1,
}



enum CHARACTER_GSIDS {
	TORSO,
	LEFT_ARM,
	RIGHT_ARM,
	HEAD,
	LEGS,
}



#region Initialization
func _init():
	internal_inventory.create_character_gear_sections()
	gear_section_ids = CHARACTER_GSIDS
#endregion
















#region Interrogation

# returns a list of strings
# each string shows a problem
# returns an empty list if there are no problems
# doesn't necessarily give you all the problems at once, but tries to
#
# all the reasons we can't put an item in a slot:
#   there is no item
#   there is no slot
#   it would put us over weight
#   wrong section (e.g. trying to put head gear in leg)
#   for each slot that would become occupied:
#     there's already something there
#     slot is out of bounds
#     slot is locked
func check_internal_equip_validity(item, gear_section_id: int, primary_cell: Vector2i) -> Array:
	var errors := super(item, gear_section_id, primary_cell)
	if not errors.is_empty():
		return errors
	
	# it would put us over weight
	if is_overweight_with_item(item):
		errors.append("Too much weight")
	
	# wrong section (e.g. trying to put head gear in leg)
	var valid_section_ids := item_section_to_valid_section_ids(item.item_data.section)
	if not gear_section_id in valid_section_ids:
		errors.append("%s can't go in %s section" % [item.item_data.name, gear_section_id_to_name(gear_section_id).capitalize()])
	
	errors.append_array(internal_inventory.check_internal_equip_validity(item, gear_section_id, primary_cell))
	#if not internal_inventory.is_valid_internal_equip(item, gear_section_id, primary_cell):
		#return false
	
	#var gear_section: GearSection = gear_sections[gear_section_id]
	# for each slot that would become occupied:
	#var cells := get_item_cells(item, gear_section_id, primary_cell)
	#for i in range(cells.size()):
		#var cell: Vector2i = cells[i]
		#
		## slot is out of bounds
		#if not gear_section.grid.is_within_size_v(cell):
			#return false
		#
		#var grid_slot: GridSlot = gear_section.grid.get_contents_v(cell)
		## slot is locked
		#if grid_slot.is_locked:
			#return false
		#
		## there's already something there
		#if grid_slot.installed_item != null:
			#return false
	
	#return true
	return errors

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

func get_equipped_items() -> Array:
	return internal_inventory.get_equipped_items()

func has_gear_section(gsid: int) -> bool:
	return internal_inventory.gear_sections.has(gsid)

func get_gear_section(gsid: int) -> GearSection:
	return internal_inventory.gear_sections[gsid]

## returns 4 things
## stat name, total, base, bonus
## not necessarily strings
#func get_stat_label_texts(stat: String) -> Array:
	#var snake_stat := stat.to_snake_case()
	#if snake_stat in [
			#"close",
			#"far",
			#"mental",
			#"power",
			#"evasion",
			#"willpower",
			#"ap",
			#"speed",
			#"sensors",
			#"repair_kits",
			#"weight",
			#"weight_cap",
			#"ballast",
			#]:
		#var value = call("get_%s" % snake_stat)
		#var info: Dictionary = call("get_%s_info" % snake_stat)
		#print(info.keys())
		#var base: int = info.get("background", 0)
		#var bonus := get_bonus_amount(info)
		#return [stat, value, base, bonus]
	#
	#match snake_stat:
		#"background":
			#return [stat, background_stats.background]
		#"marbles":
			#var info := get_max_marbles_info()
			#var base = info.background
			#var bonus: int = get_bonus_amount(info)
			#return [stat, get_max_marbles(), base, bonus]
		#"core_integrity":
			#return [stat, frame_stats.core_integrity]
		#"unlocks":
			#var info := get_max_unlocks_info()
			#return [stat, get_max_unlocks(), info.background, get_bonus_amount(info)]
		#"":
			#return []
		#_:
			#var error := "GearwrightCharacter: get_stat_label_text: unknown stat: %s" % stat
			#push_error(error)
			#return [error]







# TODO probably yeet this huh
#func get_stat_label_text(stat: String) -> String:
	#var snake_stat := stat.to_snake_case()
	#if snake_stat in [
			#"close",
			#"far",
			#"mental",
			#"power",
			#"evasion",
			#"willpower",
			#"ap",
			#"speed",
			#"sensors",
			#"repair_kits",
			#"weight",
			#"weight_cap",
			#"ballast",
			#]:
		#var value = call("get_%s" % snake_stat)
		#return "%s: %s" % [stat, value]
	#
	#match snake_stat:
		#"background":
			#return "%s: %s" % [stat, background_stats.background]
		#"marbles":
			#return "%s: %s" % [stat, get_max_marbles()]
		#"core_integrity":
			#return "%s: %s" % [stat, frame_stats.core_integrity]
		#"unlocks":
			#return "%s: %s" % [stat, get_max_unlocks()]
		#"":
			#return ""
		#_:
			#var error := "GearwrightCharacter: get_stat_label_text: unknown stat: %s" % stat
			#push_error(error)
			#return error
	#
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

func get_stat_info(stat: String) -> Dictionary:
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
		return call("get_%s_info" % snake_stat)
	
	match snake_stat:
		"background":
			return {}
		"marbles":
			return get_max_marbles_info()
		"core_integrity":
			return {frame = frame_stats.core_integrity}
		"unlocks":
			return get_max_unlocks_info()
		"":
			return {}
		_:
			push_error("GearwrightCharacter: get_stat_info: unknown stat: %s" % stat)
			return {}

func get_stat_explanation(stat: String) -> String:
	var info := get_stat_info(stat)
	if info.is_empty():
		return ""
	else:
		return info_to_explanation_text(info)
	
	#var snake_stat := stat.to_snake_case()
	#if snake_stat in [
			#"close",
			#"far",
			#"mental",
			#"power",
			#"evasion",
			#"willpower",
			#"ap",
			#"speed",
			#"sensors",
			#"repair_kits",
			#"weight",
			#"weight_cap",
			#"ballast",
			#]:
		#var info: Dictionary = call("get_%s_info" % snake_stat)
		#return info_to_explanation_text(info)
	#
	#match snake_stat:
		#"background":
			#return ""
			## custom background explanation_text, maybe?
		#"marbles":
			#return info_to_explanation_text(get_max_marbles_info())
		#"core_integrity":
			#return info_to_explanation_text({frame = frame_stats.core_integrity})
		#"unlocks":
			#return info_to_explanation_text(get_max_unlocks_info())
		#"":
			#return ""
		#_:
			#push_error("GearwrightCharacter: get_stat_explanation: unknown stat: %s" % stat)
			#return ""

static func info_to_explanation_text(info: Dictionary) -> String:
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

#func sum_internals_for_stat(stat: String) -> int:
	#return sum_array(get_equipped_items().map(
			#func(info: Dictionary): return info.internal.item_data.get(stat, 0))
	#)

func has_unlocks_remaining() -> bool:
	return get_unlocked_slots_count() < get_max_unlocks()

func get_unlocked_slots_count() -> int:
	return  internal_inventory.get_unlocked_slots().size()

func is_overweight_with_item(item):
	var weight := get_weight()
	if item != null:
		weight += item.item_data.weight
	if weight > get_weight_cap():
		return true
	else:
		return false


# Vet your info before calling this function!
func get_grid_slot(gsid: int, x: int, y: int) -> GridSlot:
	return internal_inventory.get_grid_slot(gsid, x, y)

func get_level_development_count():
	if not level_stats.has("developments"):
		push_error("GearwrightCharacter: no development info in level: %s" % str(level_stats))
		return 0
	return level_stats.developments

func get_custom_bg_points_remaining():
	var result = 4 - custom_background.size()
	assert(0 <= result and result <= 4)
	return result

func grid_array_index_to_slot_info(index: int):
	return internal_inventory.grid_array_index_to_slot_info(index)

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
	return global_util.sum_array(get_max_marbles_info().values())


func get_close_info() -> Dictionary:
	return {
		frame = frame_stats.close,
		internals = internal_inventory.sum_internals_for_stat("close")
	}

func get_close() -> int:
	return global_util.sum_array(get_close_info().values())

func get_far_info() -> Dictionary:
	return {
		frame = frame_stats.far,
		internals = internal_inventory.sum_internals_for_stat("far")
	}

func get_far() -> int:
	return global_util.sum_array(get_far_info().values())

func get_mental_info() -> Dictionary:
	return add_dev_info("mental", {
		background = get_bg_amount("mental")
		# internals TODO fish have this
	})

func get_mental() -> int:
	return global_util.sum_array(get_mental_info().values())

func get_power_info() -> Dictionary:
	return {
		frame = frame_stats.power,
		internals = internal_inventory.sum_internals_for_stat("power"),
	}

func get_power() -> int:
	return global_util.sum_array(get_power_info().values())

func get_evasion_info() -> Dictionary:
	return {
		frame = frame_stats.evasion,
		internals = internal_inventory.sum_internals_for_stat("evasion")
	}

func get_evasion() -> int:
	return global_util.sum_array(get_evasion_info().values())

func get_willpower_info() -> Dictionary:
	return add_dev_info("willpower", {
		background = get_bg_amount("willpower"),
		# fish internals TODO
	})

func get_willpower() -> int:
	return global_util.sum_array(get_willpower_info().values())

func get_ap_info() -> Dictionary:
	return {
		frame = frame_stats.ap,
		internals = internal_inventory.sum_internals_for_stat("ap"),
	}

func get_ap() -> int:
	return global_util.sum_array(get_ap_info().values())

func get_speed_info() -> Dictionary:
	return {
		frame = frame_stats.speed,
		internals = internal_inventory.sum_internals_for_stat("speed"),
	}

func get_speed() -> int:
	return global_util.sum_array(get_speed_info().values())

func get_sensors_info() -> Dictionary:
	return {
		frame = frame_stats.sensors,
		internals = internal_inventory.sum_internals_for_stat("sensors"),
	}

func get_sensors() -> int:
	return global_util.sum_array(get_sensors_info().values())

func get_repair_kits_info() -> Dictionary:
	return add_dev_info("repair_kits", {
		frame = frame_stats.repair_kits,
		internals = internal_inventory.sum_internals_for_stat("repair_kits"),
	})

func get_repair_kits() -> int:
	return global_util.sum_array(get_repair_kits_info().values())

func get_max_unlocks_info() -> Dictionary:
	return add_dev_info("unlocks", {
		background = get_bg_amount("unlocks"),
		level = level_stats.unlocks,
	})

func get_max_unlocks() -> int:
	return global_util.sum_array(get_max_unlocks_info().values())

func get_weight_info() -> Dictionary:
	return {
		internals = internal_inventory.sum_internals_for_stat("weight")
	}

func get_weight() -> int:
	return global_util.sum_array(get_weight_info().values())

func get_weight_cap_info() -> Dictionary:
	var result := {
		background = get_bg_amount("weight_cap"),
		frame = frame_stats.weight_cap,
		level = level_stats.weight_cap,
		internals = internal_inventory.sum_internals_for_stat("weight_cap"),
	}
	result = add_dev_info("weight_cap", result)
	return result

func get_weight_cap() -> int:
	return global_util.sum_array(get_weight_cap_info().values())

func get_ballast_info() -> Dictionary:
	var ballast_from_weight: int = weight_to_ballast(get_weight())
	var result = {
		frame = frame_stats.ballast,
		weight = ballast_from_weight,
		internals = internal_inventory.sum_internals_for_stat("ballast"),
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
	var value: int = global_util.sum_array(get_ballast_info().values())
	return clamp(value, 1, 10)

func get_deep_word_count_info() -> Dictionary:
	return add_dev_info("deep_words", {})

func get_deep_word_count() -> int:
	return global_util.sum_array(get_deep_word_count_info().values())

func get_maneuver_count_info() -> Dictionary:
	var result := {
		level = level_stats.maneuvers
	}
	if 6 <= get_mental():
		result.mental = 1
	return result

func get_maneuver_count() -> int:
	return global_util.sum_array(get_maneuver_count_info().values())

#func get__info() -> Dictionary:
	#return {
		#
	#}
#
#func get_() -> int:
	#return sum_array(get__info().values())

func get_core_integrity() -> int:
	return frame_stats.core_integrity

#endregion






#region Mutation

# yeets all equipped internals
# resets unlocks to nothing
# reapplies default unlocks from frame
func reset_gear_sections():
	internal_inventory.full_reset()
	
	var default_unlocks: Array = frame_stats.default_unlocks
	for index in default_unlocks:
		#grid_array[index].unlock()
		var info := internal_inventory.grid_array_index_to_slot_info(index)
		var grid_slot: GridSlot = get_grid_slot(info.gear_section_id, info.x, info.y)
		grid_slot.is_locked = false
		grid_slot.is_default_unlock = true

func equip_internal(item, gear_section_id: int, primary_cell: Vector2i) -> Array:
	var errors := check_internal_equip_validity(item, gear_section_id, primary_cell)
	if errors.is_empty():
		return internal_inventory.equip_internal(item, gear_section_id, primary_cell)
	else:
		return errors

func unequip_internal(item, gear_section_id: int):
	return internal_inventory.unequip_internal(item, gear_section_id)

# TODO yeet this???
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

func set_perk(perk_type: PerkOptionButton.PERK_TYPE, slot: int, name: String):
	match perk_type:
		PerkOptionButton.PERK_TYPE.DEVELOPMENT:
			if not name.is_empty():
				DataHandler.get_development_data(name) # trigger popup
			_edit_perk(developments, get_level_development_count(), slot, name)
		PerkOptionButton.PERK_TYPE.MANEUVER:
			if not name.is_empty():
				DataHandler.get_maneuver_data(name) # trigger popup
			_edit_perk(maneuvers, get_maneuver_count(), slot, name)
		PerkOptionButton.PERK_TYPE.DEEP_WORD:
			if not name.is_empty():
				DataHandler.get_deep_word_data(name) # trigger popup
			_edit_perk(deep_words, get_deep_word_count(), slot, name)

func _edit_perk(list: Array, list_size: int, slot: int, name: String):
	while list.size() < list_size:
		list.append("")
	while list.size() > list_size:
		list.pop_back()
	assert(slot >= 0)
	assert(slot < list_size)
	list[slot] = name

#func set_development(slot: int, name: String):
	#if not name.is_empty():
		#DataHandler.get_development_data(name) # trigger popup
	#assert(slot >= 0)
	#assert(slot < developments.size())
	#developments[slot] = name
#
#func set_maneuver(slot: int, name: String):
	#while maneuvers.size() < get_maneuver_count():
		#maneuvers.append("")
	#while maneuvers.size() > get_maneuver_count():
		#maneuvers.pop_back()
	#
	#if not name.is_empty():
		#DataHandler.get_development_data(name) # trigger popup
	#assert(slot >= 0)
	#assert(slot < maneuvers.size())
	#maneuvers[slot] = name
#
#func set_deep_word(slot: int, name: String):
	#while deep_words.size() < get_maneuver_count():
		#maneuvers.append("")
	#while maneuvers.size() > get_maneuver_count():
		#maneuvers.pop_back()
	#
	#if not name.is_empty():
		#DataHandler.get_development_data(name) # trigger popup
	#assert(slot >= 0)
	#assert(slot < maneuvers.size())
	#maneuvers[slot] = name

#func add_development(name: String):
	#DataHandler.get_development_data(name) # trigger popup
	#developments.append(name)

#func remove_development(name: String):
	#developments.erase(name)

# returns a dictionary of relevant developments
# keys are development names, values are development stat blocks
func find_devs_that_modify(stat: String) -> Dictionary:
	var result = {}
	for dev_name in developments:
		if dev_name.is_empty():
			continue
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

func modify_custom_background(stat: String, is_increase: bool):
	if not stat in custom_background_caps.keys():
		push_error("mystery custom bg stat: %s" % stat)
		breakpoint
		return
	var current_count := custom_background.count(stat)
	var cap: int = custom_background_caps[stat]
	if is_increase and (current_count < cap) and (0 < get_custom_bg_points_remaining()):
		custom_background.append(stat)
	elif not is_increase:
		custom_background.erase(stat)

#endregion






#region save & load

func load_frame(name: String):
	global_util.fancy_print("applying frame: %s" % name)
	frame_name = name
	frame_stats = DataHandler.get_thing_nicely(DataHandler.DATA_TYPE.FRAME, name)
	reset_gear_sections()

func load_background(bg_id: String):
	global_util.fancy_print("applying background: %s" % bg_id)
	if bg_id != "custom":
		custom_background.clear()
	background_stats = DataHandler.get_thing_nicely(DataHandler.DATA_TYPE.BACKGROUND, bg_id)

# might be int, might be string
func set_level(new_level):
	if new_level is String:
		new_level = int(new_level)
	level = new_level
	global_util.fancy_print("applying level: %d" % level)
	level_stats = DataHandler.get_thing_nicely(DataHandler.DATA_TYPE.LEVEL, str(level))
	
	while developments.size() < level_stats.developments:
		developments.append("")
	while developments.size() > level_stats.developments:
		developments.pop_back()
	
	while maneuvers.size() < level_stats.maneuvers:
		maneuvers.append("")
	while maneuvers.size() > level_stats.maneuvers:
		maneuvers.pop_back()

func marshal() -> Dictionary:
	var result := {
		callsign = callsign,
		frame = frame_name,
		background = background_stats.background.to_snake_case(),
		level = str(level)
	}
	
	result.custom_background = custom_background
	
	#var unlocks_info = []
	#for real_slot_info in internal_inventory.get_unlocked_slots():
		#var json_slot_info = make_slot_info(real_slot_info.gear_section_id, real_slot_info.grid_slot_coords)
		#unlocks_info.append(json_slot_info)
	var unlocks_info := {}
	var unlocks_by_gs := internal_inventory.get_unlocked_slots_by_gear_section()
	for gsid in unlocks_by_gs.keys():
		unlocks_info[gsids_to_names[gsid]] = unlocks_by_gs[gsid].map(func(coords: Vector2i):
			return global.vector_to_dictionary(coords)
			)
	result.unlocks = unlocks_info
	
	#result.internals = internal_inventory.get_equipped_items(false)
	var internals_info := {}
	var internals_by_gs := internal_inventory.get_equipped_items_by_gs(false)
	for gsid in internals_by_gs.keys():
		internals_info[gsids_to_names[gsid]] = internals_by_gs[gsid].map(func(info: Dictionary):
			info.slot = global.vector_to_dictionary(info.slot)
			return info
			)
	result.internals = internals_info
	
	result.developments = developments.duplicate(true)
	result.maneuvers = maneuvers.duplicate(true)
	result.deep_words = deep_words.duplicate(true)
	
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
# FIXME unduplicate in gearwright character and internal inventory
func make_slot_info(gear_section_id: int, cell: Vector2i) -> Dictionary:
	return {
		gear_section_name = gear_section_id_to_name(gear_section_id),
		gear_section_id = gear_section_id,
		x = cell.x,
		y = cell.y,
	}

#endregion




#region static functions

const gsids_to_names := {
	CHARACTER_GSIDS.TORSO: "torso",
	CHARACTER_GSIDS.LEFT_ARM: "left_arm",
	CHARACTER_GSIDS.RIGHT_ARM: "right_arm",
	CHARACTER_GSIDS.HEAD: "head",
	CHARACTER_GSIDS.LEGS: "legs",
}

static func gear_section_id_to_name(id: int) -> String:
	return gsids_to_names.get(id, "unknown gear section id: %d" % id)
	#match id:
		#CHARACTER_GSIDS.TORSO:
			#return "torso"
		#CHARACTER_GSIDS.LEFT_ARM:
			#return "left_arm"
		#CHARACTER_GSIDS.RIGHT_ARM:
			#return "right_arm"
		#CHARACTER_GSIDS.HEAD:
			#return "head"
		#CHARACTER_GSIDS.LEGS:
			#return "legs"
		#_:
			#return "unknown gear section id: %d" % id

static func gear_section_name_to_id(name: String) -> int:
	match name:
		"torso":
			return CHARACTER_GSIDS.TORSO
		"left_arm":
			return CHARACTER_GSIDS.LEFT_ARM
		"right_arm":
			return CHARACTER_GSIDS.RIGHT_ARM
		"head":
			return CHARACTER_GSIDS.HEAD
		"legs":
			return CHARACTER_GSIDS.LEGS
		_:
			return -1

# section_name is from item_data.json
# returns a list of valid gear_section_ids based on that name
static func item_section_to_valid_section_ids(section_name: String) -> Array:
	match section_name:
		"leg":
			return [CHARACTER_GSIDS.LEGS]
		"arm":
			var arms = [
				CHARACTER_GSIDS.LEFT_ARM,
				CHARACTER_GSIDS.RIGHT_ARM,
			]
			return arms
		"head":
			return [CHARACTER_GSIDS.HEAD]
		"chest":
			return [CHARACTER_GSIDS.TORSO]
		"any":
			return CHARACTER_GSIDS.values()
		_:
			push_error("gearwright_character: unknown item section: %s" % section_name)
			return []


static func unmarshal(info: Dictionary) -> GearwrightCharacter:
	var sesh := start_unmarshalling_session(info)
	
	var ch := GearwrightCharacter.new()
	ch.callsign = sesh.get_info("callsign")
	ch.load_frame(sesh.get_info("frame"))
	ch.load_background(sesh.get_info("background"))
	ch.set_level(sesh.get_info("level", 1))
	
	ch.custom_background = sesh.get_info("custom_background", [])
	# not sure why this was here
	#if ch.custom_background.is_empty():
		# breakpoint
	
	var unlocks_raw_data = sesh.get_info("unlocks")
	var unlocks_slot_infos := [] # list of make_slot_info results
	if unlocks_raw_data == null:
		sesh.errors.append("No unlocks found!")
	elif unlocks_raw_data is Array:
		# old style
		sesh.errors.append("Unlocks save format is from a previous version, attempting conversion")
		var unlocks_list: Array = unlocks_raw_data as Array
		for unlock_index in unlocks_list:
			var unlock_slot_info = ch.grid_array_index_to_slot_info(int(unlock_index))
			unlocks_slot_infos.append(unlock_slot_info)
	elif unlocks_raw_data is Dictionary:
		# new style
		var unlocks_info: Dictionary = unlocks_raw_data as Dictionary
		for gs_name in unlocks_info.keys():
			var gsid := gear_section_name_to_id(gs_name)
			var unlocks_list: Array = unlocks_info[gs_name]
			for unlock_slot_data in unlocks_list:
				unlocks_slot_infos.append(ch.make_slot_info(gsid, global.dictionary_to_vector2i(unlock_slot_data)))
	
	# unlocks_slot_infos should now be in make_slot_info format
	for unlock_slot_info in unlocks_slot_infos:
		if not ch.toggle_unlock(unlock_slot_info.gear_section_id, unlock_slot_info.x, unlock_slot_info.y):
			sesh.errors.append("  failed to unlock %s" % str(unlock_slot_info))
		
		#var grid_slot: GridSlot = ch.get_grid_slot(unlock_info.gear_section_id, unlock_info.x, unlock_info.y)
		#grid_slot.is_locked = false
	
	#var unlocks_info = []
	#for real_slot_info in get_unlocked_slots():
		#var json_slot_info = make_slot_info(real_slot_info.gear_section_id, real_slot_info.grid_slot_coords)
		#unlocks_info.append(json_slot_info)
	#result.unlocks = unlocks_info
	
	
	var internals := sesh.get_info("internals", {}) as Dictionary
	if internals.is_empty():
		# maybe this isn't an error?
		sesh.errors.append("No internals found!")
	else:
		var first_key = internals.keys().front()
		if (first_key == "0") or (int(first_key) != 0):
			# old style
			sesh.errors.append("Internals save format is from a previous version, attempting conversion")
			var new_internals := {}
			for slot_index in internals.keys():
				# gear_section_name, gear_section_id, x, y
				var slot_info: Dictionary = ch.grid_array_index_to_slot_info(int(slot_index))
				var internal_name = internals[slot_index]
				if not new_internals.has(slot_info.gear_section_name):
					new_internals[slot_info.gear_section_name] = []
				# fuck json
				var internal_info := {
					slot = global.vector_to_dictionary(Vector2i(slot_info.x, slot_info.y)),
					internal_name = internal_name,
				}
				new_internals[slot_info.gear_section_name].append(internal_info)
			internals = new_internals
		
		# new style
		for gs_name in internals.keys():
			var gsid := gear_section_name_to_id(gs_name)
			var gs_internals_list: Array = internals[gs_name]
			for i in range(gs_internals_list.size()):
				# internal_info.slot: dictionary
				#   x, y
				# internal_info.internal: string
				var internal_info: Dictionary = gs_internals_list[i]
				var new_internal = item_scene.instantiate()
				new_internal.load_item(internal_info.internal_name)
				var primary_cell := global.dictionary_to_vector2i(internal_info.slot) # fuck json
				var errors := ch.equip_internal(new_internal, gsid, primary_cell)
				if not errors.is_empty():
					sesh.errors.append("  failed to install internal: %s (%s)" % [internal_info, str(errors)])
	
	ch.developments = sesh.get_info("developments", [])
	ch.maneuvers = sesh.get_info("maneuvers", [])
	ch.deep_words = sesh.get_info("deep_words", [])
	
	finish_unmarshalling_session(sesh)
	
	return ch

#endregion




