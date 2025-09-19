extends Node

# Project Settings -> Application -> Config -> Version

const VERSION = "2.6.1"

func _ready():
	get_window().title = "Gearwright %s" % VERSION


