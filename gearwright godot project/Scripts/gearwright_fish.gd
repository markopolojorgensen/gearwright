extends GearwrightActor
class_name GearwrightFish

enum FISH_GSIDS {
	TIP,
	TAIL,
	BODY,
	NECK,
	HEAD,
	LEFT_LEGS,
	RIGHT_LEGS,
	LEFT_ARM,
	RIGHT_ARM,
}

enum SIZE {
	SMALL,
	MEDIUM,
	LARGE,
	MASSIVE,
	LEVIATHAN,
	SERPENT_LEVIATHAN,
	SILTSTALKER_LEVIATHAN,
}

# fish_template_data.json
enum TYPE {
	COMMON,
	ABERRANT,
	DEEPSPAWN,
	ELDER_DEEPSPAWN,
}

var size := SIZE.SMALL
var type := TYPE.COMMON

const mutation_mults := {
	"close":     1,
	"far":       1,
	"mental":    1,
	"power":     1,
	"evasion":   1,
	"willpower": 1,
	"speed":     1,
	"sensors":   3,
	"ballast":  -1,
}
var mutations: Array[String] = []

func initialize():
	internal_inventory.create_fish_gear_sections(size)
	gear_section_ids = FISH_GSIDS














#region Interrogation

func has_gear_section(gsid: int) -> bool:
	return internal_inventory.gear_sections.has(gsid)

func get_gear_section(gsid: int) -> GearSection:
	return internal_inventory.gear_sections.get(gsid, null)

func get_equipped_items() -> Array:
	return internal_inventory.get_equipped_items()

# returns a list of strings
# each string shows a problem
# returns an empty list if there are no problems
# doesn't necessarily give you all the problems at once, but tries to
#
# all the reasons we can't put an item in a slot:
#   there is no item
#   there is no slot
#   for each slot that would become occupied:
#     there's already something there
#     slot is out of bounds
#     slot is locked
func check_internal_equip_validity(item, gear_section_id: int, primary_cell: Vector2i) -> Array:
	var errors := super(item, gear_section_id, primary_cell)
	if errors.is_empty():
		return internal_inventory.check_internal_equip_validity(item, gear_section_id, primary_cell)
	else:
		return errors




static func get_size_as_string(size_value: SIZE) -> String:
	return (SIZE.find_key(size_value) as String).to_lower().replacen("_", " ")

static func size_from_string(size_name: String) -> SIZE:
	return string_to_enum(size_name, SIZE) as SIZE

static func get_type_as_string(type_value: TYPE) -> String:
	return (TYPE.find_key(type_value) as String).to_lower().replacen("_", " ")

static func type_from_string(type_name: String) -> TYPE:
	return string_to_enum(type_name, TYPE) as TYPE

# only works if the enum is named
static func string_to_enum(string: String, target_enum: Dictionary) -> int:
	string = string.to_upper()
	string = string.replacen(" ", "_")
	if not target_enum.has(string):
		var error := "unknown enum value %s\n  valid values: %s" % [string, str(target_enum.keys())]
		print(error)
		push_error(error)
		breakpoint
		return -1
	return target_enum.get(string)

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
			]:
		#var info: Dictionary = call("get_%s_info" % snake_stat)
		var info = get_basic_info(snake_stat)
		return GearwrightCharacter.info_to_explanation_text(info)
	elif snake_stat == "weight":
		var info = get_weight_info()
		return GearwrightCharacter.info_to_explanation_text(info)
	elif snake_stat == "ballast":
		var info = get_ballast_info()
		return GearwrightCharacter.info_to_explanation_text(info)
	
	var error := "GearwrightFish: get_stat_explanation: unknown stat: %s" % stat
	push_error(error)
	print(error)
	return error

func get_stat_label_text(stat: String) -> String:
	if stat.is_empty():
		return ""
	
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
			]:
		#var info = call("get_%s_info" % snake_stat)
		var info = get_basic_info(snake_stat)
		var value = global_util.sum_array(info.values())
		return "%s: %s" % [stat, value]
	elif snake_stat == "weight":
		var value = global_util.sum_array(get_weight_info().values())
		return "%s: %s" % [stat, value]
	elif snake_stat == "ballast":
		var value = global_util.sum_array(get_ballast_info().values())
		value = clamp(value, 1, 10)
		return "%s: %s" % [stat, value]
	
	var error := "GearwrightCharacter: get_stat_label_text: unknown stat: %s" % stat
	push_error(error)
	return error

