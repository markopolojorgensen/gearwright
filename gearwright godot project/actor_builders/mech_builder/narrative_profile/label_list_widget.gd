extends TabContainer

@export_enum("equipment", "descriptor") var list_type := "equipment"

signal label_hovered(label_id: String)
signal label_added(label_id: String)
signal label_removed(label_id: String)

@onready var fisher_label_container: Container = %FisherLabelContainer
@onready var all_label_container: Container = %AllLabelContainer

const label_widget_scene = preload("res://actor_builders/mech_builder/narrative_profile/label_widget.tscn")

func _ready() -> void:
	var custom_label_info := DataHandler.label_template.duplicate()
	custom_label_info.label_id = "custom"
	custom_label_info.name = "Custom Label"
	
	match list_type:
		"equipment":
			set_tab_title(0, "Fisher Equipment Labels")
			custom_label_info.label_type = "equipment"
		"descriptor":
			set_tab_title(0, "Fisher Descriptor Labels")
			custom_label_info.label_type = "descriptor"
	
	
	var all_labels := [custom_label_info]
	var label_data := DataHandler.get_merged_data(DataHandler.DATA_TYPE.FISHER_LABEL)
	all_labels.append_array(label_data.keys().map(func(label_id: String):
		var info = label_data[label_id].duplicate()
		info.label_id = label_id
		return info
		))
	set_all_labels(all_labels)
	set_fisher_labels([])
	
	if global_util.was_run_directly(self):
		
		label_hovered.connect(func(label_id):
			print("label hovered: %s" % label_id)
			)
		label_added.connect(func(label_id):
			print("label added: %s" % label_id)
			)
		label_removed.connect(func(label_id):
			print("label removed: %s" % label_id)
			)

func set_fisher_labels(label_infos: Array):
	_set_label_info(fisher_label_container, label_infos, false)

func set_all_labels(label_infos: Array):
	_set_label_info(all_label_container, label_infos, true)

func _set_label_info(label_container: Container, label_infos: Array, should_add: bool):
	global_util.clear_children(label_container)
	label_infos = _filter_relevant_label_infos(label_infos)
	for label_info in label_infos:
		var label_widget = _create_label_widget(label_info.label_id, label_info.name)
		if should_add:
			label_widget.button_texture_style = "Plus"
			label_widget.button_pressed.connect(func(): label_added.emit(label_info.label_id))
		else:
			label_widget.button_texture_style = "X"
			label_widget.button_pressed.connect(func(): label_removed.emit(label_info.label_id))
		label_container.add_child(label_widget)

func _filter_relevant_label_infos(label_infos: Array) -> Array:
	var result := []
	for label_info in label_infos:
		if label_info.label_type == list_type:
			result.append(label_info)
	return result

func _create_label_widget(label_id: String, label_text: String) -> Control:
	var label_widget = label_widget_scene.instantiate()
	label_widget.set_text(label_text)
	label_widget.fancy_mouse_entered.connect(func(): label_hovered.emit(label_id))
	return label_widget

#func clear_labels():
	#global_util.clear_children(all_label_container)
	#global_util.clear_children(fisher_label_container)








