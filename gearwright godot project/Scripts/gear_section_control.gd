extends VBoxContainer

signal slot_entered(slot_info: Dictionary)
signal slot_exited(slot_info: Dictionary)

const grid_slot_control_scene = preload("res://Scenes/grid_slot_control.tscn")

@onready var grid_container := $GridContainer
@onready var label := $Label

var initialized := false
var control_grid := SparseGrid.new()

var gear_section: GearSection

func _ready():
	if global_util.was_run_directly(self):
		var fake_gear_section := GearSection.new()
		fake_gear_section.set_section_dimensions(Vector2i(3, 3))
		fake_gear_section.name = "Head"
		fake_gear_section.dice_string = "(2-3)"
		global_position = Vector2(200, 200)
		slot_entered.connect(func(slot_info): print("slot entered: ", str(slot_info)))
		slot_exited.connect(func(slot_info): print("slot exited: ", str(slot_info)))
		initialize(fake_gear_section)
		update()

func initialize(new_gear_section: GearSection):
	initialized = true
	gear_section = new_gear_section
	
	label.text = "%s %s" % [gear_section.name, gear_section.dice_string]
	
	var column_count = gear_section.grid.size.x
	grid_container.columns = column_count
	# grid header
	for i in range(column_count):
		var l := Label.new()
		l.text = str(i + 1)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.self_modulate = Color("aeaeae")
		grid_container.add_child(l)
	
	for y in range(gear_section.grid.size.y):
		for x in range(gear_section.grid.size.x):
			var grid_slot_control = grid_slot_control_scene.instantiate()
			var slot_info := {
				"gear_section"         : gear_section,
				"gear_section_control" : self,
				"grid_slot"            : gear_section.grid.get_contents(x, y),
				"grid_slot_control"    : grid_slot_control,
				"x" : x,
				"y" : y,
			}
			grid_slot_control.slot_entered.connect(func(): slot_entered.emit(slot_info))
			grid_slot_control.slot_exited.connect( func(): slot_exited.emit( slot_info))
			grid_container.add_child(grid_slot_control)
			control_grid.set_contents(x, y, grid_slot_control)

func update():
	assert(initialized)
	
	for coords in control_grid.get_valid_entries():
		var grid_slot: GridSlot = gear_section.grid.get_contents_v(coords)
		control_grid.get_contents_v(coords).update(grid_slot)

