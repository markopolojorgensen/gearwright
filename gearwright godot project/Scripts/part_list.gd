extends MarginContainer

# subcontrol of PartMenu
# rename instances of this scene for the TabContainer in PartMenu

@onready var type_section_container: Container = %TypeSectionContainer

const type_section_scene = preload("res://Scenes/part_list_type_section.tscn")

# far close mental active passive mitigation
const types := [
	"far",
	"close",
	"mental",
	"active",
	"passive",
	"mitigation",
]
var type_sections_by_type := {}

func _ready():
	for type in types:
		add_type(type)

func add_type(type: String):
	if type_sections_by_type.has(type):
		return
	
	var type_section: Container = type_section_scene.instantiate()
	type_section.set_type(type)
	type_sections_by_type[type] = type_section
	
	type_section_container.add_child(type_section)

func add_part(part: Node, type: String):
	if not type_sections_by_type.has(type):
		add_type(type)
	
	var type_section: Container = type_sections_by_type[type]
	type_section.add_part(part)

func set_grid_column_count(new_column_count: int):
	for type_section in type_sections_by_type.values():
		type_section.set_grid_column_count(new_column_count)

