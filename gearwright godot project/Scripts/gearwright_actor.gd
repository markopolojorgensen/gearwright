class_name GearwrightActor
extends RefCounted

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

