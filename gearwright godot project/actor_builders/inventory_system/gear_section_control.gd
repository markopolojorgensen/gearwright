extends VBoxContainer
class_name GearSectionControl

signal slot_entered(slot_info: Dictionary)
signal slot_exited(slot_info: Dictionary)

const grid_slot_control_scene = preload("res://actor_builders/inventory_system/grid_slot_control.tscn")
const scaling_label_scene = preload("res://actor_builders/fish_builder/scaling_label.tscn")

@export var gear_section_id := GearwrightActor.GSIDS.FISHER_TORSO

@onready var grid_container := %GridContainer
@onready var caption_label := $CaptionLabel

var initialized := false
var control_grid := SparseGrid.new()

@onready var gsid_to_overlay := {
	GearwrightActor.GSIDS.FISHER_TORSO: %TorsoOverlaySprite2D,
}

func _ready():
	for overlay in gsid_to_overlay.values():
		overlay.hide()
	
	if global_util.was_run_directly(self):
		var fake_character := GearwrightCharacter.new()
		global_position = Vector2(200, 200)
		slot_entered.connect(func(slot_info): print("slot entered: ", str(slot_info)))
		slot_exited.connect(func(slot_info): print("slot exited: ", str(slot_info)))
		update(fake_character.get_gear_section(GearwrightActor.GSIDS.FISHER_TORSO))
		await get_tree().create_timer(2.0).timeout
		scale = Vector2(4.0, 4.0)
		await get_tree().create_timer(2.0).timeout
		update(fake_character.get_gear_section(GearwrightActor.GSIDS.FISHER_TORSO))

func initialize(gear_section: GearSection):
	initialized = true
	
	caption_label.text = "%s %s" % [gear_section.name, gear_section.dice_string]
	
	var column_count = gear_section.grid.size.x
	grid_container.columns = column_count
	# grid header
	for i in range(column_count):
		#var l := scaling_label_scene.instantiate()
		var l := Label.new()
		l.text = str(i + 1)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		#l.size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND
		l.size_flags_vertical = Control.SIZE_SHRINK_END
		l.modulate = Color("aeaeae")
		#l.custom_minimum_size.y += 12
		grid_container.add_child(l)
		#l.update_scale()
	
	for y in range(gear_section.grid.size.y):
		for x in range(gear_section.grid.size.x):
			var grid_slot_control = grid_slot_control_scene.instantiate()
			var slot_info := {
				"gear_section_id"      : gear_section_id,
				"gear_section_control" : self,
				"grid_slot_control"    : grid_slot_control,
				"x" : x,
				"y" : y,
			}
			grid_slot_control.slot_entered.connect(func(): slot_entered.emit(slot_info))
			grid_slot_control.slot_exited.connect( func(): slot_exited.emit( slot_info))
			grid_container.add_child(grid_slot_control)
			control_grid.set_contents(x, y, grid_slot_control)
	
	for overlay in gsid_to_overlay.values():
		overlay.hide()
	if gear_section.id in gsid_to_overlay.keys():
		gsid_to_overlay[gear_section_id].show()
	else:
		for cell in control_grid.get_valid_entries():
			var grid_slot_control = control_grid.get_contents_v(cell)
			grid_slot_control.use_old_style()
	

func update(gear_section: GearSection):
	if not initialized:
		initialize(gear_section)
		update.call_deferred(gear_section) # do it again for scaling label to figure things out
	assert(initialized)
	
	clear_grey_out()
	
	for coords in control_grid.get_valid_entries():
		var grid_slot: GridSlot = gear_section.grid.get_contents_v(coords)
		control_grid.get_contents_v(coords).update(grid_slot)
	
	# update column header font sizes
	#var column_count = gear_section.grid.size.x
	#for i in range(column_count):
		#var scaling_label = grid_container.get_child(i)
		#scaling_label.update_scale()
	
	# put overlays below column headers
	if 7 <= grid_container.get_child_count():
		for overlay in gsid_to_overlay.values():
			overlay.position.y = grid_container.get_child(6).position.y

func grey_out():
	for coords in control_grid.get_valid_entries():
		control_grid.get_contents_v(coords).grey_out()

func clear_grey_out():
	for coords in control_grid.get_valid_entries():
		control_grid.get_contents_v(coords).clear_grey_out()

# un-initializes this node
func reset():
	global_util.clear_children(grid_container)
	control_grid.clear()
	initialized = false






