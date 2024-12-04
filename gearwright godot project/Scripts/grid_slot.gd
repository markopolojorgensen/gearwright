extends RefCounted
class_name GridSlot

enum states {
	DEFAULT,
	TAKEN,
	FREE,
}

var state := states.DEFAULT
var locked := true
var installed_item = null

