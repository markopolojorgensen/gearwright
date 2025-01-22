extends OptionButton







#var template_data_path = "user://LocalData/fish_template_data.json"
#
#var template_data := {}
@warning_ignore("unused_signal")
signal load_template(template) # TODO yeet
signal type_selected(fish_type: GearwrightFish.TYPE)

# Called when the node enters the scene tree for the first time.
func _ready():
	#if not FileAccess.file_exists(template_data_path):
		#printerr("file not found")
		#return
	#var file = FileAccess.open(template_data_path, FileAccess.READ)
	#var temp_data = JSON.parse_string(file.get_as_text())
	#if temp_data:
		#template_data = temp_data
	#else: 
		#return
	#file.close()
	
	for type_key in DataHandler.fish_type_data.keys():
		add_item(type_key.capitalize())
	
	
	#load_template.(template_data[template_data.keys()[0]])

func _on_item_selected(index):
	#load_template.emit(template_data[template_data.keys()[index]])
	type_selected.emit(GearwrightFish.type_from_string(get_item_text(index)))


# TODO yeet
func _on_fish_builder_new_save_loaded(_a_User_data):
	pass
	#select(template_data.keys().find(a_User_data["template"]))
	#if a_User_data.has("template") and a_User_data["template"]:
		#load_template.emit(template_data[a_User_data["template"]])
