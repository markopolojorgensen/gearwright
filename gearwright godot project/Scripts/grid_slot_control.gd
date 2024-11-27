extends TextureRect

signal slot_entered(slot)
signal slot_exited(slot)

@onready var filter = $StatusFilter
@onready var padlock = $Padlock

#var slot_ID
var is_hovering := false
#var locked := true
#enum States {DEFAULT, TAKEN, FREE}
#var state := States.DEFAULT
#var installed_item = null

func update(grid_slot: GridSlot):
	set_color(grid_slot.state)
	if grid_slot.locked:
		padlock.visible = true
	else:
		padlock.visible = false

func set_color(a_state = GridSlot.states.DEFAULT):
	match a_state:
		GridSlot.states.DEFAULT:
			filter.color = Color(Color.WHITE, 0.0)
		GridSlot.states.TAKEN:
			filter.color = Color(Color.DARK_ORANGE, 0.3)
		GridSlot.states.FREE:
			filter.color = Color(Color.GREEN, 0.3)

#func lock():
	#locked = true
	#padlock.visible = true
#
#func unlock():
	#locked = false
	#padlock.visible = false

func _process(_delta):
	if get_global_rect().has_point(get_global_mouse_position()):
		if not is_hovering:
			is_hovering = true
			slot_entered.emit(self)
	else:
		if is_hovering:
			is_hovering = false
			slot_exited.emit(self)
