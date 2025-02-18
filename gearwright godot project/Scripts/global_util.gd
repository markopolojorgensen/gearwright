extends Node

# THIS FILE IS FOR UTILITY FUNCTIONS THAT COULD CONCEIVABLY BE USEFUL
# IN OTHER PROJECTS. STUFF SPECIFIC TO THIS PROJECT SHOULD GO IN global.gd

signal debug_continue

const PHI = (1.0 + sqrt(5.0)) / 2.0
# const PHI = 1.61803

var verbose := false
var _verbosity_stack := []
var _indentation := ""

func _ready():
	add_child(debug_drawing_cl)
	debug_drawing_cl.layer = 101
	debug_drawing_cl.follow_viewport_enabled = true
	debug_drawing_cl.visible = true
	
	# demo_sqrt_random()
	# demo_integer_lerp()
	# demo_quack()
	# demo_ship_dimensions()
	# demo_archetype_distances()
	# demo_mask_to_bit_list()


# loads all files in a directory path that have .tres filename ending
func load_treses(directory_path, _verbose = false):
	var loaded_treses = []
	var dir = DirAccess.open(directory_path)
	dir.list_dir_begin() # TODO GODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var filename = dir.get_next()
	while filename != "":
		if filename.ends_with("tres"):
			var full_path = dir.get_current_dir() + "/" + filename
			if verbose:
				print("    loading %s" % full_path)
			var tres = load(full_path)
			if (not "enabled" in tres) or tres.enabled:
				loaded_treses.append(tres)
		filename = dir.get_next()
	return loaded_treses

# pick a random item from an array of items
# I think standard Arrays can do this themselves these days
func pick_random_from_list(list):
	if list.size() <= 0:
		return null
	return list[randi() % list.size()]

var print_once_list = []
func print_once(msg):
	if not print_once_list.has(msg):
		print_once_list.append(msg)
		print(msg)

# returns a number between 0 and top (inclusive on both ends)
# lower numbers are "exponentially" more likely (based on sqauring, not exponents)
#
# the ratio of likelihoods between a and b is a:b
#   i.e. the odds of getting a 4 vs a 5 are 4:5
#   or it would be if we didn't swap high and low numbers lol
func sqrt_random(top):
	var result = null
	# check for null specifically since 0 is a valid result
	while result == null or result > top:
		var range_top = pow(top+1, 2)
		var result_squared = randf_range(0, range_top)
		result = int(round(sqrt(result_squared)))
	return top - result

func demo_sqrt_random():
	print("i: sqrt(i)")
	var results = {}
	var range_top = 91
	for i in range(range_top):
		var result = int(round(sqrt(i)))
		print("%d: %d" % [i, result])
		if not results.has(result):
			results[result] = 0
		results[result] += 1
	for key in results.keys():
		print("%d has %d slots" % [key, results[key]])
	
	print("sqrt random")
	results = {}
	var multiplier = 1000.0
	for _i in range(range_top * multiplier):
		var result = sqrt_random(9)
		if not results.has(result):
			results[result] = 0
		results[result] += 1
	
	var keys = results.keys()
	keys.sort()
	for key in keys:
		print("%d has %.2f slots" % [key, results[key] / multiplier])
	
	for key in keys:
		if key > 0:
			print("%d -> %d: %.2f" % [key-1, key, (results[key-1] - results[key]) / multiplier])

func bezier(weight, a_start, a_end, b_start, b_end):
	var a_point = lerp(a_start, a_end, weight)
	var b_point = lerp(b_start, b_end, weight)
	return lerp(a_point, b_point, weight)

func bezier_demo():
	for i in range(10):
		# print("%.0f" % bezier(i / 9.0, 30, 100, 100, 100))
		# print("%.0f" % bezier(i / 9.0, 100, 15, 15, 15))
		# print("%.0f" % bezier(i / 9.0, 47, 23, 23, 23))
		# print("%.0f" % bezier(i / 9.0, 5, 40, 40, 40))
		# print("%.0f" % bezier(i / 9.0, 10, 40, 40, 40))
		print("%.0f" % bezier(i / 9.0, 10, 60, 60, 60))
		

