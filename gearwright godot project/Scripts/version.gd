extends Node

const VERSION = "2.0.0"

func _ready():
	get_window().title += " " + VERSION

