extends RefCounted
class_name GearSection


var name := "GearSection"
var dice_string := "(0-1)"
# top left is 0, 0
var grid := SparseGrid.new()

func _init(dimensions: Vector2i = Vector2i(1, 1)):
	set_section_dimensions(dimensions)

func set_section_dimensions(dimensions: Vector2i):
	grid.size = dimensions
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			grid.set_contents(x, y, GridSlot.new())

func get_total_equipped_weight() -> int:
	push_error("gear_section: get_total_equipped_weight")
	return 0

func reset():
	for coords in grid.get_valid_entries():
		grid.get_contents_v(coords).reset()

func _to_string() -> String:
	return "<GearSection: %s %s | size: %dx%d>" % [name, dice_string, grid.size.x, grid.size.y]
