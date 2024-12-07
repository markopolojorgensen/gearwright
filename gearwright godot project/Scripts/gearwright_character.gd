extends RefCounted
class_name GearwrightCharacter

# represents a single character in gearwright
# one gear loadout, one callsign, etc.

# definitely keep these
var callsign := ""

# top level keys in game data json files
var frame_name := ""
var level := "-1"



#"frame": "",
#"internals": {},
#background # background_stats.background
var custom_background := []
# var unlocks := [] # use get_unlocked_slots()
var developments := []
var maneuvers := []
var deep_words := []


# idk, probably a bunch of these should get yeeted
#var marbles := 0
#var core_integrity := 0
#var close := 0
#var far := 0
#var mental := 0
#var power := 0
#var evasion := 0
#var willpower := 0
#var ap := 0
#var speed := 0
#var sensors := 0
#var repair_kits := 0
#var unlocks := 0 # number of unlocks, also see get_unlocked_slots()
#var default_unlocks := []
#var weight_cap := 0
#var weight := 0
#var ballast := 0

var gear_sections: Dictionary = create_gear_sections()
enum gear_section_ids {
	TORSO,
	LEFT_ARM,
	RIGHT_ARM,
	HEAD,
	LEGS,
	ANY,
}

# from load_frame()
# keys:
#   ap
#   ballast
#   close
#   core_integrity
#   default_unlocks
#   evasion
#   far
#   gear_ability
#   gear_ability_name
#   power
#   repair_kits
#   sensors
#   speed
#   weight
#   weight_cap
var frame_stats := {}

# from localData/fisher_backgrounds.json
# keys:
#   background
#   marbles
#   mental
#   willpower
#   deep_words
#   weight_cap
#   unlocks
#   description
var background_stats := {}

# from level_data.json
# keys:
#   unlocks
#   maneuvers
#   developments
#   weight_cap
#   shore_leave_stat
var level_stats := {}








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

func get_total_equipped_weight() -> int:
	var sections := gear_sections.values()
	var sum := 0
	for i in range(sections.size()):
		var gear_section: GearSection = sections[i]
		sum += gear_section.get_total_equipped_weight()
	return sum

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

# background + level + developments TODO
func get_max_unlocks() -> int:
	return background_stats.unlocks + level_stats.unlocks

func has_unlocks_remaining():
	return get_unlocked_slots().size() < get_max_unlocks()

# background + frame + level + developments TODO
func get_weight_cap():
	var sum := 0
	sum += background_stats.weight_cap
	sum += frame_stats.weight_cap
	sum += level_stats.weight_cap
	return sum

#endregion










#region save & load

func load_frame(data: Dictionary, name: String):
	frame_name = name
	#current_frame = a_Frame_name
	
	for gear_section in gear_sections.values():
		gear_section.reset()
	
	frame_stats = data
	var default_unlocks: Array = frame_stats.default_unlocks
	
	for index in default_unlocks:
		#grid_array[index].unlock()
		var info := grid_array_index_to_gear_section_info(index)
		var grid_slot: GridSlot = info.grid_slot
		grid_slot.is_locked = false
		grid_slot.is_default_unlock = true
	
	#gear_data["unlocks"].clear()
	#reset_lock_tally.emit()

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



func load_background(new_background_data: Dictionary):
	background_stats = new_background_data
	custom_background.clear()

func marshal_as_string() -> String:
	push_error("gearwright_character: marshal_as_string")
	return ""
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

#endregion




#region static functions

#static func gear_section_id_to_name(id: int) -> String:
	#match id:
		#gear_section_ids.TORSO:
			#return "torso"
		#gear_section_ids.LEFT_ARM:
			#return "left_arm"
		#gear_section_ids.RIGHT_ARM:
			#return "right_arm"
		#gear_section_ids.HEAD:
			#return "head"
		#gear_section_ids.LEGS:
			#return "legs"
		#_:
			#return "unknown gear section id: %d" % id

#endregion




