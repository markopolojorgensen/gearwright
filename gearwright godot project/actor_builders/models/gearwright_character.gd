extends GearwrightActor
class_name GearwrightCharacter

# represents a single character in gearwright
# one gear loadout, one callsign, etc.

const non_cyclic_item_scene = preload("res://actor_builders/inventory_system/Item.tscn")

# keys in game data json files
var frame_name := ""
var level: int = 1
var backlash: int = 0
var current_marbles: int = -1

var developments := []
var maneuvers := []
var mental_maneuver := ""
var deep_words := []

var frame_stats := DataHandler.frame_stats_template.duplicate(true)
var level_stats := DataHandler.level_stats_template.duplicate(true)
var background_stats := DataHandler.background_stats_template.duplicate(true)
var custom_background_name := ""
var custom_background := []
const custom_background_caps := {
	"marbles":    2,
	"willpower":  4,
	"mental":     4,
	"unlocks":    1,
	"weight_cap": 1,
}

var enforce_weight_cap := true
var enforce_hardpoint_cap := true

# string -> int
var manual_stat_adjustments := {}
# lists of string label_ids
var labels := ["fishing_gear", "diving_suit"]
var custom_labels := []
# key: label_id String
# value: label_info Dictionary
#   see DataHandler label_template
var custom_label_info := {}


#region Initialization

func _init():
	internal_inventory.create_character_gear_sections()
	if not DataHandler.frame_data.keys().is_empty():
		load_frame(DataHandler.frame_data.keys().front())

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
	if enforce_weight_cap and is_overweight_with_item(item):
		errors.append("Too much weight")
	
	# wrong section (e.g. trying to put head gear in leg)
	var valid_section_ids := item_section_to_valid_section_ids(item.item_data.section)
	if not gear_section_id in valid_section_ids:
		errors.append("%s can't go in %s section" % [item.item_data.name, gear_section_id_to_name(gear_section_id).capitalize()])
	
	errors.append_array(internal_inventory.check_internal_equip_validity(item, gear_section_id, primary_cell, enforce_tags))
	
	return errors

func get_equipped_items() -> Array:
	return internal_inventory.get_equipped_items()

func has_gear_section(gsid: int) -> bool:
	return internal_inventory.gear_sections.has(gsid)

func get_gear_section(gsid: int) -> GearSection:
	return internal_inventory.gear_sections[gsid]

func get_stat(stat: String) -> int:
	if stat == "ballast":
		return get_ballast()
	else:
		return global_util.sum_array(get_stat_info(stat).values())

func get_stat_info(stat: String) -> Dictionary:
	var snake_stat := stat.to_snake_case()
	if snake_stat in [
			"marbles",
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
			"unlocks",
			]:
		return get_basic_info(snake_stat)
		#return call("get_%s_info" % snake_stat)
	
	match snake_stat:
		"background":
			return {}
		"core_integrity":
			var result := {frame = frame_stats.core_integrity}
			result = _add_nonzero_kv_pair(result, "manual adj", get_manual_stat_adjustment("core_integrity"))
			return result
		"ballast":
			return get_ballast_info()
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

static func info_to_explanation_text(info: Dictionary) -> String:
	var result := ""
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
	
	# trim trailing newline
	if result.ends_with("\n"):
		result = result.left(-1)
	
	return result

func has_unlocks_remaining() -> bool:
	if enforce_hardpoint_cap:
		return get_unlocked_slots_count() < get_stat("unlocks")
	else:
		return true

func get_unlocked_slots_count() -> int:
	return  internal_inventory.get_unlocked_slots().size()

func is_overweight_with_item(item):
	var weight := get_stat("weight")
	var weight_cap := get_stat("weight_cap")
	if item != null:
		weight += item.item_data.weight
		weight_cap += item.item_data.weight_cap
	if weight > weight_cap:
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
	return level_stats.developments + get_manual_stat_adjustment("developments")

func get_custom_bg_points_remaining():
	var result = 4 - custom_background.size()
	assert(0 <= result and result <= 4)
	return result

func grid_array_index_to_slot_info(index: int):
	return internal_inventory.grid_array_index_to_slot_info(index)

