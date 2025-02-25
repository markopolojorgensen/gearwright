extends RefCounted
class_name SparseGrid

# 2D "grid" with arbitrary keys
# i.e. negative keys are fine
# really, this is just a dictionary where the key is a pair of things instead of one thing
# (although it's assumed that the keys are all integers)
# maybe it should be called PairKeyDictionary
# maybe it should be called ParakeetDictionary

# set size to positive values to enforce strict get/set
var size := Vector2i(-1, -1)

var _contents := {}

func get_contents(x: int, y: int):
	if not is_within_size(x, y):
		breakpoint
	return _contents.get(x, {}).get(y)

func get_contents_v(coords: Vector2i):
	return get_contents(coords.x, coords.y)

func set_contents(x: int, y: int, thing: Variant):
	if not is_within_size(x, y):
		breakpoint
	if not _contents.has(x):
		_contents[x] = {}
	_contents[x][y] = thing

func set_contents_v(coords: Vector2i, thing: Variant):
	return set_contents(coords.x, coords.y, thing)

# returns a list of Vector2is
func get_valid_entries() -> Array:
	var result := []
	for x in _contents.keys():
		var y_contents: Dictionary = _contents[x]
		for y in y_contents.keys():
			result.append(Vector2i(x, y))
	return result

# returns a list of whatever, without key info
func get_values() -> Array:
	return get_valid_entries().map(func(coords: Vector2i): return get_contents_v(coords))

func clear():
	_contents = {}

func is_within_size(x: int, y: int):
	# size not configured, skip it
	if (size.x <= 0) and (size.y <= 0):
		return true
	
	if (x < 0) or (y < 0):
		return false
	
	if (size.x <= x) or (size.y <= y):
		return false
	
	return true

func is_within_size_v(coords: Vector2i):
	return is_within_size(coords.x, coords.y)

