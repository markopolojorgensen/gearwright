extends RefCounted
class_name GearSection

var id: GearwrightActor.GSIDS
var name := "GearSection"
var dice_string := "(0-1)"
# 0, 0 is top left
var grid := SparseGrid.new()

func _init(dimensions: Vector2i = Vector2i(1, 1)):
	set_section_dimensions(dimensions)

func set_section_dimensions(dimensions: Vector2i):
	grid.size = dimensions
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			grid.set_contents(x, y, GridSlot.new())

# fish don't have locked/unlocked slots
func unlock_all():
	for grid_slot in grid.get_values():
		grid_slot.is_locked = false



#region Interrogation

func get_equipped_items() -> Array:
	var result := []
	var used_items := []
	for cell in grid.get_valid_entries():
		var grid_slot: GridSlot = grid.get_contents_v(cell)
		var item = grid_slot.installed_item
		if (item != null) and (not item in used_items):
			used_items.append(item)
			result.append(item)
	return result

#func get_total_equipped_weight() -> int:
	#return get_equipped_items().reduce(func(sum, item): return sum + item.item_data.weight, 0)
	#var sum := 0
	#var used_items := []
	#for cell in grid.get_valid_entries():
		#var grid_slot: GridSlot = grid.get_contents_v(cell)
		#var item = grid_slot.installed_item
		#if (item != null) and (not item in used_items):
			#used_items.append(item)
			#sum += grid_slot.installed_item.item_data.weight
	#return sum

func _to_string() -> String:
	return "<GearSection: %s %s | size: %dx%d>" % [name, dice_string, grid.size.x, grid.size.y]

# TODO I guess this isn't used anywhere...?
#func is_valid_internal_equip(item, primary_cell: Vector2i) -> bool:
	#var cells: Array = item.get_relative_cells(primary_cell)
	#for i in range(cells.size()):
		#var cell: Vector2i = cells[i]
		#
		## slot is out of bounds
		#if not grid.is_within_size_v(cell):
			#return false
		#
		#var grid_slot: GridSlot = grid.get_contents_v(cell)
		## slot is locked
		#if grid_slot.is_locked:
			#return false
		#
		## there's already something there
		#if grid_slot.installed_item != null:
			#return false
	#
	#return true



#endregion



#region Mutation
# forgets about items and unlocks (including default unlocks)
func reset():
	for coords in grid.get_valid_entries():
		grid.get_contents_v(coords).reset()

# yeets all items
func unequip_all_internals():
	for coords in grid.get_valid_entries():
		var grid_slot: GridSlot = grid.get_contents_v(coords)
		var item = grid_slot.installed_item
		if item != null and is_instance_valid(item) and not item.is_queued_for_deletion():
			item.queue_free()
		grid_slot.installed_item = null

#endregion
