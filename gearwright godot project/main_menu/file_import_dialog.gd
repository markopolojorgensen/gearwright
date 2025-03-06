extends FileDialog

@onready var error_dialog = $ErrorDialog
@onready var success_dialog = $SuccessDialog

func _on_file_selected(path: String):
	if DataHandler.load_fsh_file(path):
		success_dialog.popup()
	else:
		error_dialog.popup()
