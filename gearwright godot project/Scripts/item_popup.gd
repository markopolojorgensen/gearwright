extends Popup

@onready var engage_text_label = $ColorRect2/MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/EngageTextLabel
@onready var range_damage_label = $ColorRect2/MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/RangeDamageLabel
@onready var item_description_container = $ColorRect2/MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/ItemDescriptionContainer
@onready var item_description_label = $ColorRect2/MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/ItemDescriptionContainer/ItemDescriptionLabel
@onready var item_tags_container = $ColorRect2/MarginContainer/ColorRect/VBoxContainer/ColorRect2
@onready var item_tags_label = $ColorRect2/MarginContainer/ColorRect/VBoxContainer/ColorRect2/MarginContainer2/ItemTagsContainer/ItemTagsLabel
@onready var item_stats_container = $ColorRect2/MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/ItemStatsContainer
@onready var item_stats_label = $ColorRect2/MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/ItemStatsContainer/ItemStatsLabel
@onready var item_rules_container = $ColorRect2/MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/ItemRulesContainer
@onready var item_rules_label = $ColorRect2/MarginContainer/ColorRect/VBoxContainer/MarginContainer/VBoxContainer/ItemRulesContainer/ItemRulesLabel
@onready var middle_text_container = $ColorRect2/MarginContainer/ColorRect/VBoxContainer/MarginContainer
@onready var item_name_label = $ColorRect2/MarginContainer/ColorRect/VBoxContainer/ColorRect/MarginContainer/VBoxContainer/ItemNameLabel
@onready var item_type_weight_label = $ColorRect2/MarginContainer/ColorRect/VBoxContainer/ColorRect/MarginContainer/VBoxContainer/ItemTypeLabel

@onready var internal_color_rect = $ColorRect2/MarginContainer/ColorRect/VBoxContainer/ColorRect

#var internal_menu_colors = {
	#"far": Color.html("#0678b5"),
	#"close": Color.html("#9d2d96"),
	#"active": Color.html("#509335"),
	#"passive": Color.html("#a34902"),
	#"mitigation": Color.html("#999999"),
	#"mental": Color.html("#ce2d45")
#}

var stats_to_list = [
	"close",
	"far",
	"mental",
	"power",
	"evasion",
	"willpower",
	"ap",
	"speed",
	"sensors",
	"repair_kits",
	"weight_cap",
	"ballast"]

var stats_to_capitalize = [
	"close",
	"far",
	"power",
	"ap"
]

var weapon_internals = ["close", "far", "mental"]

func set_data(a_Item_Data):
	internal_color_rect.color = global.colors[a_Item_Data["type"]]
	item_tags_container.color = global.colors[a_Item_Data["type"]]
	#internal_color_rect.color = internal_menu_colors[a_Item_Data["type"]]
	#item_tags_container.color = internal_menu_colors[a_Item_Data["type"]]
	
	item_name_label.text = a_Item_Data["name"]
	
	if a_Item_Data["type"] in weapon_internals:
		item_type_weight_label.text = "%s Weapon" % a_Item_Data["type"].to_upper()
	else:
		item_type_weight_label.text = "%s Internal" % a_Item_Data["type"].capitalize()
	
	item_type_weight_label.text += " - Weight %s" % str(a_Item_Data["weight"])
	
	if a_Item_Data["tags"]:
		var temp_tags = "Tags: "
		for tag in a_Item_Data["tags"]:
			temp_tags += "%s, " % tag.capitalize()
		
		temp_tags = temp_tags.erase(temp_tags.length() - 2, 2)
		item_tags_label.text = "[center]%s[/center]" % temp_tags
		item_tags_container.visible = true
		size.y = size.y + 33
	
	var temp_stats = ""
	if "optics" in a_Item_Data["tags"] or "engine" in a_Item_Data["tags"]:
		pass
	else:
		for stat in a_Item_Data:
			if stat in stats_to_list && a_Item_Data[stat] != 0:
				temp_stats += ("%s +%s, " if a_Item_Data[stat] > 0 else "%s %s, ") % [stat.to_upper() if stat in stats_to_capitalize else stat.capitalize(), a_Item_Data[stat]]
	if temp_stats:
		temp_stats = temp_stats.erase(temp_stats.length() - 2, 2)
		item_stats_label.text = "[center]%s[/center]" % temp_stats
		item_stats_container.visible = true
		size.y = size.y + 43
		if a_Item_Data["tags"]:
			size.y = size.y + 10
	
	if a_Item_Data["extra_rules"]:
		item_rules_label.text = a_Item_Data["extra_rules"]
		item_rules_container.visible = true
		
		var min_x = item_rules_label.size.x
		var temp_font_size = get_theme_default_font_size()
		var text_height = get_theme_default_font().get_multiline_string_size(a_Item_Data["extra_rules"], HORIZONTAL_ALIGNMENT_CENTER, min_x, temp_font_size).y
		
		size.y = size.y + int(text_height/8.0) + 30
	
	if a_Item_Data["action_data"]:
		var action_data = a_Item_Data["action_data"]
		
		if a_Item_Data["type"] != "passive":
			engage_text_label.text = "Engage (%sAP)" % str(action_data["ap_cost"])
			engage_text_label.visible = true
			
			size.y = size.y + 23
		
		if a_Item_Data["type"] in weapon_internals:
			engage_text_label.text += ": %s Attack" % a_Item_Data["type"].to_upper()
			
			if action_data.has("marble_damage") && action_data["marble_damage"] != 0:
				range_damage_label.text = "Range %s - Marble Damage [%s]" % [str(action_data["range"]), str(action_data["marble_damage"])]
			else:
				range_damage_label.text = "Range %s - Damage [%s]" % [str(action_data["range"]), str(action_data["damage"])]
			
			range_damage_label.visible = true
			size.y = size.y + 23
		
		if action_data["action_text"]:
			item_description_label.text = "Effect: %s" % action_data["action_text"]
			item_description_container.visible = true
			
			var min_x = item_description_label.size.x
			var temp_font_size = get_theme_default_font_size()
			var text_height = get_theme_default_font().get_multiline_string_size(action_data["action_text"], HORIZONTAL_ALIGNMENT_CENTER, min_x, temp_font_size).y
			
			size.y = size.y + int(text_height/8.0) + 50
		
	if !(item_description_container.visible or item_rules_container.visible or range_damage_label.visible or engage_text_label.visible or temp_stats):
		middle_text_container.visible = false
		size.y = size.y - (middle_text_container.size.y)