# 480x270
# 640x360
# 960x540
func get_resolution():
	var width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height = ProjectSettings.get_setting("display/window/size/viewport_height")
	var resolution = Vector2(width, height)
	# don't use get_viewport().get_rect().size because we might not have a viewport
	# assert(resolution == Vector2(960, 540)) # or whatever your project is
	return resolution




# if you have an arc that covers division distance of a circle with the given radius,
# what angle does that arc cover?
func circumference_angle_division(radius, division):
	var circumference = TAU * radius
	# print("circ: %.2f" % circumference)
	var ratio =  division / circumference
	# print("ratio: %.2f" % ratio)
	var result = ratio * TAU
	# print("result: %.2f" % result)
	# print("result (degrees): %.2f" % rad_to_deg(result))
	var alt_result = float(division) / radius
	assert(abs(result - alt_result) < 0.01)
	return result

# returns a number between 0 and 1
# the numbers follow a normal distribution where 0.5 is average
# std deviation is 0.16667
# 0 and 1 are very unlikely (but still possible)
# numbers less than zero and more than one get limit_length
#
# lerp(-10, 10, global_util.rand_normal()) -> random number from -10 to 10 that is mostly around 0
func rand_normal():
	return clamp(randfn(0.5, 0.16667), 0.0, 1.0)

# returns a number between 0 and 1
# numbers are weighted towards 0, less likely towards one
# it looks like a bell curve folded in half
func abs_rand_normal():
	return abs(rand_normal() - 0.5) * 2

func demo_integer_lerp():
	print("weight | lerp")
	for i in range(11):
		var weight = float(i) / 10.0
		print("%.2f | %d" % [weight, integer_lerp(0, 10, weight)])
	print("  ")
	print("weight | lerp")
	for i in range(11):
		var weight = float(i) / 10.0
		print("%.2f | %d" % [weight, integer_lerp(-2, 2, weight)])
	
	var counts = {}
	for _i in range(30):
		var roll = integer_lerp(2, 12, rand_normal())
		if not counts.has(roll):
			counts[roll] = 1
		else:
			counts[roll] += 1
	print("30 normal distribution rolls from 2 to 12:")
	for i in range(11):
		if counts.has(i+2):
			print("%d: %d" % [i+2, counts[i+2]])
		else:
			print("%d: 0" % (i+2))
	print(" ")

# not actually totally accurate, just kind of accurate
# global_util.integer_lerp(1, 10, global_util.rand_normal())
# inclusive on both ends
func integer_lerp(from, to, weight):
	var from_float = float(from) - 0.4999
	var to_float = float(to) + 0.4999
	return int(round(lerp(from_float, to_float, weight)))

# returns bits indexed from 1
func mask_to_bit_list(bitmask):
	var result = []
	for i in range(32):
		if (bitmask & (1 << i)) != 0:
			result.append(i+1)
	return result

func is_bit_enabled(mask, index):
	return mask & (1 << index) != 0

func demo_mask_to_bit_list():
	print(mask_to_bit_list(0)) # -> []
	print(mask_to_bit_list(1)) # -> [1]
	print(mask_to_bit_list(2)) # -> [2]
	print(mask_to_bit_list(3)) # -> [1, 2]
	print(mask_to_bit_list(4)) # -> [3]
	print(mask_to_bit_list(7)) # -> [1, 2, 3]
	print(mask_to_bit_list(16)) # -> [5]


# similar to roll_thresholds, but the threshold dictionary is different
# weights = {
#   "a": 0.2,
#   "b": 0.2,
#   "c": 0.5,
#   "d": 0.1,
# }
# this way you don't have to do the addition yourself, and different outcomes
#  can have the same weights
func roll_weights(roll: float, weights: Dictionary):
	var sum = weights.values().reduce(func(a, b): return a + b)
	if not is_equal_approx(sum, 1.0):
		print("weights add to %f, not to one: %s" % [sum, str(weights)])
		return weights.keys()[0]
	
	var thresholds = {}
	var accum = 0.0
	for outcome in weights.keys():
		accum += weights[outcome]
		thresholds[accum] = outcome
	
	fancy_print("weights: %s" % str(weights))
	fancy_print("-> thresholds: %s" % str(thresholds))
	return roll_thresholds(roll, thresholds)

