extends Container

signal stat_mouse_entered(stat_name: String)
signal stat_mouse_exited(stat_name: String)

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
	"",
	"Unlocks",
	"Weight Cap",
	"Weight",
	"Ballast",
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

@onready var weight_label_shaker = $WeightLabelShaker
@onready var grid_container: GridContainer = %GridContainer

# key: stat_name
# value: array of labels
var labels := {}
var mouse_detectors := {}

const mouse_detector_scene := preload("res://Scenes/mouse_detector.tscn")

var hovered_stat := ""

func _ready():
	if is_fish:
		pretty_stat_names = pretty_stat_names_fish
		
		# jank
		%StatTotalLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		(%HeaderLabel as Label).add_theme_font_size_override("font_size", 24)
		theme = preload("res://Assets/big_font_theme.tres")
	else:
		pretty_stat_names = pretty_stat_names_character
	
	for stat_name in pretty_stat_names:
		# maybe key these to make sure we don't end up in a fugue state?
		var name_label  := Label.new()
		var value_label := Label.new()
		var math_label  := Label.new()
		name_label.text = stat_name
		if not is_fish:
			name_label.custom_minimum_size.x = 106 # extreme amounts of jank
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		math_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		math_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var label_list := [
			name_label,
			value_label,
			math_label,
		]
		labels[stat_name] = label_list
		for label in label_list:
			grid_container.add_child(label)
	
	weight_label_shaker.target_label = labels["Weight"][0] # magic constants, yippee
	
	
	if global_util.was_run_directly(self):
		update(GearwrightCharacter.new())

func update(character: GearwrightActor):
	for stat_name in pretty_stat_names:
		if stat_name.is_empty():
			continue
		
		var label_list: Array = labels[stat_name]
		var info := character.get_stat_info(stat_name)
		label_list[0].text = str(stat_name)
		
		var stat_value: int = global_util.sum_array(info.values())
		# stat caps
		if stat_name.to_lower() in ["close", "far", "power", "speed"]:
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
		
		label_list[1].text = str(stat_value)
		
		var base: int = 0
		base += info.get("background", 0)
		base += info.get("frame", 0)
		for key in info.keys():
			if "fish" in key.to_lower():
				base += info[key]
		
		label_list[2].text = "[%d+%d]" % [base, global_util.sum_array(info.values()) - base]
		
		if not mouse_detectors.has(stat_name):
			var new_md = mouse_detector_scene.instantiate()
			new_md.safe_mouse_entered.connect(func(): stat_mouse_entered.emit(stat_name))
			new_md.safe_mouse_exited.connect(func(): stat_mouse_exited.emit(stat_name))
			$MouseDetectors.add_child(new_md)
			mouse_detectors[stat_name] = new_md
		var md: Control = mouse_detectors[stat_name]
		var left_label: Label = labels[stat_name].front()
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

func over_weight():
	weight_label_shaker.start_shaking()

func under_weight():
	weight_label_shaker.stop_shaking()
