extends Container

signal stat_mouse_entered(stat_name: String)
signal stat_mouse_exited(stat_name: String)
signal manual_stat_increase(stat_name: String)
signal manual_stat_decrease(stat_name: String)

@export var is_fish := false

const pretty_stat_names_character := [
	"Marbles",
	"Core Integrity",
	"",
	"CLOSE",
	"FAR",
	"MENTAL",
	"POWER",
	"",
	"Evasion",
	"Willpower",
	"",
	"AP",
	"Speed",
	"Sensors",
	"Repair Kits",
	"Ballast",
	#"",
	#"Unlocks",
	#"Weight Cap",
	#"Weight",
	#"Ballast",
]
const pretty_stat_names_fish := [
	"Weight",
	"Ballast",
	"",
	"CLOSE",
	"FAR",
	"MENTAL",
	"POWER",
	"",
	"Evasion",
	"Willpower",
	"",
	"AP",
	"Speed",
	"Sensors",
]
var pretty_stat_names: Array

@onready var grid_container: GridContainer = %GridContainer

# key: stat_name
# value: array of controls
var stat_to_controls := {}
# for empty lines
var empty_controls := []
var mouse_detectors := {}

const mouse_detector_scene := preload("res://utility/mouse_detector.tscn")
const manual_adjustment_control_scene := preload("res://actor_builders/mech_builder/manual_adjustment_control.tscn")

var hovered_stat := ""

func _ready():
	global_util.clear_children(grid_container)
	if is_fish:
		pretty_stat_names = pretty_stat_names_fish
		
		# jank
		%StatTotalLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		(%HeaderLabel as Label).add_theme_font_size_override("font_size", 24)
		theme = preload("res://Assets/big_font_theme.tres")
	else:
		pretty_stat_names = pretty_stat_names_character
	
	for stat_name in pretty_stat_names:
		stat_name = stat_name as String
		# maybe key these to make sure we don't end up in a fugue state?
		var name_label  := Label.new()
		var value_label := Label.new()
		var math_label  := Label.new()
		name_label.text = stat_name
		if not is_fish:
			name_label.custom_minimum_size.x = 106 # extreme amounts of jank
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		name_label.custom_minimum_size.y = 26
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		math_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		math_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var spin_box_container: Control
		if stat_name.is_empty():
			spin_box_container = Control.new()
		else:
			spin_box_container = manual_adjustment_control_scene.instantiate()
			var spin_box: Control = spin_box_container.get_spin_box()
			spin_box.increase.connect(func():
				manual_stat_increase.emit(stat_name)
				)
			spin_box.decrease.connect(func():
				manual_stat_decrease.emit(stat_name)
				)
		spin_box_container.hide()
		
		var control_list := [
			name_label,
			value_label,
			spin_box_container,
			math_label,
		]
		if stat_name.is_empty():
			empty_controls.append(control_list)
		else:
			stat_to_controls[stat_name] = control_list
		
		for control in control_list:
			grid_container.add_child(control)
	
	if global_util.was_run_directly(self):
		update(GearwrightCharacter.new())
	
	show_hide_spinboxes(false)

func update(character: GearwrightActor):
	for stat_name in pretty_stat_names:
		if stat_name.is_empty():
			continue
		
		var control_list: Array = stat_to_controls[stat_name]
		var info := character.get_stat_info(stat_name)
		control_list[0].text = str(stat_name)
		
		var stat_value: int = global_util.sum_array(info.values())
		# stat caps
		if stat_name.to_lower() in ["close", "far", "power", "speed", "mental"]:
			stat_value = clamp(stat_value, 0, 9)
		elif stat_name.to_lower() in ["evasion", "willpower"]:
			stat_value = clamp(stat_value, 0, 16)
		elif stat_name.to_lower() == "ballast":
			# special calculation
			stat_value = 0
			var negatives = 0
			for value in info.values():
				if value >= 0:
					stat_value += value
				else:
					negatives += value
			stat_value = clamp(stat_value, 1, 10)
			stat_value += negatives
			stat_value = clamp(stat_value, 1, 10)
		
		control_list[1].text = str(stat_value)
		
		if not is_fish:
			var manual_amount: int = character.get_manual_stat_adjustment(stat_name)
			control_list[2].get_spin_box().value = manual_amount
		
		var base: int = 0
		base += info.get("background", 0)
		base += info.get("frame", 0)
		base += info.get("mutations", 0)
		base += info.get("manual adj", 0)
		for key in info.keys():
			if "fish" in key.to_lower():
				base += info[key]
			# developments edit base stats
			elif DataHandler.is_development_name(key):
				base += info[key]
		
		var bonus: int = global_util.sum_array(info.values()) - base
		if 0 <= bonus:
			control_list[3].text = "[%d+%d]" % [base, bonus]
		else:
			control_list[3].text = "[%d%d]" % [base, bonus]
		
		if not mouse_detectors.has(stat_name):
			var new_md = mouse_detector_scene.instantiate()
			new_md.safe_mouse_entered.connect(func(): stat_mouse_entered.emit(stat_name))
			new_md.safe_mouse_exited.connect(func(): stat_mouse_exited.emit(stat_name))
			$MouseDetectors.add_child(new_md)
			mouse_detectors[stat_name] = new_md
		var md: Control = mouse_detectors[stat_name]
		var left_label: Label = stat_to_controls[stat_name].front()
		md.global_position = left_label.global_position
		var new_size := Vector2()
		new_size.x = grid_container.size.x
		new_size.y = left_label.size.y
		md.set_deferred("size", new_size)

func set_mouse_detector_filters(active: bool):
	for md in mouse_detectors.values():
		md = md as Control
		if active:
			md.mouse_filter = Control.MOUSE_FILTER_STOP
		else:
			md.mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_hide_spinboxes(show_spinbox: bool):
	if show_spinbox:
		grid_container.columns = 4
	else:
		grid_container.columns = 3
	
	var control_lists := stat_to_controls.values()
	control_lists.append_array(empty_controls)
	
	for control_list in control_lists:
		control_list = control_list as Array
		if control_list.is_empty():
			continue
		var spin_box := control_list[2] as Control
		if spin_box == null:
			continue
		if show_spinbox:
			spin_box.show()
		else:
			spin_box.hide()

