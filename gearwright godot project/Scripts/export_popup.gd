extends Popup

signal export_requested(filename)

func _on_button_button_down():
	export_requested.emit(%LineEdit.text)
