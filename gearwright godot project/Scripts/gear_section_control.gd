extends VBoxContainer

const grid_slot_control_scene = preload("res://Scenes/grid_slot_control.tscn")

@onready var grid_container := $GridContainer
@onready var label := $Label

var initialized := false
var control_grid := SparseGrid.new()

func _ready():
	if global_util.was_run_directly(self):
		var gear_section := GearSection.new()
		gear_section.set_section_dimensions(Vector2i(3, 3))
		gear_section.name = "Head"
		gear_section.dice_string = "(2-3)"
		global_position = Vector2(200, 200)
		update(gear_section)

func initialize(gear_section: GearSection):
	initialized = true
	
	label.text = "%s %s" % [gear_section.name, gear_section.dice_string]
	
	var column_count = gear_section.grid.size.x
	grid_container.columns = column_count
	# grid header
	for i in range(column_count):
		var l := Label.new()
		l.text = str(i + 1)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		grid_container.add_child(l)
	
	for y in range(gear_section.grid.size.y):
		for x in range(gear_section.grid.size.x):
			var grid_slot_control = grid_slot_control_scene.instantiate()
			grid_slot_control.slot_entered
			grid_slot_control.slot_exited
			grid_container.add_child(grid_slot_control)
			control_grid.set_contents(x, y, grid_slot_control)

func update(gear_section: GearSection):
	if not initialized:
		initialize(gear_section)