func are_marbles_quantum():
	return current_marbles == -1

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
	var bg_amount: int = background_stats.get(stat, 0)
	if background_stats.background.to_lower() == "custom":
		bg_amount += custom_background.count(stat) * mults.get(stat, 0)
	return bg_amount

func get_manual_stat_adjustment(stat: String) -> int:
	stat = stat.to_snake_case()
	return manual_stat_adjustments.get(stat, 0)

func get_ballast_info() -> Dictionary:
	var ballast_from_weight: int = weight_to_ballast(get_stat("weight"))
	var result = {
		frame = frame_stats.ballast,
		weight = ballast_from_weight,
		internals = internal_inventory.sum_internals_for_stat("ballast"),
	}
	const LIGHTWEIGHT := "lightweight_modifier"
	var lightweight_info := _add_dev_info(LIGHTWEIGHT, {})
	if not lightweight_info.is_empty():
		var dev_name: String = lightweight_info.keys()[0]
		var adjusted_weight: int = get_stat("weight") - lightweight_info[dev_name]
		var ballast_from_adjusted_weight: int = weight_to_ballast(adjusted_weight)
		var ballast_effect = ballast_from_adjusted_weight - ballast_from_weight
		result[dev_name] = ballast_effect
	
	result = _add_nonzero_kv_pair(result, "manual adj", get_manual_stat_adjustment("ballast"))
	
	return result

func weight_to_ballast(weight: int) -> int:
	@warning_ignore("integer_division")
	var result: int = weight / 5
	return result

func get_ballast() -> int:
	var value: int = global_util.sum_array(get_ballast_info().values())
	return clamp(value, 1, 10)

#func get_deep_word_count_info() -> Dictionary:
	#return add_dev_info("deep_words", {})

func get_deep_word_count() -> int:
	return developments.count("a_brush_with_the_deep") + get_manual_stat_adjustment("deep_words")
	#return global_util.sum_array(get_deep_word_count_info().values())

func get_maneuver_count_info(include_mental := true) -> Dictionary:
	var result := {
		level = level_stats.maneuvers
	}
	if include_mental and (6 <= get_stat("mental")):
		result.mental = 1
	result = _add_nonzero_kv_pair(result, "manual adj", get_manual_stat_adjustment("maneuvers"))
	return result

func get_maneuver_count(include_mental := true) -> int:
	return global_util.sum_array(get_maneuver_count_info(include_mental).values())

func has_mental_maneuver():
	return get_maneuver_count_info(true).has("mental")

func get_maneuvers(include_mental := true) -> Array:
	if include_mental:
		return maneuvers + [mental_maneuver]
	else:
		return maneuvers

#func get__info() -> Dictionary:
	#return {
		#
	#}
#
#func get_() -> int:
	#return sum_array(get__info().values())

func get_core_integrity() -> int:
	#return frame_stats.core_integrity
	return global_util.sum_array(get_stat_info("core_integrity").values())

func get_basic_info(stat_name: String) -> Dictionary:
	stat_name = stat_name.to_snake_case()
	var result := {}
	result = _add_nonzero_kv_pair(result, "background", get_bg_amount(stat_name))
	result = _add_nonzero_kv_pair(result, "frame", frame_stats.get(stat_name, 0))
	result = _add_nonzero_kv_pair(result, "level", level_stats.get(stat_name, 0))
	result = _add_nonzero_kv_pair(result, "internals", internal_inventory.sum_internals_for_stat(stat_name))
	result = _add_dev_info(stat_name, result)
	result = _add_nonzero_kv_pair(result, "manual adj", get_manual_stat_adjustment(stat_name))
	return result

func _add_nonzero_kv_pair(dictionary: Dictionary, key, value: int) -> Dictionary:
	if value != 0:
		dictionary[key] = value
	return dictionary

#endregion






#region Mutation

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

