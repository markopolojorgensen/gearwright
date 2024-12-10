extends VBoxContainer

@onready var points_remaining_label = $HBoxContainer/BackgroundPointsRemainingLabel

var background_stat_container_scene = preload("res://Scenes/custom_background_stat_container.tscn")

var available_bonuses = {"marbles":1, "mental":1, "willpower":1, "unlocks":2, "weight_cap":2}
var stat_caps = {"marbles":2, "mental":4, "willpower":4, "unlocks":1, "weight_cap":1}
var stat_costs = {"marbles":1, "mental":1, "willpower":1, "unlocks":1, "weight_cap":1}
var base_background_points = 4
var stat_containers = {}
signal background_stat_updated(stat, value, was_added)

var remaining_points = base_background_points

func _ready():
	for stat in available_bonuses.keys():
		var temp_container = background_stat_container_scene.instantiate()
		temp_container.stat = stat
		temp_container.stat_modifier = available_bonuses[stat]
		temp_container.stat_cap = stat_caps[stat]
		temp_container.stat_cost = stat_costs[stat]
		temp_container.background_stat_changed.connect(stat_update)
		stat_containers[stat] = temp_container
		add_child(temp_container)
	
	points_remaining_label.text = str(remaining_points)

func stat_update(stat, was_added):
	background_stat_updated.emit(stat, available_bonuses[stat], was_added)
	remaining_points -= stat_costs[stat] if was_added else -1 * stat_costs[stat]
	
	points_remaining_label.text = str(remaining_points)

func _on_background_selector_load_background(bg_name: String):
	if bg_name.to_lower() != "custom":
		for stat in available_bonuses:
			stat_containers[stat].clear_stat_counter()

func _on_mech_builder_new_save_loaded(user_data):
	for stat in available_bonuses:
		stat_containers[stat].clear_stat_counter()
	
	remaining_points = base_background_points
	
	if user_data.has("custom_background"):
		for stat in user_data["custom_background"]:
			remaining_points -= stat_costs[stat]
			background_stat_updated.emit(stat, available_bonuses[stat], true)
			stat_containers[stat].increase_stat_counter()
	
	points_remaining_label.text = str(remaining_points)