func get_mutations_amount(stat: String) -> int:
	var amount = mutations.count(stat) * mutation_mults.get(stat, 0)
	return amount

func get_mutations_remaining():
	return get_type_data().get("mutations", 0) - mutations.size()

func get_same_mutations_limit():
	return get_type_data().get("mutation_cap", 0)

func get_basic_info(stat: String) -> Dictionary:
	var info := get_size_stat_info(stat)
	
	var internals_amount = internal_inventory.sum_internals_for_stat(stat)
	if internals_amount != 0:
		info.internals = internals_amount
	
	var mutations_amount: int = get_mutations_amount(stat)
	if mutations_amount != 0:
		info.mutations = get_mutations_amount(stat)
	
	return info

#func get_close_info() -> Dictionary:
	#return get_basic_info("close")
#
#func get_far_info() -> Dictionary:
	#return get_basic_info("far")
#
#func get_mental_info() -> Dictionary:
	#return get_basic_info("mental")
#
#func get_power_info() -> Dictionary:
	#return get_basic_info("power")
#
#func get_evasion_info() -> Dictionary:
	#return get_basic_info("evasion")
#
#func get_willpower_info() -> Dictionary:
	#return get_basic_info("willpower")
#
#func get_ap_info() -> Dictionary:
	#return get_basic_info("ap")
#
#func get_speed_info() -> Dictionary:
	#return get_basic_info("speed")
#
#func get_sensors_info() -> Dictionary:
	#return get_basic_info("sensors")

func get_weight_info() -> Dictionary:
	var info = get_basic_info("weight")
	var type_amount = get_type_data().get("weight", 0)
	if type_amount != 0:
		# ballast calculation needs to ignore this
		info.fish_type = type_amount
	return info

func get_ballast_info() -> Dictionary:
	var weight_info := get_weight_info()
	weight_info.erase("fish_type") # fish type doesn't affect ballast
	var total_weight = global_util.sum_array(weight_info.values())
	var ballast_from_weight := int(floor(total_weight / 5.0))
	var ballast_info := {}
	ballast_info.weight = ballast_from_weight
	
	var basic_ballast_info = get_basic_info("ballast")
	for key in basic_ballast_info.keys():
		if basic_ballast_info[key] != 0:
			ballast_info[key] = basic_ballast_info[key]
	
	return ballast_info

# get_size_stat_info("close") returns {"small fish" -> 4}
func get_size_stat_info(stat_name) -> Dictionary:
	var info = {}
	var size_name = get_size_as_string(size)
	var info_key = "%s fish" % size_name
	var size_stats = DataHandler.get_fish_size_data(size_name.to_snake_case())
	info[info_key] = size_stats.get(stat_name, 0)
	return info

func get_type_data() -> Dictionary:
	return DataHandler.get_fish_type_data(TYPE.find_key(type).to_snake_case())

#endregion













#region Mutation

func equip_internal(item, gear_section_id: int, primary_cell: Vector2i) -> Array:
	var errors := check_internal_equip_validity(item, gear_section_id, primary_cell)
	if errors.is_empty():
		return internal_inventory.equip_internal(item, gear_section_id, primary_cell)
	else:
		return errors

func unequip_internal(item, gear_section_id: int):
	return internal_inventory.unequip_internal(item, gear_section_id)

func reset_gear_sections():
	assert(internal_inventory.gear_sections.values().size() >= 1)
	internal_inventory.full_reset()
	internal_inventory.unlock_all()

# FIXME code duplication with custom background in GearwrightCharacter
func modify_mutation(stat_name: String, is_increase: bool):
	if not stat_name in mutation_mults.keys():
		var error := "mystery mutation stat: %s" % stat_name
		push_error(error)
		print(error)
		breakpoint
		return
	var current_count := mutations.count(stat_name)
	var cap: int = get_same_mutations_limit()
	if is_increase and (current_count < cap) and (0 < get_mutations_remaining()):
		mutations.append(stat_name)
	elif not is_increase:
		mutations.erase(stat_name)

func set_fish_type(fish_type: TYPE):
	if fish_type != type:
		mutations.clear()
	type = fish_type

#endregion
