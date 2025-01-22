extends HBoxContainer

func set_legend_number(number: int):
	%NumberLabel.text = str(number)

func set_legend_name(new_name: String):
	%NameLabel.text = new_name
