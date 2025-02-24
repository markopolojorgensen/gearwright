extends Container

signal stat_mouse_entered(stat_name: String)
signal stat_mouse_exited(stat_name: String)

@export var is_fish := false

#const label_scene := preload("res://Scenes/stat_label.tscn")
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

# keys are sane stat names
# values are dictionaries:
#   name -> String
#   label -> Label
#var stat_lines := {}

# key: stat_name
# value: array of 4 labels
var labels := {}
var mouse_detectors := {}

const mouse_detector_scene := preload("res://Scenes/mouse_detector.tscn")

var hovered_stat := ""

func _ready():
	if is_fish:
		pretty_stat_names = pretty_stat_names_fish
		#%StatTotalLabel.size_flags_stretch_ratio = 1.0
		%StatTotalLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		(%HeaderLabel as Label).add_theme_font_size_override("font_size", 24)
		theme = preload("res://Assets/big_font_theme.tres")
	else:
		pretty_stat_names = pretty_stat_names_character
	
	#for text in ["Stat", "Total", "Base", "Bonus"]:
		#var label := Label.new()
		#label.text = text
		#label.modulate = Color.SKY_BLUE
		#grid_container.add_child(label)
	
	for stat_name in pretty_stat_names:
		# maybe key these to make sure we don't end up in a fugue state?
		#var label := label_scene.instantiate()
		#label.stat_name = stat_name
		#label.safe_mouse_entered.connect(func(): stat_mouse_entered.emit(stat_name))
		#label.safe_mouse_exited.connect(func(): stat_mouse_exited.emit())
		var name_label  := Label.new()
		var value_label := Label.new()
		var math_label  := Label.new()
		name_label.text = stat_name
		if is_fish:
			pass
		else:
			name_label.custom_minimum_size.x = 106 # extreme amounts of jank
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		math_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		math_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		#var base_label  := Label.new()
		#var bonus_label := Label.new()
		
		var label_list := [
			name_label,
			value_label,
			#base_label,
			#bonus_label,
			math_label,
		]
		labels[stat_name] = label_list
		#for label in label_list:
		for i in range(label_list.size()):
			var label := label_list[i] as Label
			#if i in [0, 2, 3]:
				#label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			#else:
				#label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			grid_container.add_child(label)
	
	#weight_label_shaker.target_label = stat_lines["weight"].label # magic constants, yippee
	weight_label_shaker.target_label = labels["Weight"][0] # magic constants, yippee
	
	
	if global_util.was_run_directly(self):
		update(GearwrightCharacter.new())

#func _process(delta: float) -> void:
	#process_mouse_hover()
#
#func process_mouse_hover():
	#var mouse := get_global_mouse_position()
	#if not get_global_rect().has_point(mouse):
		#return
	#
	#var has_mouse := false
	#
	#for stat_name in labels.keys():
		#var label: Label = labels[stat_name]
		#if label.get_global_rect().has_point(mouse):
			#has_mouse = true
			#if hovered_stat != stat_name:
				#hovered_stat = stat_name
				#stat_mouse_entered.emit(stat_name)
			#break
	#
	#if (hovered_stat != "") and not has_mouse:
		#hovered_stat = ""
		#stat_mouse_exited.emit()

## returns sum of everything that's not background / frame
#func get_bonus_amount(info: Dictionary) -> int:
	#var result: int = 0
	#for key in info.keys():
		#if not ((key == "background") or (key == "frame")):
			#result += info[key]
	#return result

