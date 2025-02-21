extends Node

const colors := {
	"passive": Color("753706"),
	"active": Color("215328"),
	"far": Color("204050"),
	"close": Color("452255"),
	"mental": Color("572129"),
	"mitigation": Color("454545"),
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

func open_folder(folder_name):
	var path
	if OS.has_feature("editor"):
		path = ProjectSettings.globalize_path("user://%s" % folder_name)
	else:
		path = OS.get_user_data_dir().path_join(folder_name)
	OS.shell_show_in_file_manager(path, true)

