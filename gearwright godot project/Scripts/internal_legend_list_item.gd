extends HBoxContainer

# might be string
func set_legend_number(number):
	%NumberLabel.text = str(number)

func set_legend_name(new_name: String):
	new_name = new_name.replacen("Horizontal", "H.")
	new_name = new_name.replacen("Vertical", "V.")
	%NameLabel.text = new_name
