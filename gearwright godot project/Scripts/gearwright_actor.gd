class_name GearwrightActor
extends RefCounted

# Still no idea why this causes cyclic errors
#const item_scene = preload("res://Scenes/item.tscn")

# Gear Section IDs
enum GSIDS {
	FISHER_TORSO,
	FISHER_LEFT_ARM,
	FISHER_RIGHT_ARM,
	FISHER_HEAD,
	FISHER_LEGS,
	FISH_TIP,
	FISH_TAIL,
	FISH_BODY,
	FISH_NECK,
	FISH_HEAD,
	FISH_LEFT_LEGS,
	FISH_RIGHT_LEGS,
	FISH_LEFT_ARM,
	FISH_RIGHT_ARM,
}

const GSIDS_TO_NAMES := {
	GSIDS.FISHER_TORSO: "torso",
	GSIDS.FISHER_LEFT_ARM: "left_arm",
	GSIDS.FISHER_RIGHT_ARM: "right_arm",
	GSIDS.FISHER_HEAD: "head",
	GSIDS.FISHER_LEGS: "legs",
	GSIDS.FISH_TIP: "tip",
	GSIDS.FISH_TAIL: "tail",
	GSIDS.FISH_BODY: "body",
	GSIDS.FISH_NECK: "neck",
	GSIDS.FISH_HEAD: "head",
	GSIDS.FISH_LEFT_LEGS: "left_legs",
	GSIDS.FISH_RIGHT_LEGS: "right_legs",
	GSIDS.FISH_LEFT_ARM: "left_arm",
	GSIDS.FISH_RIGHT_ARM: "right_arm",
}


# character callsign, fish name
var callsign := ""

var internal_inventory := InternalInventory.new()

func check_internal_equip_validity(item, gear_section_id: int, _primary_cell: Vector2i) -> Array:
	var errors := []
	
	# there is no item
	if item == null:
		errors.append("No item")
	
	# there is no gear section
	if not gear_section_id in GSIDS.values():
		errors.append("No gear section '%d'" % gear_section_id)
	
	return errors

func equip_internal(item, gear_section_id: int, primary_cell: Vector2i) -> Array:
	var errors := check_internal_equip_validity(item, gear_section_id, primary_cell)
	if errors.is_empty():
		return internal_inventory.equip_internal(item, gear_section_id, primary_cell)
	else:
		return errors

func unequip_internal(item, gear_section_id: int):
	return internal_inventory.unequip_internal(item, gear_section_id)

func unequip_all_internals():
	return internal_inventory.unequip_all_internals()

func get_stat_info(_stat_name: String) -> Dictionary:
	breakpoint
	return {}

static func gear_section_id_to_name(id: int) -> String:
	return GSIDS_TO_NAMES.get(id, "unknown gear section id: %d" % id)

static func start_unmarshalling_session(info: Dictionary) -> UnmarshalSession:
	global_util.fancy_print("loading GearwrightActor...")
	global_util.indent()
	var sesh := UnmarshalSession.new()
	sesh.info = info
	
	if not info.has("gearwright_version"):
		sesh.errors.append("No Version Detected!")
		sesh.errors.append("This character may have been made with a previous version of gearwright. Some things may not load properly.")
		#global_util.popup_warning()
	elif info.get("gearwright_version", "") != version.VERSION:
		sesh.errors.append("Different Version Detected!")
		sesh.errors.append("This character was made with a different version of gearwright. Some things may not load properly.")
		#global_util.popup_warning("Different Version Detected!", "This character was made with a different version of gearwright. Some things may not load properly.")
	
	return sesh

static func finish_unmarshalling_session(sesh: UnmarshalSession):
	if not sesh.errors.is_empty():
		global_util.popup_warning("Load Errors:", sesh.errors.reduce(
				func(result: String, message: String):
					if result.is_empty():
						return message
					else:
						return result + "\n" + message
					, ""))
		global_util.fancy_print("Load Errors:")
		global_util.indent()
		for error in sesh.errors:
			global_util.fancy_print(error)
		global_util.dedent()
	
	global_util.dedent()
	global_util.fancy_print("...finished loading GearwrightActor")

