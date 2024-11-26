extends GridContainer

@onready var mutations_remaining_label = $"../../VBoxContainer2/HBoxContainer/MutationsRemainingLabel"
@onready var mutation_cap_label = $"../../VBoxContainer2/HBoxContainer3/SameMutationsLimitLabel"

var mutation_stat_container_scene = preload("res://Scenes/mutation_stat_container.tscn")

var available_mutations = {"close":1, "far":1, "mental":1, "speed":1, "evasion":1, "willpower":1, "sensors":3, "power":1, "ballast":-1}
var mutation_containers = {}
signal mutation_updated(stat, value, was_added)

var cached_mutations := []

var remaining_mutations = 0
var mutation_cap = 0

func _ready():
	for stat in available_mutations.keys():
		var temp_container = mutation_stat_container_scene.instantiate()
		temp_container.stat = stat
		temp_container.stat_modifier = available_mutations[stat]
		temp_container.mutation_count_changed.connect(mutation_update)
		mutation_containers[stat] = temp_container
		add_child(temp_container)

func mutation_update(stat, was_added):
	emit_signal("mutation_updated", stat, available_mutations[stat], was_added)
	remaining_mutations -= 1 if was_added else -1
	
	mutations_remaining_label.text = str(remaining_mutations)

func _on_template_selector_load_template(template):
	for stat in available_mutations:
		mutation_containers[stat].clear_mutation_counter()
	
	remaining_mutations = template["mutations"]
	mutations_remaining_label.text = str(remaining_mutations)
	
	mutation_cap = template["mutation_cap"]
	mutation_cap_label.text = str(mutation_cap)
	
	if cached_mutations:
		for stat in cached_mutations:
			emit_signal("mutation_updated", stat, available_mutations[stat], true)
			mutation_containers[stat].increase_mutation_counter()
		cached_mutations.clear()

func _on_fish_builder_new_save_loaded(user_data):
	if user_data.has("mutations"):
		cached_mutations = user_data["mutations"]
