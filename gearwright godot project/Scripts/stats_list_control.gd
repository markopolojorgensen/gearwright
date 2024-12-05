extends VBoxContainer

const stat_names := [
	"background",
	"marbles",
	"core_integrity",
	"close",
	"far",
	"mental",
	"power",
	"evasion",
	"willpower",
	"ap",
	"speed",
	"sensors",
	"repair_kits",
	"unlocks",
	"weight_cap",
	"weight",
	"ballast",
]

const spacer_locations := [
	"core_integrity",
	"power",
	"willpower",
	"repair_kits",
]

@onready var weight_label_shaker = $WeightLabelShaker

var labels := {}

func _ready():
	for stat_name in stat_names:
		var label := Label.new()
		labels[stat_name] = label
		add_child(label)
		
		if spacer_locations.has(stat_name):
			var blank_label = Label.new()
			add_child(blank_label)
	
	weight_label_shaker.target_label = labels["weight"] # magic constants, yippee

func update_labels():
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
