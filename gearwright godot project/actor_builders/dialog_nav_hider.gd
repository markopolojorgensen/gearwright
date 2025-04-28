extends ColorRect

# this is a hack to hide the path bar

@export var file_dialog: FileDialog

func _process(_delta: float) -> void:
	size.x = file_dialog.size.x

