extends VBoxContainer

@onready var stat_label_scene = preload("res://Scenes/stat_label.tscn")

var stats_to_display := {
	"background": "",
	"marbles": 0,
	"core_integrity": 0,
	"close": 0,
	"far": 0,
	"mental": 0,
	"power": 0,
	"evasion": 0,
	"willpower": 0,
	"ap": 0,
	"speed": 0,
	"sensors": 0,
	"repair_kits": 0,
	"unlocks": 0,
	"weight_cap": 0,
	"weight": 0,
	"ballast": 0,
}

var base_stats := {
	"background": "",
	"marbles": 0,
	"core_integrity": 0,
	"close": 0,
	"far": 0,
	"mental": 0,
	"power": 0,
	"evasion": 0,
	"willpower": 0,
	"ap": 0,
	"speed": 0,
	"sensors": 0,
	"repair_kits": 0,
	"unlocks": 0,
	"default_unlocks": [],
	"weight_cap": 0,
	"weight": 0,
	"ballast": 0,
}

var hidden_stats := {
	"close_range_bonus": 0,
	"lightweight_modifier": 0,
	"curios_allowed": 0,
	"deep_words": 0,
	"bonus_mental_maneuvers": 0,
}

var mutated_stats := {
	
}

var installed_cams := []
var primary_cam = []
var installed_engines := []
var primary_engine = []

var uppercase_stats := ["close", "far", "mental", "power", "ap"]
var spacer_locations := ["core_integrity", "power", "willpower", "repair_kits"]
var stats_to_cap := {"close":9, "far":9, "mental":9, "power":9, "evasion":16, "willpower":16}
var label_dict := {}

@warning_ignore("unused_signal")
signal update_core_integrity(value)
@warning_ignore("unused_signal")
signal update_repair_kits(value)
signal update_unlock_label(current, maximum)
@warning_ignore("unused_signal")
signal update_deep_words(value)
@warning_ignore("unused_signal")
signal update_curios_allowed(value)
@warning_ignore("unused_signal")
signal update_mental_maneuvers(value)
var unlock_tally = 0

var cringe_ballast_tracker = 0

var current_background
var current_level
var current_frame

var ignoring_weight_cap = false
var ignoring_unlock_cap = false

@onready var weight_label_shaker = $WeightLabelShaker

# Called when the node enters the scene tree for the first time.
func _ready():
	for key in stats_to_display.keys():
		var new_label = stat_label_scene.instantiate()
		label_dict[key] = new_label
		add_child(new_label)
		
		if spacer_locations.has(key):
			var blank_label = stat_label_scene.instantiate()
			add_child(blank_label)
	
	weight_label_shaker.target_label = label_dict["weight"] # magic constants, yippee

func update_labels():
	pass
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

func _on_mech_builder_item_installed(a_Item):
	for stat in stats_to_display:
		if stats_to_display.has(stat) and a_Item.item_data.has(stat) and a_Item.item_data[stat] != null:
			stats_to_display[stat] += a_Item.item_data[stat]
	cringe_ballast_tracker += a_Item.item_data["ballast"]
	
	if str(a_Item.item_data["tags"]).contains("sensors"):
		installed_cams.append(a_Item.item_data)
	elif str(a_Item.item_data["tags"]).contains("engine"):
		installed_engines.append(a_Item.item_data)
	
	update_labels()

func _on_mech_builder_item_removed(a_Item):
	for stat in stats_to_display:
		if stats_to_display.has(stat) and a_Item.item_data.has(stat) and a_Item.item_data[stat] != null:
			stats_to_display[stat] -= a_Item.item_data[stat]
	cringe_ballast_tracker -= a_Item.item_data["ballast"]
	
	if str(a_Item.item_data["tags"]).contains("sensors"):
		installed_cams.erase(a_Item.item_data)
	elif str(a_Item.item_data["tags"]).contains("engine"):
		installed_engines.erase(a_Item.item_data)
	
	update_labels()