func update(character: GearwrightActor):
	#print("stats control size: %s" % str(size))
	%BgContainer.hide()
	if is_fish:
		pass
		#%BgContainer.hide()
	else:
		#%BgContainer.show()
		%BgLabel.text = character.background_stats.background
	
	for stat_name in pretty_stat_names:
		if stat_name.is_empty():
			continue
		
		var label_list: Array = labels[stat_name]
		var info := character.get_stat_info(stat_name)
		#print(info.keys())
		label_list[0].text = str(stat_name)
		
		var stat_value: int = global_util.sum_array(info.values())
		# common stat caps
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
		#label_list[2].text = str(base)
		#label_list[3].text = str(global_util.sum_array(info.values()) - base)
		
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
	
	#for i in range(pretty_stat_names.size()):
		#var stat_name: String = pretty_stat_names[i]
		#var label: Label = labels[stat_name]
		##var sane_stat_name: String = stat_name.to_snake_case()
		## keys: label_text, explanation_text
		#label.text = character.get_stat_label_text(stat_name)
	
	#var sl
	#sl = stat_lines["weight"]
	#sl.label.text = "%s: %s" % [sl.name, character.get_total_equipped_weight()]
	#
	#sl = stat_lines["weight_cap"]
	#sl.label.text = "%s: %s" % [sl.name, character.get_weight_cap()]
	#
	#sl = stat_lines["background"]
	#sl.label.text = "%s: %s" % [sl.name, character.background_stats.background]
	#
	#sl = stat_lines["marbles"]
	#sl.label.text = "%s: %s" % [sl.name, character.get_max_marbles()]
	#
	#sl = stat_lines["core_integrity"]
	#sl.label.text = "%s: %s" % [sl.name, character.frame_stats.core_integrity]
	
	
	
	
	
	
	#stats_to_display["ballast"] = int(base_stats["ballast"] + cringe_ballast_tracker + (clamp(stats_to_display["weight"] - hidden_stats["lightweight_modifier"], 0, stats_to_display["weight"]))/5)
	#
	#for key in stats_to_display.keys():
		#var stat_name
		#if uppercase_stats.has(key):
			#stat_name = key.to_upper()
		#else:
			#stat_name = key.capitalize()
		#
		#var temp_value
		#var stat_value = stats_to_display[key]
		#
		#if key in stats_to_cap.keys():
			#if stat_value > stats_to_cap[key]:
				#stat_value = stats_to_cap[key]
		#
		#var stat_data
		#var positive_stat
		#if typeof(stats_to_display[key]) != typeof("String"):
			#stat_data = [str(stat_value), str(base_stats[key]), str(stats_to_display[key] - base_stats[key])]
			#positive_stat = (stats_to_display[key] - base_stats[key]) >= 0
		#
		#if typeof(stats_to_display[key]) == typeof("String") or key == "weight":
			#temp_value = str(stats_to_display[key])
		#elif key == "far" or key == "close":
			#temp_value = ("[%s] (%s+%s Sensors)" if positive_stat else "[%s] (%s%s Sensors)") % stat_data
		#elif key == "ap":
			#temp_value = ("[%s] (%s+%s Engine)" if positive_stat else "[%s] (%s%s Engine)") % stat_data
		#elif key == "ballast":
			#temp_value = ("[%s] (%s+%s)" if positive_stat else "[%s] (%s%s)") % [str(clamp(stat_value, 1, 10)), str(base_stats[key]), str(stats_to_display[key] - base_stats[key])]
		#else:
			#temp_value = ("[%s] (%s+%s)" if positive_stat else "[%s] (%s%s)") % stat_data
		#
		#label_dict[key].text = stat_name + ": " + temp_value
	#
	#update_unlock_label.emit(unlock_tally, stats_to_display["unlocks"])
	#update_core_integrity.emit(stats_to_display["core_integrity"])
	#update_repair_kits.emit(stats_to_display["repair_kits"])
	#update_deep_words.emit(hidden_stats["deep_words"])
	#update_curios_allowed.emit(hidden_stats["curios_allowed"])
	#
	#
	#if stats_to_display["mental"] > 5:
		#hidden_stats["bonus_mental_maneuvers"] = 1
	#else: 
		#hidden_stats["bonus_mental_maneuvers"] = 0
	#
	#update_mental_maneuvers.emit(hidden_stats["bonus_mental_maneuvers"])

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
