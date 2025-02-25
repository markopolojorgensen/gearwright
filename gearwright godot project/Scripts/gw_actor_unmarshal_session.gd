class_name UnmarshalSession
extends RefCounted

# once was an internal class of GearwrightActor
# something got extremely borked, and now it's here
#  I didn't know cyclic dependency errors still existed in 4.x

var errors := []
var info := {}

func get_info(key, default = ""):
	if info.has(key):
		return info[key]
	else:
		errors.append("No %s info found!" % key)
		return default



