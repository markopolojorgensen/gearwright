extends RefCounted
class_name GridSlot

var is_locked := true
var is_default_unlock := false

var installed_item = null
var is_primary_install_point := false

func reset():
	is_locked = true
	installed_item = null
	is_primary_install_point = false
	is_default_unlock = false