# roll = randf() -> (between 0 and 1)
# thresholds = {
#   0.5: 1, # -> 50% chance
#   0.7: 2, # -> 20% chance
#   1.0: 3  # -> 30% chance
# }
#
# I would have each key be a weight (instead of the threshold)
#   but you can't have duplicate keys in a dict, so you would have to find
#   another way to have 10 things with a 10% chance each. This way all the
#   keys are unique.
# 
# returns the value of whatever threshold based on the roll
# roll must be less than at least one of the keys
# thresholds must be in ascending order
func roll_thresholds(roll : float, thresholds : Dictionary):
	for threshold in thresholds.keys():
		if roll <= threshold:
			return thresholds[threshold]
	print("bad roll thresholds:")
	print(thresholds)
	breakpoint
	return 0

# https://github.com/godotengine/godot/issues/23715
func profiler_add_child(parent, child):
	parent.add_child(child)


# returns a list of all terrained points within the radius of the ray cast
# points returned are in global coordinates
func map_circle(ray: RayCast2D, circle_resolution: float):
	var points := PackedVector2Array()
	var normals := PackedVector2Array()
	# uses a raycast to figure out where collisions are
	for i in range(circle_resolution):
		ray.rotation = (i / circle_resolution) * TAU
		ray.force_raycast_update()
		if ray.is_colliding():
			points.append(ray.get_collision_point())
			normals.append(ray.get_collision_normal())
	return [points, normals]



var BUTTON_NAMES = {
	"Logitech Dual Action": {
		0: "A",
		1: "B",
		2: "X",
		3: "Y",
		4: "Select",
		# 5: "R1",
		6: "Start",
		7: "L3",
		8: "R3",
		9: "L1",
		10: "R1",
		11: "D-pad Up",
		12: "D-pad Down",
		13: "D-pad Left",
		14: "D-pad Right",
	},
}

# FIXME this ignores keyboards
func get_pretty_button_name(button_id):
	var joy_name = Input.get_joy_name(0)
	if joy_name == "XInput Gamepad":
		joy_name = "Logitech Dual Action"
	
	if BUTTON_NAMES.has(joy_name):
		if BUTTON_NAMES[joy_name].has(button_id):
			return BUTTON_NAMES[joy_name][button_id]
		else:
			print("No name for button '%s' in %s" % [button_id, Input.get_joy_name(0)])
	else:
		print("Unknown Joy Name: %s" % Input.get_joy_name(0))
	
	return "button: %d" % button_id

func get_joystick_intended_direction():
	var horizontal = Input.get_action_strength("joystick_right") - Input.get_action_strength("joystick_left")
	var vertical = Input.get_action_strength("joystick_down") - Input.get_action_strength("joystick_up")
	var intended_direction = Vector2(horizontal, vertical).limit_length(1)
	return intended_direction

func clear_children(node: Node):
	for child in node.get_children():
		child.queue_free()

func fancy_print(what: String):
	if verbose:
		print(what.indent(_indentation))

func indent():
	_indentation += "  "

func dedent():
	_indentation = _indentation.left(-2)

func push_verbose():
	_verbosity_stack.append(verbose)

func pop_verbose():
	verbose = _verbosity_stack.pop_back()

func file_to_string(path: String) -> String:
	return FileAccess.open(path, FileAccess.READ).get_as_text()

