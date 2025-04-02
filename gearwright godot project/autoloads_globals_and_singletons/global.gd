extends Node

# user selects an existing file to load from main menu
var path_to_shortcutted_file

const colors := {
	"passive": Color("753706"),
	"active": Color("215328"),
	"far": Color("204050"),
	"close": Color("452255"),
	"mental": Color("572129"),
	"mitigation": Color("454545"),
	"deep_word": Color("5a4d91"),
	"generic_perk": Color.BLACK,
}

# for JSON-able slots
func make_slot_info(gear_section_id: int, cell: Vector2i) -> Dictionary:
	return {
		gear_section_name = GearwrightActor.gear_section_id_to_name(gear_section_id),
		gear_section_id = gear_section_id,
		x = cell.x,
		y = cell.y,
	}

# fuck json
func vector_to_dictionary(vector):
	return {
		x = vector.x,
		y = vector.y,
	}

func dictionary_to_vector2i(dict: Dictionary) -> Vector2i:
	return Vector2i(int(dict.x), int(dict.y))

func dictionary_to_vector2(dict: Dictionary) -> Vector2:
	return Vector2(float(dict.x), float(dict.y))

func open_folder(folder_name: String):
	folder_name = folder_name.replace("user://", "")
	var path
	if OS.has_feature("editor"):
		path = ProjectSettings.globalize_path("user://%s" % folder_name)
	else:
		path = OS.get_user_data_dir().path_join(folder_name)
	OS.shell_show_in_file_manager(path, true)

