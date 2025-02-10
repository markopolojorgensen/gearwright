extends VBoxContainer
class_name GearSectionControl

signal slot_entered(slot_info: Dictionary)
signal slot_exited(slot_info: Dictionary)

const grid_slot_control_scene = preload("res://Scenes/grid_slot_control.tscn")

# FIXME: can't support both fish and character gear section ids, since the values
#  mean different things! There's no merging the two different enums.
#  Wouldn't be a problem if we could dynamically change the sugggestions
#  offered by the editor, but I think there's no way to do that either, so
#  we're stuck with two different things and a boolean to tell the difference.
#  at least we can keep this contained to within this class, other code
#  shouldn't have to ask about which gear section id it should trust.
@export var gear_section_id := GearwrightCharacter.CHARACTER_GSIDS.TORSO
@export var fish_gear_section_id := GearwrightFish.FISH_GSIDS.BODY
@export var is_fish_mode := false 

@onready var grid_container := $GridContainer
@onready var label := $Label

var initialized := false
var control_grid := SparseGrid.new()

# var gear_section: GearSection

func _ready():
	if global_util.was_run_directly(self):
		var fake_character := GearwrightCharacter.new()
		#var fake_gear_section := GearSection.new()
		#fake_gear_section.set_section_dimensions(Vector2i(3, 3))
		#fake_gear_section.name = "Head"
		#fake_gear_section.dice_string = "(2-3)"
		global_position = Vector2(200, 200)
		slot_entered.connect(func(slot_info): print("slot entered: ", str(slot_info)))
		slot_exited.connect(func(slot_info): print("slot exited: ", str(slot_info)))
		update(fake_character.get_gear_section(GearwrightCharacter.CHARACTER_GSIDS.TORSO))

func initialize(gear_section: GearSection):
	initialized = true
	#var fake_character = GearwrightCharacter.new()
	#gear_section = new_gear_section
	#var gear_section: GearSection = fake_character.get_gear_section(gear_section_id)
	
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
				#"gear_section"         : gear_section,
				"gear_section_id"      : gear_section_id,
				"gear_section_control" : self,
				#"grid_slot"            : gear_section.grid.get_contents(x, y),
				"grid_slot_control"    : grid_slot_control,
				"x" : x,
				"y" : y,
			}
			if is_fish_mode:
				slot_info.gear_section_id = fish_gear_section_id
			grid_slot_control.slot_entered.connect(func(): slot_entered.emit(slot_info))
			grid_slot_control.slot_exited.connect( func(): slot_exited.emit( slot_info))
			grid_container.add_child(grid_slot_control)
			control_grid.set_contents(x, y, grid_slot_control)

func update(gear_section: GearSection):
	if not initialized:
		initialize(gear_section)
	assert(initialized)
	
	clear_grey_out()
	
	for coords in control_grid.get_valid_entries():
		var grid_slot: GridSlot = gear_section.grid.get_contents_v(coords)
		control_grid.get_contents_v(coords).update(grid_slot)

func grey_out():
	for coords in control_grid.get_valid_entries():
		control_grid.get_contents_v(coords).grey_out()

func clear_grey_out():
	for coords in control_grid.get_valid_entries():
		control_grid.get_contents_v(coords).clear_grey_out()

# un-initializes this node
# no idea if this works or what
func reset():
	global_util.clear_children(grid_container)
	control_grid.clear()
	initialized = false






