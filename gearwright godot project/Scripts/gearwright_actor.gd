class_name GearwrightActor
extends RefCounted

const item_scene = preload("res://Scenes/item.tscn")

# character callsign, fish name
var callsign := ""

# enum
var gear_section_ids := {}

var internal_inventory := InternalInventory.new()

func check_internal_equip_validity(item, gear_section_id: int, _primary_cell: Vector2i) -> Array:
	var errors := []
	
	# there is no item
	if item == null:
		errors.append("No item")
	
	# there is no gear section
	if not gear_section_id in gear_section_ids.values():
		errors.append("No gear section")
	
	return errors

func equip_internal(_item, _gear_section_id: int, _primary_cell: Vector2i) -> Array:
	# should be overridden with no super calls
	breakpoint
	return []

func unequip_internal(_item, _gear_section_id: int):
	# should be overridden with no super calls
	breakpoint
	return

func get_stat_info(_stat_name: String) -> Dictionary:
	breakpoint
	return {}





class UnmarshalSession:
	var errors := []
	var info := {}
	
	func get_info(key, default = ""):
		if info.has(key):
			return info[key]
		else:
			errors.append("No %s info found!" % key)
			return default

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

