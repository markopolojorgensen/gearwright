extends RefCounted
class_name GearwrightCharacter

# represents a single character in gearwright
# one gear loadout, one callsign, etc.

# definitely keep these
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
var background_stats := DataHandler.background_stats_template.duplicate(true)
var custom_background := {}
var level_stats := DataHandler.level_stats_template.duplicate(true)






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

# return value keys are gear_section_ids
func get_equipped_items() -> Dictionary:
	var result := {}
	for gear_section_id in gear_section_ids.values():
		var list := []
		var gear_section: GearSection = gear_sections[gear_section_id]
		list.append_array(gear_section.get_equipped_items())
		result[gear_section_id] = list
	return result

# all internals, without gear_section info
func get_equipped_items_list() -> Array:
	return get_equipped_items().values().reduce(func(result: Array, list: Array):
			result.append_array(list)
			return result,
			[]
		)

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
			# TODO: custom background explanation_text, probably
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
		
		result += "%s: %s\n" % [key, number_string]
	return result

func sum_internals_for_stat(stat: String) -> int:
	return sum_array(get_equipped_items_list().map(
			func(item): return item.item_data.get(stat, 0)))

func has_unlocks_remaining() -> bool:
	return get_unlocked_slots().size() < get_max_unlocks()

#endregion











#region Stat Info



func get_max_marbles_info() -> Dictionary:
	return {
		background = background_stats.marbles
	}

# background + developments TODO
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
	return {
		background = background_stats.mental,
		# developments TODO
		# internals TODO fish have this
	}

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
	return {
		background = background_stats.willpower
		# developments TODO
		# fish internals TODO
	}

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
	return {
		frame = frame_stats.repair_kits,
		internals = sum_internals_for_stat("repair_kits"),
		# developments TODO
	}

func get_repair_kits() -> int:
	return sum_array(get_repair_kits_info().values())

# background + level + developments TODO
func get_max_unlocks_info() -> Dictionary:
	return {
		background = background_stats.unlocks,
		level = level_stats.unlocks,
	}

func get_max_unlocks() -> int:
	return sum_array(get_max_unlocks_info().values())

func get_weight_info() -> Dictionary:
	return {
		internals = sum_internals_for_stat("weight")
	}

func get_weight() -> int:
	return sum_array(get_weight_info().values())

# background + frame + level + developments TODO
func get_weight_cap_info() -> Dictionary:
	var result := {
		background = background_stats.weight_cap,
		frame = frame_stats.weight_cap,
		level = level_stats.weight_cap,
	}
	return result

func get_weight_cap() -> int:
	return sum_array(get_weight_cap_info().values())

func get_ballast_info() -> Dictionary:
	@warning_ignore("integer_division")
	var internal_ballast = get_weight() / 5
	return {
		frame = frame_stats.ballast,
		weight = internal_ballast,
		internals = sum_internals_for_stat("ballast"),
	}

func get_ballast() -> int:
	return sum_array(get_ballast_info().values())




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
		var info := grid_array_index_to_gear_section_info(index)
		var grid_slot: GridSlot = info.grid_slot
		grid_slot.is_locked = false
		grid_slot.is_default_unlock = true

# yeets all equipped internals
func unequip_all_internals():
	for gear_section_id in gear_section_ids.values():
		var gear_section: GearSection = gear_sections[gear_section_id]
		gear_section.unequip_all_internals()

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

# returns dictionary with keys gear_section_id, gear_section, grid_slot, x, y
func grid_array_index_to_gear_section_info(index: int) -> Dictionary:
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
	result.grid_slot = gear_section.grid.get_contents(x, y)
	assert(0 <= result.x)
	assert(0 <= result.y)
	assert(result.x < gear_section.grid.size.x)
	assert(result.y < gear_section.grid.size.y)
	return result

func marshal() -> Dictionary:
	var result := {
		callsign = callsign,
		frame = frame_name,
		background = background_stats.background,
		level = str(level)
	}
	
	var internals_list := []
	for gear_section_id in gear_sections.keys():
		var gear_section: GearSection = gear_sections[gear_section_id]
		for cell in gear_section.grid.get_valid_entries():
			var grid_slot: GridSlot = gear_section.grid.get_contents_v(cell)
			if (grid_slot.installed_item != null) and (grid_slot.is_primary_install_point):
				var internal_info := {
					slot = make_slot_info(gear_section_id, cell),
					internal = grid_slot.installed_item.item_data.name.to_snake_case(),
				}
				internals_list.append(internal_info)
	result.internals = internals_list
	
	# TODO custom backgrounds
	
	var unlocks_info = []
	for real_slot_info in get_unlocked_slots():
		var json_slot_info = make_slot_info(real_slot_info.gear_section_id, real_slot_info.grid_slot_coords)
		unlocks_info.append(json_slot_info)
	result.unlocks = unlocks_info
	
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
		section = gear_section_id_to_name(gear_section_id),
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
	
	var internals = sesh.get_info("internals", [])
	for i in range(internals.size()):
		var internal_info: Dictionary = internals[i]
		# WHEREWASI
	#var internals_list := []
	#for gear_section_id in gear_sections.keys():
		#var gear_section: GearSection = gear_sections[gear_section_id]
		#for cell in gear_section.grid.get_valid_entries():
			#var grid_slot: GridSlot = gear_section.grid.get_contents_v(cell)
			#if (grid_slot.installed_item != null) and (grid_slot.is_primary_install_point):
				#var internal_info := {
					#slot = make_slot_info(gear_section_id, cell),
					#internal = grid_slot.installed_item.item_data.name.to_snake_case(),
				#}
				#internals_list.append(internal_info)
	#result.internals = internals_list
	#
	## TODO custom backgrounds
	#
	#var unlocks_info = []
	#for real_slot_info in get_unlocked_slots():
		#var json_slot_info = make_slot_info(real_slot_info.gear_section_id, real_slot_info.grid_slot_coords)
		#unlocks_info.append(json_slot_info)
	#result.unlocks = unlocks_info
	#
	## TODO developments
	## TODO manuevers
	## TODO deep words
	
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




