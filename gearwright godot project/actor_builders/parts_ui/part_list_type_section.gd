extends VBoxContainer

func _ready():
	# don't show type sections with nothing in them
	hide()

func set_type(type: String):
	$Label.text = type.capitalize()

func add_part(part: Node):
	$GridContainer.add_child(part)
	show()

func set_grid_column_count(new_column_count: int):
	$GridContainer.columns = new_column_count