func var_to_file(storage, path: String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(storage)
	file.close()

func file_to_var(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	var storage = file.get_var()
	file.close()
	return storage

# global_util.was_run_directly(self)
# don't call this unless you're inside the tree!
func was_run_directly(node: Node):
	return (node.get_parent() == node.get_tree().root)

#region wandering camera

var wandering_camera: Camera2D
var wandering_camera_tween: Tween

# global_util.spawn_camera_on_direct_run(self)
#func spawn_camera_on_direct_run(node: Node):
	#if was_run_directly(node):
		#wandering_camera = preload("res://_addons/_markopolodev/camera/wandering_camera.tscn").instantiate()
		#node.add_child(wandering_camera)

func focus_wandering_camera(gpos: Vector2, zoom: float, duration: float = 0.2):
	if not wandering_camera:
		return
	if wandering_camera_tween:
		wandering_camera_tween.kill()
	wandering_camera_tween = wandering_camera.create_tween()
	wandering_camera_tween.tween_property(wandering_camera, "global_position", gpos, duration)
	wandering_camera_tween.tween_property(wandering_camera, "zoom", Vector2(zoom, zoom), duration)
	wandering_camera_tween.set_ease(Tween.EASE_OUT)
	wandering_camera_tween.set_trans(Tween.TRANS_CUBIC)

func disable_wandering_camera():
	if wandering_camera:
		wandering_camera.enabled = false

#endregion

func wait_for_continue():
	await debug_continue

func _unhandled_input(event):
	if event.is_action_pressed("debug_continue") and is_inside_tree():
		get_viewport().set_input_as_handled()
		debug_continue.emit()






#region DEBUG DRAWING

var debug_drawing_cl := CanvasLayer.new()
var verbose_lines := []
var verbose_labels := []


func clear_lines():
	for line in verbose_lines:
		line.queue_free()
	verbose_lines.clear()

func draw_debug_x(pos : Vector2, color = Color("ffec27")):
	var offset = Vector2(4, 4)
	var other_offset = Vector2(4, -4)
	draw_debug_line(pos - offset, pos + offset, color)
	draw_debug_line(pos - other_offset, pos + other_offset, color)

# single line between two points
# a, b in global coordinates
func draw_debug_line(a:Vector2, b:Vector2, color = Color("ffec27")):
	var line = Line2D.new()
	line.z_index = 100
	line.width = 2
	line.default_color = color
	line.add_point(a)
	line.add_point(b)
	debug_drawing_cl.add_child(line)
	verbose_lines.append(line)
	return line

# series of points
func draw_debug_line_2d(points, close_loop = false, line_weight: float = 2.0, color = random_color()):
	points = points.duplicate() # don't mutate stuff
	if close_loop:
		points.append(points[0])
	
	var line: = Line2D.new()
	line.width = line_weight
	line.points = points
	line.z_index = 100
	line.default_color = color
	debug_drawing_cl.add_child(line)
	verbose_lines.append(line)

# draws polygon outline with labels for each point
func draw_debug_polygon(polygon: PackedVector2Array, poly_name = "", color = random_color()):
	for i in range(polygon.size()):
		var previous_point = polygon[i-1]
		var point = polygon[i]
		var next_point = polygon[(i+1) % polygon.size()]
		var normal := get_point_normal(previous_point, point, next_point)
		var label_direction = normal.rotated(randf_range(-PI / 8, PI / 8))
		var label_position = polygon[i] + (label_direction * 64.0)
		draw_debug_line_2d([label_position, polygon[i]], false, 1.0, color.darkened(0.4))
		# create_label(label_position + Vector2(-4, -4), "%s%d" % [poly_name, i], color.darkened(0.2))
		create_label(label_position + Vector2(-4, -4), "%s%d %s" % [poly_name, i, str(polygon[i])], color.darkened(0.2))
	draw_debug_line_2d(polygon, true, 1.0, color)

# returns a vector2!
func get_point_normal(previous_point: Vector2, point: Vector2, next_point: Vector2) -> Vector2:
	var prev_to_point = previous_point.direction_to(point)
	var prev_to_point_normal = prev_to_point.normalized().rotated(-TAU/4.0)
	var point_to_next = point.direction_to(next_point)
	var point_to_next_normal = point_to_next.normalized().rotated(-TAU/4.0)
	var normal: Vector2 = (prev_to_point_normal + point_to_next_normal) / 2.0
	normal = normal.normalized()
	return normal

func random_color(lower_limit = 0.3, upper_limit = 1.0) -> Color:
	lower_limit = clamp(lower_limit, 0.0, 1.0)
	upper_limit = clamp(upper_limit, 0.0, 1.0)
	var r = lerp(lower_limit, upper_limit, randf())
	var g = lerp(lower_limit, upper_limit, randf())
	var b = lerp(lower_limit, upper_limit, randf())
	return Color(r, g, b)

func create_label(g_pos, text, color = Color.WHITE, font_size = 16.0):
	var label = Label.new()
	label.text = text
	debug_drawing_cl.add_child(label)
	label.global_position = g_pos
	label.z_index = 100
	label.modulate = color
	label.add_theme_font_size_override("font_size", font_size)
	verbose_labels.append(label)

func clear_debug_labels():
	for label in verbose_labels:
		label.queue_free()
	verbose_labels.clear()

#endregion


# https://en.wikipedia.org/wiki/Midpoint_circle_algorithm
# returns a list of all discrete points within radius distance of 0, 0
# this algorithm is extremely cool
# but it only draws the outer circle, doesn't do fill
func midpoint_circle_algo(radius: int) -> Array:
	var result = []
	var t1: int = int(floor(radius / 16.0))
	var x: int = radius
	var y: int = 0
	while y <= x:
		result.append(Vector2i( x,  y))
		result.append(Vector2i(-x,  y))
		result.append(Vector2i( x, -y))
		result.append(Vector2i(-x, -y))
		result.append(Vector2i( y,  x))
		result.append(Vector2i(-y,  x))
		result.append(Vector2i( y, -x))
		result.append(Vector2i(-y, -x))
		y += 1
		t1 += y
		var t2 = t1 - x
		if t2 >= 0:
			t1 = t2
			x -= 1
	
	return result

# returns a list of all points within radius distance of 0, 0
# extremely inefficient!
func circle_fill_points(radius: int) -> Array:
	var points := []
	var y = -radius
	var r2 = pow(radius, 2)
	while y <= radius:
		var x = -radius
		while x <= radius:
			var point := Vector2i(x, y)
			if point.distance_squared_to(Vector2i()) <= r2:
				if not point in points:
					points.append(point)
			x += 1
		y += 1
	return points

var warning_popup: AcceptDialog

func popup_warning(title: String, text: String):
	if is_warning_popup_active():
		return
	warning_popup = AcceptDialog.new()
	warning_popup.title = title
	warning_popup.get_label().text = text
	warning_popup.confirmed.connect(free_warning_popup)
	warning_popup.canceled.connect(free_warning_popup)
	add_child(warning_popup)
	warning_popup.popup_centered.call_deferred()

func free_warning_popup():
	if (warning_popup != null) and is_instance_valid(warning_popup) and not warning_popup.is_queued_for_deletion():
		warning_popup.queue_free()
		warning_popup = null

func is_warning_popup_active():
	return (
		warning_popup != null
		and is_instance_valid(warning_popup)
		and not warning_popup.is_queued_for_deletion()
		and warning_popup.visible
	)

# returns the index of the selected item, or -1 if it couldn't be found
func set_option_button_by_item_text(
		option_button: OptionButton,
		item_text: String,
		snake_case := true) -> int:
	
	for i in range(option_button.item_count):
		var is_match := false
		if snake_case:
			is_match = (
					option_button.get_item_text(i).to_snake_case()
					== item_text.to_snake_case()
					)
		else:
			is_match = (option_button.get_item_text(i) == item_text)
		if is_match:
			option_button.select(i)
			return i
	return -1

func sum_array(list: Array):
	return list.reduce(func(sum, value): return sum + value, 0)

func rising_text(text: String, location: Vector2):
	var label := preload("res://Scenes/rising_text.tscn").instantiate()
	label.text = text
	label.position = location
	
	debug_drawing_cl.add_child(label)

