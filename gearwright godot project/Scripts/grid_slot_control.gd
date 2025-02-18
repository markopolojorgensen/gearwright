extends TextureRect
class_name GridSlotControl

# TODO yeet comments

signal slot_entered
signal slot_exited

@onready var filter = $StatusFilter
@onready var padlock = $Padlock
@onready var hovered_color_rect: ColorRect = $HoveredColorRect
@onready var greyed_color_rect: ColorRect = %GreyedColorRect

#var slot_ID
var is_hovering := false
#var locked := true
#enum States {DEFAULT, TAKEN, FREE}
#var state := States.DEFAULT
#var installed_item = null

func update(grid_slot: GridSlot):
	if grid_slot.is_locked:
		padlock.visible = true
	else:
		padlock.visible = false
	
	filter.color = Color(Color.WHITE, 0.0) # clear
	
	#if grid_slot.installed_item == null:
		#rotation = 0
	#else:
		#rotation = deg_to_rad(45)

func color_good():
	filter.color = Color(Color.GREEN, 0.3)

func color_bad():
	filter.color = Color(Color.DARK_ORANGE, 0.3)

func grey_out():
	greyed_color_rect.show()

func clear_grey_out():
	greyed_color_rect.hide()

func use_old_style():
	$OldGridBackground.show()
	$Padlock.texture = $OldPadlock.texture
	$Padlock.scale *= 0.8
	$Padlock.position = Vector2(2, 2)

#func set_color(a_state = GridSlot.states.DEFAULT):
	#match a_state:
		#GridSlot.states.DEFAULT:
			#filter.color = Color(Color.WHITE, 0.0)
		#GridSlot.states.TAKEN:
			#filter.color = Color(Color.DARK_ORANGE, 0.3)
		#GridSlot.states.FREE:
			#filter.color = Color(Color.GREEN, 0.3)

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
			hovered_color_rect.show()
			slot_entered.emit()
	else:
		if is_hovering:
			is_hovering = false
			hovered_color_rect.hide()
			slot_exited.emit()