#func _on_frame_selector_load_frame(a_Frame_data, _a_Frame_name):
func _on_frame_selector_load_frame(_a_Frame_name):
	pass
	#if current_frame:
		#for stat in base_stats:
			#if current_frame.has(stat) and stat != "default_unlocks":
				#if stats_to_display.has(stat):
					#stats_to_display[stat] -= current_frame[stat]
				#if base_stats.has(stat):
					#base_stats[stat] -= current_frame[stat]
	#
	#for stat in base_stats:
		#if a_Frame_data.has(stat) and stat != "default_unlocks":
			#if stats_to_display.has(stat):
				#stats_to_display[stat] += a_Frame_data[stat]
			#if base_stats.has(stat):
				#base_stats[stat] += a_Frame_data[stat]
	#
	#current_frame = a_Frame_data
	#
	#update_labels()

func _on_background_selector_load_background(_bg_name): # changed to string
	pass
	#if current_background:
		#for stat in base_stats:
			#if a_Background_data.has(stat) and stat != "background":
				#if stats_to_display.has(stat):
					#stats_to_display[stat] -= current_background[stat]
				#if base_stats.has(stat):
					#base_stats[stat] -= current_background[stat]
	#
	#for stat in base_stats:
		#if a_Background_data.has(stat) and stat != "background":
				#if stats_to_display.has(stat):
					#stats_to_display[stat] += a_Background_data[stat]
				#if base_stats.has(stat):
					#base_stats[stat] += a_Background_data[stat]
	#
	#stats_to_display["background"] = a_Background_data["background"]
	#current_background = a_Background_data
	#update_labels()

#func _on_level_selector_change_level(a_Level_data, _a_Level):
func _on_level_selector_change_level(_a_Level):
	#if current_level:
		#for stat in stats_to_display:
			#if stats_to_display.has(stat) and current_level.has(stat):
				#stats_to_display[stat] -= current_level[stat]
	#
	#for stat in stats_to_display:
		#if stats_to_display.has(stat) and a_Level_data.has(stat):
			#stats_to_display[stat] += a_Level_data[stat]
	#current_level = a_Level_data
	update_labels()

func _on_mech_builder_incrememnt_lock_tally(a_Change):
	unlock_tally += a_Change
	update_unlock_label.emit(unlock_tally, stats_to_display["unlocks"])

func unlocks_remaining() -> bool:
	return unlock_tally < stats_to_display["unlocks"] or ignoring_unlock_cap

func _on_mech_builder_reset_lock_tally():
	unlock_tally = 0
	update_unlock_label.emit(unlock_tally, stats_to_display["unlocks"])

func is_under_weight_limit(a_Item):
	var under_limit = a_Item["weight"] + stats_to_display["weight"] <= a_Item["weight_cap"] + stats_to_display["weight_cap"]
	return under_limit or ignoring_weight_cap or a_Item["weight"] == 0

func update_weight_label_effect(a_Item):
	if (a_Item == null) or is_under_weight_limit(a_Item):
		weight_label_shaker.stop_shaking()
	else:
		weight_label_shaker.start_shaking()

func _on_weight_cap_check_button_toggled(button_pressed):
	ignoring_weight_cap = button_pressed

func _on_unlocks_check_button_toggled(button_pressed):
	ignoring_unlock_cap = button_pressed

func _on_background_edit_menu_background_stat_updated(stat, value, was_added):
	base_stats[stat] += value if was_added else value * -1
	stats_to_display[stat] += value if was_added else value * -1
	update_labels()

func _on_developments_container_development_added(development_data):
	for stat in development_data:
		if stats_to_display.has(stat):
			stats_to_display[stat] += development_data[stat]
		elif hidden_stats.has(stat):
			hidden_stats[stat] += development_data[stat]
	update_labels()

func _on_developments_container_development_removed(development_data):
	for stat in development_data:
		if stats_to_display.has(stat):
			stats_to_display[stat] -= development_data[stat]
		elif hidden_stats.has(stat):
			hidden_stats[stat] -= development_data[stat]
	update_labels()

func get_close_range_bonus():
	return hidden_stats["close_range_bonus"]
