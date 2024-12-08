extends VBoxContainer

signal stat_mouse_entered(stat_name: String)
signal stat_mouse_exited

const pretty_stat_names := [
	"Background",
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

@onready var weight_label_shaker = $WeightLabelShaker

# keys are sane stat names
# values are dictionaries:
#   name -> String
#   label -> Label
#var stat_lines := {}

var labels := {}
var hovered_stat := ""

func _ready():
	for i in range(pretty_stat_names.size()):
		var stat_name: String = pretty_stat_names[i]
		var label := Label.new()
		# WHEREWASI
		# TODO these labels probably should be busted out in their own scene
		#  especially given that we're going to move weight / weight_cap
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.custom_minimum_size.x = 180
		label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		label.text = stat_name
		# TODO maybe key these to make sure we don't end up in a fugue state?
		# FIXME Label's mouse_entered and mouse_exited cause flickering...?
		#label.mouse_filter = Control.MOUSE_FILTER_STOP
		#label.mouse_entered.connect(func(): stat_mouse_entered.emit(stat_name))
		#label.mouse_exited.connect(func(): stat_mouse_exited.emit())
		add_child(label)
		labels[stat_name] = label
		#var sane_stat_name: String = stat_name.to_snake_case()
		#labels[sane_stat_name] = label
		#stat_lines[sane_stat_name] = {
			#"name": stat_name,
			#"label": label,
		#}
	
	#weight_label_shaker.target_label = stat_lines["weight"].label # magic constants, yippee
	weight_label_shaker.target_label = labels["Weight"] # magic constants, yippee

func _process(delta: float) -> void:
	process_mouse_hover()

func process_mouse_hover():
	var mouse := get_global_mouse_position()
	if not get_global_rect().has_point(mouse):
		return
	
	var has_mouse := false
	
	for stat_name in labels.keys():
		var label: Label = labels[stat_name]
		if label.get_global_rect().has_point(mouse):
			has_mouse = true
			if hovered_stat != stat_name:
				hovered_stat = stat_name
				stat_mouse_entered.emit(stat_name)
			break
	
	if (hovered_stat != "") and not has_mouse:
		hovered_stat = ""
		stat_mouse_exited.emit()


func update(character: GearwrightCharacter):
	for i in range(pretty_stat_names.size()):
		var stat_name: String = pretty_stat_names[i]
		var label: Label = labels[stat_name]
		#var sane_stat_name: String = stat_name.to_snake_case()
		# keys: label_text, explanation_text
		label.text = character.get_stat_label_text(stat_name)
	
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

func over_weight():
	weight_label_shaker.start_shaking()

func under_weight():
	weight_label_shaker.stop_shaking()
