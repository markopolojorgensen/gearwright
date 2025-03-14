extends HBoxContainer

@onready var color_rect: ColorRect = %ColorRect

func _ready():
	color_rect.color = Color(0,0,0,0)

# might be string
func set_legend_number(number):
	%NumberLabel.text = str(number)

func set_legend_name(new_name: String):
	new_name = new_name.replacen("Horizontal", "H.")
	new_name = new_name.replacen("Vertical", "V.")
	%NameLabel.text = new_name

# only call after adding to tree!
func set_color(new_color: Color):
	color_rect.color = new_color

func set_font_size(new_font_size: int):
	%NameLabel.add_theme_font_size_override("font_size", new_font_size)
