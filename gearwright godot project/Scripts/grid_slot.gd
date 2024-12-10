extends RefCounted
class_name GridSlot

#enum states {
	#DEFAULT,
	#TAKEN,
	#FREE,
#}

#var state := states.DEFAULT
var is_locked := true
var installed_item = null
var is_primary_install_point := false
var is_default_unlock := false

func reset():
	#state = states.DEFAULT
	is_locked = true
	installed_item = null
	is_primary_install_point = false
	is_default_unlock = false

