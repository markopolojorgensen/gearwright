extends OptionButton
class_name PerkOptionButton

# perk is snake_case
signal perk_selected(perk_slot: int, perk: String)

enum PERK_TYPE {
	DEVELOPMENT,
	MANEUVER,
	DEEP_WORD,
}

@export var perk_type: PERK_TYPE = PERK_TYPE.DEVELOPMENT

var perk_info: Dictionary

func _ready():
	perk_info = DataHandler.get_perk_info(perk_type)
	match perk_type:
		PERK_TYPE.DEVELOPMENT, PERK_TYPE.DEEP_WORD:
			add_item("None")
			for value in perk_info.values():
				add_item(value)
		PERK_TYPE.MANEUVER:
			add_item("None")
			var real_perk_info := {}
			var categories := perk_info.keys()
			categories.sort()
			for category in categories:
				add_separator(category.capitalize())
				var maneuvers: Array = perk_info[category]
				for i in range(maneuvers.size()):
					var maneuver: Dictionary = maneuvers[i]
					add_item(maneuver.values().front())
					real_perk_info.merge(maneuver)
			perk_info = real_perk_info
	select(0)

func _on_item_selected(index: int) -> void:
	var perk := ""
	if index != 0:
		perk = perk_info.find_key(get_item_text(index))
	var perk_type_name: String = PERK_TYPE.find_key(perk_type)
	print("%s perk selected: %s in perk slot %d (option %d)" % [perk_type_name, perk, get_index(), index])
	perk_selected.emit(get_index(), perk)

func update(character: GearwrightCharacter):
	match perk_type:
		PERK_TYPE.DEVELOPMENT:
			update_option(character.get_level_development_count(), character.developments)
		PERK_TYPE.MANEUVER:
			update_option(character.get_maneuver_count(), character.maneuvers)
		PERK_TYPE.DEEP_WORD:
			update_option(character.get_deep_word_count(), character.deep_words)

func update_option(index_threshold: int, char_perk_list: Array):
	var index = get_index()
	if index_threshold <= index:
		hide()
		return
	
	show()
	var perk = ""
	if index < char_perk_list.size():
		perk = char_perk_list[index]
	var nice_dev_name = perk_info.get(perk, "None")
	for i in range(item_count):
		if get_item_text(i) == nice_dev_name:
			select(i)
			break









