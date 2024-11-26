extends HBoxContainer

@onready var stat_label = $CustomBackgroundStatLabel
@onready var stat_count_label = $BackgroundStatCountLabel

signal background_stat_changed(stat, was_added)

var stat = ""
var stat_modifier = 0
var stat_counter = 0
var stat_cap = 0
var stat_cost = 0

func _ready():
	stat_label.text = stat.capitalize() + " (+" + str(stat_modifier) + ")" if stat_modifier >= 0 else stat.capitalize() + " (" + str(stat_modifier) + ")"

func _on_mutation_plus_button_button_down():
	if get_parent().remaining_points - stat_cost < 0 or stat_cap <= stat_counter:
		return
	
	stat_counter += 1
	stat_count_label.text = str(stat_counter)
	emit_signal("background_stat_changed", stat, true)

func _on_mutation_minus_button_button_down():
	if stat_counter <= 0:
		return
	
	stat_counter -= 1
	stat_count_label.text = str(stat_counter)
	emit_signal("background_stat_changed", stat, false)

func increase_stat_counter():
	stat_counter += 1
	stat_count_label.text = str(stat_counter)

func clear_stat_counter():
	for i in range(stat_counter):
		stat_counter -= 1
		stat_count_label.text = str(stat_counter)
		emit_signal("background_stat_changed", stat, false)
