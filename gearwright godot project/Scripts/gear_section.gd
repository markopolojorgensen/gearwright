extends RefCounted
class_name GearSection

var name := "GearSection"
var dice_string := "(0-1)"
var grid := SparseGrid.new()

func _init(dimensions: Vector2i = Vector2i(1, 1)):
	set_section_dimensions(dimensions)

func set_section_dimensions(dimensions: Vector2i):
	grid.size = dimensions



