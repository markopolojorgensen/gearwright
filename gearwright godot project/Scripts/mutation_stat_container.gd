extends HBoxContainer

@onready var stat_label = $MutationStatLabel
@onready var mutation_count_label = $MutationCountLabel

signal mutation_count_changed(stat, was_added)

var stat = ""
var stat_modifier = 0
var mutation_counter = 0

func _ready():
	stat_label.text = stat.capitalize() + " (+" + str(stat_modifier) + ")" if stat_modifier >= 0 else stat.capitalize() + " (" + str(stat_modifier) + ")"

func _on_mutation_plus_button_button_down():
	if get_parent().remaining_mutations <= 0 or get_parent().mutation_cap <= mutation_counter:
		return
	
	mutation_counter += 1
	mutation_count_label.text = str(mutation_counter)
	mutation_count_changed.emit(stat, true)

func _on_mutation_minus_button_button_down():
	if mutation_counter <= 0:
		return
	
	mutation_counter -= 1
	mutation_count_label.text = str(mutation_counter)
	mutation_count_changed.emit(stat, false)

func increase_mutation_counter():
	mutation_counter += 1
	mutation_count_label.text = str(mutation_counter)

func clear_mutation_counter():
	for i in range(mutation_counter):
		mutation_counter -= 1
		mutation_count_label.text = str(mutation_counter)
		mutation_count_changed.emit(stat, false)
