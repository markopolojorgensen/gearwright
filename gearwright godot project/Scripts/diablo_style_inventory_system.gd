extends Node2D
class_name DiabloStyleInventorySystem

# interacts with PartMenu, GearSectionControl, and their subcontrols.

@export var is_fish_mode := false

signal something_changed

const item_scene = preload("res://Scenes/item.tscn")

enum Modes {
	EQUIP,
	PLACE,
	UNLOCK,
}
var mode = Modes.EQUIP
var item_held

# keys:
#   gear_section_id
#   x
#   y
var current_slot_info: Dictionary
# can't assign null to these, so use current_slot_info.is_empty()
#   to find out if a slot is currently being hovered
var current_gear_section: GearSection
var current_gear_section_control: GearSectionControl
var current_grid_slot: GridSlot
var current_grid_slot_control: GridSlotControl

var control_scale: float = 1.0


func get_mode() -> String:
	return Modes.find_key(mode)









#region Leftclick Rightclick

func leftclick(character):
	match mode:
		Modes.EQUIP:
			pickup_item(character)
		Modes.PLACE:
			place_item(character)
		Modes.UNLOCK:
			toggle_current_slot_lock(character)

func rightclick(_character):
	match mode:
		Modes.PLACE:
			drop_item()


func pickup_item(actor: GearwrightActor):
	if current_slot_info.is_empty():
		return
	if not current_grid_slot.installed_item:
		return
	
	item_held = current_grid_slot.installed_item
	item_held.grid_anchor = null
	item_held.selected = true
	item_held.hide_legend_number()
	
	actor.unequip_internal(item_held, current_slot_info.gear_section_id)
	
	mode = Modes.PLACE
	
	something_changed.emit()

func place_item(actor: GearwrightActor):
	if current_slot_info.is_empty():
		return
	
	var current_slot_cell := Vector2i(current_slot_info.x, current_slot_info.y)
	var errors: Array = actor.equip_internal(
			item_held,
			current_slot_info.gear_section_id,
			current_slot_cell
	)
	if not errors.is_empty():
		global_util.rising_text(errors.reduce(func(accum: String, current: String):
			if accum.is_empty():
				return current
			else:
				return accum + "\n" + current
			, ""), get_global_mouse_position() + Vector2(16, -16))
		return
	
	item_held.selected = false
	item_held = null
	mode = Modes.EQUIP
	
	something_changed.emit()

func toggle_current_slot_lock(character):
	if current_slot_info.is_empty():
		return
	
	character.toggle_unlock(
			current_slot_info.gear_section_id,
			current_slot_info.x,
			current_slot_info.y
	)
	
	something_changed.emit()

func drop_item():
	if not item_held:
		return
	item_held.queue_free()
	item_held = null
	mode = Modes.EQUIP
	#request_update_controls = true
	something_changed.emit()

#endregion






#region Mutation

func toggle_unlock_mode():
	if item_held:
		drop_item()
	
	if mode == Modes.UNLOCK:
		mode = Modes.EQUIP
	else:
		mode = Modes.UNLOCK

#endregion







#region Rendering

func fancy_update(character, gear_section_controls: Dictionary):
	# updates controls on data from gear_section / grid_slot
	# also clears all highlights / filters
	for gear_section_id in gear_section_controls.keys():
		if not character.has_gear_section(gear_section_id):
			continue
		var gear_section: GearSection = character.get_gear_section(gear_section_id)
		var gear_section_control: GearSectionControl = gear_section_controls[gear_section_id]
		gear_section_control.update(gear_section)
	
	update_internal_items(character, gear_section_controls)
	
	update_place_mode(character, gear_section_controls)
	update_unlock_mode(character, gear_section_controls)

func update_internal_items(character, gear_section_controls: Dictionary):
	# gsid -> gear_section_id
	var internals: Array = character.get_equipped_items()
	for i in range(internals.size()):
		#  
		#   slot (gear_section_id, gear_section_name, x, y)
		#   internal_name
		#   internal: actual Item value
		var internal_info: Dictionary = internals[i]
		var gsid: int = internal_info.slot.gear_section_id
		var primary_cell := Vector2i(internal_info.slot.x, internal_info.slot.y)
		var item = internal_info.internal
		#var item_cells: Array = character.get_item_cells(item, gsid, primary_cell)
		var item_cells: Array = item.get_relative_cells(primary_cell)
		var top_left_cell = item_cells.reduce(func(best: Vector2i, current: Vector2i):
			best.x = min(best.x, current.x)
			best.y = min(best.y, current.y)
			return best
			, Vector2i(1000, 1000))
		var gear_section_control: GearSectionControl = gear_section_controls[gsid]
		var anchor_grid_slot_control: GridSlotControl = gear_section_control.control_grid.get_contents_v(top_left_cell)
		item.snap_to(anchor_grid_slot_control.global_position)
		item.grid_anchor = anchor_grid_slot_control

