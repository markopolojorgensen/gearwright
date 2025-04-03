extends GearwrightActor
class_name GearwrightFish

const non_cyclic_item_scene = preload("res://actor_builders/inventory_system/Item.tscn")

const LEVIATHAN_FISH_GSIDS := [
	GSIDS.FISH_TAIL,
	GSIDS.FISH_BODY,
	GSIDS.FISH_HEAD,
]

const SERPENT_LEVIATHAN_FISH_GSIDS := [
	GSIDS.FISH_TIP,
	GSIDS.FISH_TAIL,
	GSIDS.FISH_BODY,
	GSIDS.FISH_NECK,
	GSIDS.FISH_HEAD,
]

const SILTSTALKER_LEVIATHAN_FISH_GSIDS := [
	GSIDS.FISH_LEFT_LEGS,
	GSIDS.FISH_BODY,
	GSIDS.FISH_RIGHT_LEGS,
	GSIDS.FISH_LEFT_ARM,
	GSIDS.FISH_RIGHT_ARM,
]



enum SIZE {
	SMALL,
	MEDIUM,
	LARGE,
	MASSIVE,
	LEVIATHAN,
	SERPENT_LEVIATHAN,
	SILTSTALKER_LEVIATHAN,
}

const SIZE_NAMES := {
	SIZE.SMALL: "small",
	SIZE.MEDIUM: "medium",
	SIZE.LARGE: "large",
	SIZE.MASSIVE: "massive",
	SIZE.LEVIATHAN: "leviathan",
	SIZE.SERPENT_LEVIATHAN: "serpent leviathan",
	SIZE.SILTSTALKER_LEVIATHAN: "siltstalker leviathan",
}

# fish_template_data.json
enum TYPE {
	COMMON,
	ABERRANT,
	DEEPSPAWN,
	ELDER_DEEPSPAWN,
}

const TYPE_NAMES := {
	TYPE.COMMON: "common",
	TYPE.ABERRANT: "aberrant",
	TYPE.DEEPSPAWN: "deepspawn",
	TYPE.ELDER_DEEPSPAWN: "elder deepspawn",
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
# array of strings, but using Array[String] makes unmarshalling explode
#  I do not understand how typed arrays and casting work
var mutations: Array = []

func initialize():
	internal_inventory.create_fish_gear_sections(size)
	
	if size in [SIZE.LEVIATHAN, SIZE.SERPENT_LEVIATHAN, SIZE.SILTSTALKER_LEVIATHAN]:
		internal_inventory.max_optics_count = 2














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
# there are no problems unique to fish, so they're all in internal_inventory
func check_internal_equip_validity(item, gear_section_id: int, primary_cell: Vector2i) -> Array:
	var errors := super(item, gear_section_id, primary_cell)
	if errors.is_empty():
		return internal_inventory.check_internal_equip_validity(item, gear_section_id, primary_cell, enforce_tags)
	else:
		return errors

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
			]:
		return get_basic_info(snake_stat)
	
	elif snake_stat == "weight":
		return get_weight_info()
	elif snake_stat == "ballast":
		return get_ballast_info()
	
	var error := "GearwrightFish: get_stat_info: unknown stat: %s" % stat
	push_error(error)
	print(error)
	return {}

func get_stat_explanation(stat: String) -> String:
	var info := get_stat_info(stat)
	if info.is_empty():
		return ""
	else:
		return GearwrightCharacter.info_to_explanation_text(info)

func get_mutations_amount(stat: String) -> int:
	var amount = mutations.count(stat) * mutation_mults.get(stat, 0)
	return amount

func get_mutations_remaining() -> int:
	return get_type_data().get("mutations", 0) - mutations.size()

func get_same_mutations_limit() -> int:
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

func get_weight_info() -> Dictionary:
	var info = get_basic_info("weight")
	var type_amount = get_type_data().get("weight", 0)
	if type_amount != 0:
		# ballast calculation needs to ignore this
		info.fish_type = type_amount
	return info

func get_ballast_info() -> Dictionary:
	var weight_info := get_weight_info()
	weight_info.erase("fish_type") # fish type weight doesn't affect ballast
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



static func get_size_as_string(size_value: SIZE) -> String:
	return (SIZE.find_key(size_value) as String).to_lower().replacen("_", " ")

static func size_from_string(size_name: String) -> SIZE:
	if "silt" in size_name.to_lower():
		return SIZE.SILTSTALKER_LEVIATHAN
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

#endregion













#region Mutation

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














#region Save & Load

func marshal() -> Dictionary:
	var info := {
		name = callsign, # callsign
		size = SIZE_NAMES[size],
		template = TYPE_NAMES[type], # type
		mutations = mutations.duplicate(),
	}
	
	#info.internals = internal_inventory.get_equipped_items(false)
	var internals_info := {}
	var internals_by_gs := internal_inventory.get_equipped_items_by_gs(false)
	for gsid in internals_by_gs.keys():
		internals_info[GSIDS_TO_NAMES[gsid]] = internals_by_gs[gsid].map(func(internal_info: Dictionary):
			internal_info.slot = global.vector_to_dictionary(internal_info.slot)
			return internal_info
			)
	info.internals = internals_info
	
	info.gearwright_version = version.VERSION
	
	return info

static func unmarshal(info: Dictionary) -> GearwrightFish:
	global_util.fancy_print("loading fish...")
	global_util.indent()
	var sesh: UnmarshalSession = start_unmarshalling_session(info)
	
	var new_fish := GearwrightFish.new()
	new_fish.callsign = sesh.get_info("name")
	new_fish.size = SIZE_NAMES.find_key(sesh.get_info("size", "small"))
	var template_type = sesh.get_info("template", "common")
	if template_type == "abberant":
		template_type = "aberrant"
	new_fish.type = TYPE_NAMES.find_key(template_type)
	new_fish.mutations = sesh.get_info("mutations", [])
	
	new_fish.initialize()
	
	var internals := sesh.get_info("internals", {}) as Dictionary
	if internals.is_empty():
		# maybe this isn't an error?
		sesh.errors.append("No internals found!")
	else:
		var first_key = internals.keys().front()
		if (first_key == "0") or (int(first_key) != 0):
			# old style
			sesh.errors.append("Failed to convert old fish internals format")
		else:
			# new style
			for gs_name in internals.keys():
				var gsid: GSIDS = GSIDS_TO_NAMES.find_key(gs_name)
				# this is a fish, not a fisher
				if gsid == GSIDS.FISHER_LEFT_ARM:
					gsid = GSIDS.FISH_LEFT_ARM
				if gsid == GSIDS.FISHER_RIGHT_ARM:
					gsid = GSIDS.FISH_RIGHT_ARM
				if gsid == GSIDS.FISHER_HEAD:
					gsid = GSIDS.FISH_HEAD
				var gs_internals_list: Array = internals[gs_name]
				for i in range(gs_internals_list.size()):
					# internal_info.slot: dictionary
					#   x, y
					# internal_info.internal: string
					var internal_info: Dictionary = gs_internals_list[i]
					var new_internal = non_cyclic_item_scene.instantiate()
					new_internal.load_item(internal_info.internal_name, false)
					var primary_cell := global.dictionary_to_vector2i(internal_info.slot) # fuck json
					var errors: Array = new_fish.equip_internal(new_internal, gsid, primary_cell)
					if not errors.is_empty():
						sesh.errors.append("  failed to install internal: %s (%s)" % [internal_info, str(errors)])
	
	finish_unmarshalling_session(sesh)
	global_util.dedent()
	global_util.fancy_print("...finished loading fish")
	return new_fish

#endregion









