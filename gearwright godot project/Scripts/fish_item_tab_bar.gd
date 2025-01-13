extends TabBar

# TODO yeet this script

@onready var item_list = $".."

signal tab_chosen(label)

@onready var tab_labels = item_list.section_list.keys()

func _ready():
	for label in tab_labels:
		if label in ["mitigation", "passive"]:
			add_tab(label.capitalize())
		else:
			add_tab(" %s " % label.capitalize())

func _on_tab_changed(tab):
	tab_chosen.emit(tab_labels[tab])