# returns an error message, or an empty string if everything's fine
func set_perk(perk_type: PerkOptionButton.PERK_TYPE, slot: int, name: String) -> String:
	match perk_type:
		PerkOptionButton.PERK_TYPE.DEVELOPMENT:
			if not name.is_empty():
				DataHandler.get_development_data(name) # trigger popup
			if (name in ["", "a_brush_with_the_deep"]) or (not name in developments):
				_edit_perk(developments, get_level_development_count(), slot, name)
			else:
				# repeat development
				return "Fisher already has development '%s'" % name.capitalize()
		PerkOptionButton.PERK_TYPE.MANEUVER:
			if not name.is_empty():
				DataHandler.get_maneuver_data(name) # trigger popup
			
			var devs = maneuvers.duplicate()
			devs.append(mental_maneuver)
			if (name != "") and (name in devs):
				return "Fisher already has maneuver '%s'" % name.capitalize()
			
			if 0 <= slot:
				_edit_perk(maneuvers, get_maneuver_count(), slot, name)
			elif slot == -1:
				mental_maneuver = name
		PerkOptionButton.PERK_TYPE.DEEP_WORD:
			if not name.is_empty():
				DataHandler.get_deep_word_data(name) # trigger popup
			if (name != "") and (name in deep_words):
				return "Fisher already knows %s" % name.capitalize()
			_edit_perk(deep_words, get_deep_word_count(), slot, name)
	return ""

func _edit_perk(list: Array, list_size: int, slot: int, name: String):
	while list.size() < list_size:
		list.append("")
	while list.size() > list_size:
		list.pop_back()
	assert(slot >= 0)
	assert(slot < list_size)
	list[slot] = name

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
func _add_dev_info(stat_name: String, stat_info: Dictionary) -> Dictionary:
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

func manual_stat_increase(stat_name: String):
	manual_stat_change(stat_name, 1)

func manual_stat_decrease(stat_name: String):
	manual_stat_change(stat_name, -1)

func manual_stat_change(stat_name: String, change: int):
	stat_name = stat_name.to_snake_case()
	var old_value = manual_stat_adjustments.get(stat_name, 0)
	var new_value = old_value + change
	if new_value == 0:
		manual_stat_adjustments.erase(stat_name)
	else:
		manual_stat_adjustments[stat_name] = new_value

func add_label(label_id: String):
	global_util.fancy_print("adding label %s" % label_id)
	labels.append(label_id)

func remove_label(label_id: String):
	labels.erase(label_id)
	custom_labels.erase(label_id)
	
	var to_erase := []
	for custom_label_id in custom_label_info.keys():
		if not custom_label_id in custom_labels:
			to_erase.append(custom_label_id)
	for custom_label_id in to_erase:
		custom_label_info.erase(custom_label_id)

# overrites previous entries
func add_custom_label(label_id: String, label_info: Dictionary):
	custom_label_info[label_id] = label_info
	custom_labels.append(label_id)

func modify_current_marbles(amount: int):
	if are_marbles_quantum():
		collapse_quantum_marbles()
	current_marbles = clamp(current_marbles + amount, 0, get_stat("marbles"))

func collapse_quantum_marbles():
	current_marbles = get_stat("marbles")

#endregion






#region save & load

func marshal(collapse_marbles := true) -> Dictionary:
	if collapse_marbles and are_marbles_quantum():
		collapse_quantum_marbles()
	
	var result := {
		callsign = callsign,
		frame = frame_name,
		background = background_stats.background.to_snake_case(),
		level = str(level),
		manual_stat_adjustments = manual_stat_adjustments.duplicate(),
		mental_maneuver = mental_maneuver,
		backlash = backlash,
		labels = labels.duplicate(),
		custom_labels = custom_labels.duplicate(),
		custom_label_info = custom_label_info.duplicate(),
		current_marbles = current_marbles,
		custom_background_name = custom_background_name,
	}
	
	result.custom_background = custom_background
	
	var unlocks_info := {}
	var unlocks_by_gs := internal_inventory.get_unlocked_slots_by_gear_section()
	for gsid in unlocks_by_gs.keys():
		unlocks_info[GSIDS_TO_NAMES[gsid]] = unlocks_by_gs[gsid].map(func(coords: Vector2i):
			return global.vector_to_dictionary(coords)
			)
	result.unlocks = unlocks_info
	
	var internals_info := {}
	var internals_by_gs := internal_inventory.get_equipped_items_by_gs(false)
	for gsid in internals_by_gs.keys():
		internals_info[GSIDS_TO_NAMES[gsid]] = internals_by_gs[gsid].map(func(info: Dictionary):
			info.slot = global.vector_to_dictionary(info.slot)
			return info
			)
	result.internals = internals_info
	
	result.developments = developments.duplicate(true)
	result.maneuvers = maneuvers.duplicate(true)
	result.deep_words = deep_words.duplicate(true)
	
	result.gearwright_version = version.VERSION
	
	return result

