extends PanelContainer

func _on_button_pressed() -> void:
	var file_contents: String = global_util.file_to_string("res://utility/label json maker/25_03_21 label list.tsv")
	var lines: Array = file_contents.split("\n")
	%DebugLabel.text += "%d lines" % lines.size()
	global_util.clear_children(%LabelList)
	var label_infos = {}
	for line in lines:
		line = line as String
		var cells = line.split("\t")
		var label_info = {}
		label_info.name = cells[0]
		var label_id: String = label_info.name.to_snake_case()
		if "equipment" in cells[1].to_lower():
			label_info.label_type = "equipment"
		else:
			label_info.label_type = "descriptor"
		label_info.description = cells[2]
		
		assert(not label_infos.has(label_id))
		label_infos[label_id] = label_info
		
		var label := Label.new()
		label.text = label_id
		%LabelList.add_child(label)
	
	print(JSON.stringify(label_infos, "  "))
	
