extends OptionButton
class_name PerkOptionButton

# perk is snake_case
signal perk_selected(perk_slot: int, perk: String)
signal perk_hovered(perk: String)

enum PERK_TYPE {
	DEVELOPMENT,
	MANEUVER,
	DEEP_WORD,
}

@export var perk_type: PERK_TYPE = PERK_TYPE.DEVELOPMENT
@export var mental_only := false

var perk_info: Dictionary
var current_index: int = -1

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
				if mental_only and category != "mental":
					continue
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
	#var perk_type_name: String = PERK_TYPE.find_key(perk_type)
	#print("%s perk selected: %s in perk slot %d (option %d)" % [persk_type_name, perk, get_index(), index])
	if mental_only:
		perk_selected.emit(-1, perk)
	else:
		perk_selected.emit(get_index(), perk)

func update(character: GearwrightCharacter):
	match perk_type:
		PERK_TYPE.DEVELOPMENT:
			update_option(character.get_level_development_count(), character.developments)
		PERK_TYPE.MANEUVER:
			if not mental_only:
				update_option(character.get_maneuver_count(false), character.get_maneuvers(false))
			else:
				update_mental_option(character)
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
	generic_update(perk)


func update_mental_option(character: GearwrightCharacter):
	if not character.has_mental_maneuver():
		hide()
		return
	show()
	
	var maneuvers := character.get_maneuvers(true)
	generic_update(maneuvers.back())

func generic_update(perk: String):
	var nice_name = perk_info.get(perk, "None")
	if nice_name == "None":
		$ColorRect.hide()
	else:
		$ColorRect.show()
	for i in range(item_count):
		if get_item_text(i) == nice_name:
			select(i)
	
	# TODO: disable perks already taken
	# container.option_button.set_item_disabled(container.locations_in_menu.find(maneuver), true)

func _process(_delta: float) -> void:
	var popup_index: int = get_popup().get_focused_item()
	$Label.text = str(popup_index)
	if popup_index != current_index:
		current_index = popup_index
		if 1 <= current_index: # ignore "None" and -1 for nothing hovered
			var perk: String = perk_info.find_key(get_item_text(current_index))
			perk_hovered.emit(perk)
		else:
			perk_hovered.emit("")

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse_rightclick"):
		accept_event()
		var option_text: String = get_item_text(get_selected_id())
		var perk = perk_info.find_key(option_text)
		if perk == null:
			perk_hovered.emit("")
		else:
			perk_hovered.emit(perk)

func _on_mouse_exited() -> void:
	perk_hovered.emit("")
