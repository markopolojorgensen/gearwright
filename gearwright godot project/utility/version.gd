extends Node

# Project Settings -> Application -> Config -> Version

const VERSION = "2.5.3"

func _ready():
	get_window().title += " " + VERSION