static func unmarshal(info: Dictionary) -> GearwrightCharacter:
	var sesh: UnmarshalSession = start_unmarshalling_session(info)
	
	var ch := GearwrightCharacter.new()
	# suspension might not get equipped before we hit weight cap, so ignore it
	# other things too, ignore it all until everything is loaded
	ch.enforce_weight_cap = false
	ch.enforce_hardpoint_cap = false
	ch.enforce_tags = false
	
	ch.callsign = sesh.get_info("callsign")
	ch.load_frame(sesh.get_info("frame"))
	ch.load_background(sesh.get_info("background"))
	ch.set_level(sesh.get_info("level", 1))
	ch.manual_stat_adjustments = sesh.get_info("manual_stat_adjustments", {})
	ch.mental_maneuver = sesh.get_info("mental_maneuver")
	ch.backlash = sesh.get_info("backlash", 0)
	ch.labels = sesh.get_info("labels", [])
	ch.custom_labels = sesh.get_info("custom_labels", [])
	ch.custom_label_info = sesh.get_info("custom_label_info", {})
	ch.current_marbles = sesh.get_info("current_marbles", 0)
	ch.developments = sesh.get_info("developments", [])
	ch.maneuvers = sesh.get_info("maneuvers", [])
	ch.deep_words = sesh.get_info("deep_words", [])
	ch.custom_background = sesh.get_info("custom_background", [])
	ch.custom_background_name = sesh.get_info("custom_background_name")
	
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
				unlocks_slot_infos.append(global.make_slot_info(gsid, global.dictionary_to_vector2i(unlock_slot_data)))
	
	# unlocks_slot_infos should now be in make_slot_info format
	for unlock_slot_info in unlocks_slot_infos:
		if not ch.toggle_unlock(unlock_slot_info.gear_section_id, unlock_slot_info.x, unlock_slot_info.y):
			sesh.errors.append("  failed to unlock %s" % str(unlock_slot_info))
	
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
				internal_info.internal_name = (internal_info.internal_name as String).replacen("cam", "optics")
				var new_internal = non_cyclic_item_scene.instantiate()
				new_internal.load_item(internal_info.internal_name)
				var primary_cell := global.dictionary_to_vector2i(internal_info.slot) # fuck json
				var errors: Array = ch.equip_internal(new_internal, gsid, primary_cell)
				if not errors.is_empty():
					sesh.errors.append("  failed to install internal: %s (%s)" % [internal_info, str(errors)])
	
	#ch.enforce_weight_cap = true
	#ch.enforce_hardpoint_cap = true
	#ch.enforce_tags = true
	
	finish_unmarshalling_session(sesh)
	
	return ch

#endregion




#region static functions

static func gear_section_name_to_id(name: String) -> int:
	match name:
		"torso":
			return GSIDS.FISHER_TORSO
		"left_arm":
			return GSIDS.FISHER_LEFT_ARM
		"right_arm":
			return GSIDS.FISHER_RIGHT_ARM
		"head":
			return GSIDS.FISHER_HEAD
		"legs":
			return GSIDS.FISHER_LEGS
		_:
			return -1

# section_name is from item_data.json
# returns a list of valid gear_section_ids based on that name
static func item_section_to_valid_section_ids(section_name: String) -> Array:
	match section_name:
		"leg":
			return [GSIDS.FISHER_LEGS]
		"arm":
			var arms = [
				GSIDS.FISHER_LEFT_ARM,
				GSIDS.FISHER_RIGHT_ARM,
			]
			return arms
		"head":
			return [GSIDS.FISHER_HEAD]
		"chest":
			return [GSIDS.FISHER_TORSO]
		"any":
			return GSIDS.values()
		_:
			push_error("gearwright_character: unknown item section: %s" % section_name)
			return []

#endregion




