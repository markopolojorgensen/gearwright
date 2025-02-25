extends Popup

signal export(filename: String)

@export var extension := ".fsh"

func _ready():
	set_extension(extension)

func _on_button_button_down():
	export.emit(%LineEdit.text + extension)

func set_extension(new_extension: String):
	extension = new_extension
	%ExtensionLabel.text = extension

func set_line_edit_text(text: String):
	%LineEdit.text = text
