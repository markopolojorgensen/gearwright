extends VBoxContainer

# TODO yeet this script

@onready var stat_label_scene = preload("res://Scenes/stat_label.tscn")
@onready var weight_stats_list = $"../../Stats2/WeightStatsList"

var stat_modifications := {
	"weight": 0,
	"close": 0,
	"far": 0,
	"mental": 0,
	"power": 0,
	"evasion": 0,
	"willpower": 0,
	"ap": 0,
	"speed": 0,
	"sensors": 0,
	"ballast": 0}

var mutated_stats := {
	"close":0,
	"far":0,
	"mental":0,
	"speed":0,
	"evasion":0,
	"willpower":0,
	"sensors":0,
	"power":0,
	"ballast":0}

var base_stats := {
	"weight": 0,
	"close": 0,
	"far": 0,
	"mental": 0,
	"power": 0,
	"evasion": 0,
	"willpower": 0,
	"ap": 0,
	"speed": 0,
	"sensors": 0,
	"ballast": 0}

var uppercase_stats := ["close", "far", "mental", "power", "ap"]
var spacer_locations := ["core_integrity", "power", "willpower", "repair_kits"]
var stats_to_cap := {"close":9, "far":9, "mental":9, "power":9, "evasion":16, "willpower":16}
var label_dict := {}

@warning_ignore("unused_signal")
signal update_core_integrity(value)
@warning_ignore("unused_signal")
signal update_repair_kits(value)

var cringe_ballast_tracker = 0
var current_template

# Called when the node enters the scene tree for the first time.
func _ready():
	for key in stat_modifications.keys():
		var new_label = stat_label_scene.instantiate()
		label_dict[key] = new_label
		if key in ["weight", "ballast"]:
			weight_stats_list.add_child(new_label)
		else:
			add_child(new_label)
		
		if key in spacer_locations:
			var blank_label = stat_label_scene.instantiate()
			add_child(blank_label)

func update_labels():
	for key in stat_modifications.keys():
		var stat_name
		if uppercase_stats.has(key):
			stat_name = key.to_upper()
		else:
			stat_name = key.capitalize()
		
		var total_weight = base_stats["weight"] + stat_modifications["weight"]
		if current_template:
			total_weight -= current_template["weight"]
		base_stats["ballast"] = int(total_weight/5)
		
		var temp_value
		var stat_value = base_stats[key]
		if stat_modifications.has(key):
			stat_value += stat_modifications[key]
		if mutated_stats.has(key):
			if key == "ballast":
				if stat_value > 10: stat_value = 10
				stat_value += mutated_stats[key]
				if stat_value < 1: stat_value = 1
			else:
				stat_value += mutated_stats[key]
		
		if key in stats_to_cap.keys():
			if stat_value > stats_to_cap[key]:
				stat_value = stats_to_cap[key]
		
		if typeof(stat_modifications[key]) == 4 or key == "weight":
			temp_value = str(stat_value)
		elif mutated_stats.has(key):
			temp_value = "[" + str(stat_value) + "] (" + str(base_stats[key] + mutated_stats[key]) + "+" + str(stat_modifications[key]) + ")"
		else:
			temp_value = "[" + str(stat_value) + "] (" + str(base_stats[key]) + "+" + str(stat_modifications[key]) + ")"
		
		label_dict[key].text = stat_name + ": " + temp_value

func _on_fish_builder_item_installed(a_Item):
	for stat in stat_modifications:
		if stat_modifications.has(stat) and a_Item.item_data.has(stat) and a_Item.item_data[stat] != null:
			stat_modifications[stat] += a_Item.item_data[stat]
	update_labels()

func _on_fish_builder_item_removed(a_Item):
	for stat in stat_modifications:
		if stat_modifications.has(stat) and a_Item.item_data.has(stat) and a_Item.item_data[stat] != null:
			stat_modifications[stat] -= a_Item.item_data[stat]
	update_labels()

# TODO FIXME WHERWASI fish_size_selector
func _on_fish_size_selector_load_fish_container(_fish_container, size_data):
	for stat in base_stats:
		if size_data.has(stat):
			base_stats[stat] = size_data[stat]
	update_labels()

func _on_template_selector_load_template(_template):
	pass
	#if current_template:
		#for stat in stat_modifications:
			#if stat_modifications.has(stat) and current_template.has(stat) and current_template[stat] != null:
				#stat_modifications[stat] -= current_template[stat]
	#
	#for stat in stat_modifications:
		#if stat_modifications.has(stat) and template.has(stat) and template[stat] != null:
			#stat_modifications[stat] += template[stat]
	#
	#current_template = template
	#
	#update_labels()

func _on_mutation_menu_mutation_updated(stat, value, was_added):
	mutated_stats[stat] += value if was_added else value * -1
	update_labels()