func update_place_mode(actor: GearwrightActor, gear_section_controls: Dictionary):
	if mode != Modes.PLACE:
		return
	if item_held == null:
		return
	
	# correct section
	var item_section = item_held.item_data.get("section", null)
	# fish internals have no section
	if item_section != null:
		var valid_section_ids := GearwrightCharacter.item_section_to_valid_section_ids(item_section)
		for gear_section_id in gear_section_controls.keys():
			var gear_section_control: GearSectionControl = gear_section_controls[gear_section_id]
			if gear_section_id in valid_section_ids:
				gear_section_control.clear_grey_out()
			else:
				gear_section_control.grey_out()
	
	# no hovered slot
	if current_slot_info.is_empty():
		return
	
	var gsid: int = current_slot_info.gear_section_id
	var primary_cell := Vector2i(current_slot_info.x, current_slot_info.y)
	#var item_cells: Array = character.get_item_cells(item_held, gsid, primary_cell)
	var item_cells: Array = item_held.get_relative_cells(primary_cell)
	var grid_slot_controls := item_cells.map(func(cell):
		if current_gear_section_control.control_grid.is_within_size_v(cell):
			return current_gear_section_control.control_grid.get_contents_v(cell)
		else:
			return null
		)
	grid_slot_controls = grid_slot_controls.filter(func(gsc): return gsc != null)
	if actor.check_internal_equip_validity(item_held, gsid, primary_cell).is_empty():
		for grid_slot_control in grid_slot_controls:
			if grid_slot_control != null:
				grid_slot_control.color_good()
	else:
		for grid_slot_control in grid_slot_controls:
			if grid_slot_control != null:
				grid_slot_control.color_bad()

func update_unlock_mode(character, gear_section_controls: Dictionary):
	if mode != Modes.UNLOCK:
		return
	
	# default frame unlocks
	for gsid in gear_section_controls.keys():
		var gear_section_control: GearSectionControl = gear_section_controls[gsid]
		var gear_section: GearSection = character.get_gear_section(gsid)
		var cells := gear_section.grid.get_valid_entries()
		for cell in cells:
			# cell is Vector2i
			var grid_slot: GridSlot = gear_section.grid.get_contents_v(cell)
			var grid_slot_control: GridSlotControl = gear_section_control.control_grid.get_contents_v(cell)
			if grid_slot.is_default_unlock:
				grid_slot_control.color_bad()
	
	update_current_unlock_highlight(character)

func update_current_unlock_highlight(character):
	if current_slot_info.is_empty():
		return
	
	if current_grid_slot.is_default_unlock:
		return
	
	if current_grid_slot.is_locked:
		if character.has_unlocks_remaining():
			current_grid_slot_control.color_good()
		else:
			current_grid_slot_control.color_bad()
	else:
		# not a default unlock, not locked, should be allowed to re-lock it
		current_grid_slot_control.color_good()

#endregion







#region "Reactivity"

func on_slot_mouse_entered(slot_info: Dictionary, character):
	current_slot_info = {}
	current_slot_info.x = slot_info.x
	current_slot_info.y = slot_info.y
	current_slot_info.gear_section_id = slot_info.gear_section_id
	current_gear_section         = character.get_gear_section(slot_info.gear_section_id)
	current_gear_section_control = slot_info.gear_section_control
	current_grid_slot         = current_gear_section.grid.get_contents(slot_info.x, slot_info.y)
	current_grid_slot_control = slot_info.grid_slot_control

func on_slot_mouse_exited(slot_info: Dictionary):
	if (
			(slot_info.x == current_slot_info.x)
			and (slot_info.y == current_slot_info.y)
			and (slot_info.gear_section_id == current_slot_info.gear_section_id)
	):
		current_slot_info = {}

func on_part_menu_item_spawned(item_id: Variant) -> void:
	if item_held:
		return
	var new_item = item_scene.instantiate()
	new_item.scale = Vector2(1.0, 1.0) * control_scale
	add_child(new_item)
	new_item.load_item(item_id, not is_fish_mode)
	new_item.selected = true
	item_held = new_item
	mode = Modes.PLACE

#endregion

