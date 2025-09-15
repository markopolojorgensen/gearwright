extends Container

@onready var header_color_rect: ColorRect = %HeaderColorRect
@onready var name_label = %NameLabel
@onready var type_label: Label = %ItemTypeLabel
@onready var weight_label: Label = %WeightLabel

@onready var middle_text_container = %MiddleContainer
@onready var middle_text: RichTextLabel = %MiddleText

@onready var footer_container = %FooterContainer
@onready var footer_color_rect = %FooterColorRect
@onready var item_tags_label = %ItemTagsLabel

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

var optics_ignore_tags := [
	"close",
	"far",
	"sensors",
]

var engine_ignore_tags := [
	"ap",
]

var stats_to_use_allcaps_for = [
	"close",
	"far",
	"power",
	"ap"
]

var weapon_internals = ["close", "far", "mental"]

const max_widget_width: float = 600.0

func _process(_delta: float) -> void:
	if max_widget_width < size.x:
		middle_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		custom_minimum_size.x = max_widget_width
		return # wait for resize
	
	var viewport_rect: Rect2 = get_viewport_rect()
	if not get_viewport_rect().encloses(get_rect()):
		position.x = clamp(position.x, viewport_rect.position.x, viewport_rect.end.x - size.x)
		position.y = clamp(position.y, viewport_rect.position.y, viewport_rect.end.y - size.y)

func _ready():
	if global_util.was_run_directly(self):
		set_data(DataHandler.get_internal_data("close_optics_i"))
		position = Vector2(100, 100)


func set_data(a_Item_Data):
	var item_type = a_Item_Data["type"]
	header_color_rect.color = global.colors[item_type]
	footer_color_rect.color = global.colors[item_type]
	
	name_label.text = a_Item_Data["name"]
	
	var is_weapon = item_type in weapon_internals
	if is_weapon:
		type_label.text = "%s Weapon" % item_type.to_upper()
	else:
		type_label.text = "%s Internal" % item_type.capitalize()
	
	weight_label.text = "Weight %d" % a_Item_Data["weight"]
	
	
	var action_data: Dictionary = a_Item_Data.get("action_data", {})
	var tags: Array = a_Item_Data.get("tags", [])
	
	var middle_text_lines := []
	if not action_data.is_empty():
		# engage line
		if item_type != "passive":
			var engage_line := "Engage (%dAP)" % int(action_data.get("ap_cost", 0))
			if is_weapon:
				engage_line += ": %s Attack" % item_type.to_upper()
			middle_text_lines.append(engage_line)
		
		# range line
		if is_weapon:
			var range_line := ""
			if action_data.has("marble_damage") && action_data["marble_damage"] != 0:
				range_line = "Range %d - Marble Damage [%d]" % [action_data["range"], action_data["marble_damage"]]
			else:
				range_line = "Range %d - Damage [%d]" % [action_data["range"], action_data["damage"]]
			if not range_line.is_empty():
				middle_text_lines.append(range_line)
		
		# Effect
		if action_data.has("action_text") and not action_data["action_text"].is_empty():
			var effect_text: String = action_data["action_text"]
			effect_text = effect_text.replacen(". ", ".\n")
			effect_text = effect_text.replacen("\n ", "\n")
			middle_text_lines.append("Effect: %s" % effect_text)
	
	if a_Item_Data.has("extra_rules") and not a_Item_Data["extra_rules"].is_empty():
		middle_text_lines.append(a_Item_Data["extra_rules"])
	
	
	var is_optics = "optics" in tags
	var is_engine = "engine" in tags
	var temp_stat_quips := []
	for stat in a_Item_Data:
		if not stat in stats_to_list:
			continue
		if a_Item_Data[stat] == 0:
			continue
		if is_optics and (stat in optics_ignore_tags):
			continue
		if is_engine and (stat in engine_ignore_tags):
			continue
		
		var stat_string := "%s +%d"
		var value = a_Item_Data[stat]
		if value < 0:
			stat_string = "%s %d"
		var stat_name: String
		if stat in stats_to_use_allcaps_for:
			stat_name = stat.to_upper()
		else:
			stat_name = stat.capitalize()
		stat_string = stat_string % [stat_name, value]
		temp_stat_quips.append(stat_string)
	if not temp_stat_quips.is_empty():
		var temp_stats := ", ".join(temp_stat_quips)
		var full_stats_line := "[center]%s[/center]" % temp_stats
		middle_text_lines.append(full_stats_line)
	
	if middle_text_lines.is_empty():
		middle_text_container.visible = false
	else:
		middle_text.text = "\n".join(middle_text_lines)
	
	
	if tags.is_empty():
		footer_container.hide()
	else:
		footer_container.show()
		var temp_tags = "Tags: "
		var pretty_tags = tags.map(func(tag: String): return tag.capitalize())
		temp_tags += ", ".join(pretty_tags)
		item_tags_label.text = "[center]%s[/center]" % temp_tags



