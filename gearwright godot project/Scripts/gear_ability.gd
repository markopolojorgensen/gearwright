extends ColorRect

# TODO yeet this script
#
#@onready var name_label = $VBoxContainer/GearAbilityLabel
#@onready var text_label = $VBoxContainer/GearAbilityText
#
#func _on_mech_builder_set_gear_ability(a_Frame):
	#name_label.text = "Gear Ability:\n" + a_Frame["gear_ability_name"]
	#
	#var temp_font_size = 14
	#
	#var min_x = 220
	#var min_y = 80
	#
	#while get_theme_default_font().get_multiline_string_size(a_Frame["gear_ability"], HORIZONTAL_ALIGNMENT_LEFT, min_x, temp_font_size).y > min_y:
		#temp_font_size = temp_font_size - 1
	#
	#text_label.set("theme_override_font_sizes/font_size", temp_font_size)
	#text_label.text = a_Frame["gear_ability"]
