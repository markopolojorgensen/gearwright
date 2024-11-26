extends FileDialog

var local_data_dir = "user://LocalData"
var update_path = "user://latest_update.pck"

@onready var error_dialog = $ErrorDialog
@onready var success_dialog = $SuccessDialog

func _on_file_selected(a_path):
	var diraccess = DirAccess.open(local_data_dir)
	var zipreader = ZIPReader.new()
	
	var _err = zipreader.open(a_path)
	var files_to_import = zipreader.get_files()
	
	for file_name in files_to_import:
		var data
		var file
		if file_name.contains(".pck"):
			data = zipreader.read_file(file_name)
			file = FileAccess.open(update_path, FileAccess.WRITE)
			file.store_buffer(data)
			file.close()
		if not diraccess.file_exists(file_name):
			continue
		data = zipreader.read_file(file_name).get_string_from_utf8()
		file = FileAccess.open(local_data_dir.path_join(file_name), FileAccess.WRITE)
		file.store_string(data)
		file.close()
	
	DataHandler.reload_items()
	success_dialog.popup()
