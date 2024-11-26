extends TabBar

signal tab_chosen(label)

var tab_labels := ["head", "chest", "arm", "leg", "curios"]

func _ready():
	for label in tab_labels:
		add_tab(label.capitalize())

func _on_tab_changed(tab):
	tab_chosen.emit(tab_labels[tab])

func _on_stats_list_update_curios_allowed(value):
	set_tab_disabled(tab_labels.find("curios"), not bool(value))
