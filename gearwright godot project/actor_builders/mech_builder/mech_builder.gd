extends Control

@export var debug := false

@onready var stats_list_control: Control = %StatsListControl
@onready var internals_reset_dialog: ConfirmationDialog = %InternalsResetConfirmDialog
@onready var hardpoints_reset_dialog: ConfirmationDialog = %HardpointsResetConfirmDialog
@onready var callsign_line_edit: LineEdit = %CallsignLineEdit
@onready var floating_explanation_control: Control = %FloatingExplanationControl

# for control updates
@onready var frame_selector: OptionButton = %FrameSelector
@onready var level_selector: SpinBox = %LevelSelector
@onready var unlocks_remaining_label: Label = %UnlocksRemainingLabel
@onready var unlocks_label_shaker: Node = %UnlocksLabelShaker
@onready var weight_label: Label = %WeightLabel
@onready var weight_label_shaker: Node = %WeightLabelShaker
@onready var nameplate: Label = %LevelBackgroundNameplate
@onready var gear_ability_title: Label = %GearAbilityTitle
@onready var gear_ability_text: Label = %GearAbilityText
@onready var core_integrity_control: Control = %CoreIconContainer
@onready var repair_kits_control: Control = %RepairIconContainer
@onready var developments_title_control: Control = %DevelopmentsPerkSectionTitleControl
@onready var maneuvers_title_control: Control = %ManeuversPerkSectionTitleControl
@onready var deep_words_title_control: Control = %DeepWordsPerkSectionTitleControl
@onready var development_option_buttons := [
	%DevelopmentPerkOptionButton1,
	%DevelopmentPerkOptionButton2,
	%DevelopmentPerkOptionButton3,
	%DevelopmentPerkOptionButton4,
	%DevelopmentPerkOptionButton5,
	%DevelopmentPerkOptionButton6,
	%DevelopmentPerkOptionButton7,
	%DevelopmentPerkOptionButton8,
	%DevelopmentPerkOptionButton9,
	%DevelopmentPerkOptionButton10,
]
@onready var maneuver_option_buttons := [
	%ManeuverPerkOptionButton1,
	%ManeuverPerkOptionButton2,
	%ManeuverPerkOptionButton3,
	%ManeuverPerkOptionButton4,
	%ManeuverPerkOptionButton5,
	%ManeuverPerkOptionButton6,
	%ManeuverPerkOptionButton7,
	%ManeuverPerkOptionButton8,
	%ManeuverPerkOptionButton9,
	%ManeuverPerkOptionButton10,
]
@onready var deep_word_option_buttons := [
	%DeepWordPerkOptionButton1,
	%DeepWordPerkOptionButton2,
	%DeepWordPerkOptionButton3,
	%DeepWordPerkOptionButton4,
	%DeepWordPerkOptionButton5,
	%DeepWordPerkOptionButton6,
	%DeepWordPerkOptionButton7,
	%DeepWordPerkOptionButton8,
	%DeepWordPerkOptionButton9,
	%DeepWordPerkOptionButton10,
]
@onready var background_option_button: OptionButton = %BackgroundOptionButton
@onready var edit_bg_button: Button = %EditBackgroundButton
@onready var custom_bg_popup: Container = %CustomBGPanelContainer
@onready var custom_bg_points_label: Label = %CustomBGPointsLabel
@onready var custom_bg_stat_edit_controls := {
	"marbles":    %MarblesCustomStatEditControl,
	"mental":     %MentalCustomStatEditControl,
	"willpower":  %WillpowerCustomStatEditControl,
	"unlocks":    %UnlocksCustomStatEditControl,
	"weight_cap": %WeightCapCustomStatEditControl,
}
@onready var manual_button: Button = %ManualButton
@onready var popup_collection = %PopupCollection
@onready var perk_info_container: Container = %PerkInfoContainer
@onready var perk_color_panel: PanelContainer = %PerkInfoColorPanel
@onready var perk_title_label: Label = %PerkTitleLabel
@onready var perk_info_label: Label = %PerkInfoLabel

@onready var gear_section_controls = {
	GearwrightActor.GSIDS.FISHER_HEAD:      %HeadGearSectionControl,
	GearwrightActor.GSIDS.FISHER_TORSO:     %TorsoGearSectionControl,
	GearwrightActor.GSIDS.FISHER_LEFT_ARM:  %LeftArmGearSectionControl,
	GearwrightActor.GSIDS.FISHER_RIGHT_ARM: %RightArmGearSectionControl,
	GearwrightActor.GSIDS.FISHER_LEGS:      %LegsGearSectionControl,
}

@onready var descriptor_label_list_widget: Control = %DescriptorLLWidget
@onready var equipment_label_list_widget: Control  = %EquipmentLLWidget

@onready var part_menu: PartMenu = %PartMenu
const part_menu_tabs := ["Head", "Chest", "Arm", "Leg", "Curios"]

@onready var inventory_system: DiabloStyleInventorySystem = $DiabloStyleInventorySystem

var current_character := GearwrightCharacter.new()

# don't call update_controls() directly, use this
# prevents many updates on a single frame
#   also prevents ui from asking for data before it's loaded
var request_update_controls := false

var enforce_weight_cap := true
var enforce_hardpoint_cap := true
var enforce_tags := true

var custom_background_index: int = -1

#region initialization

func _ready():
	get_tree().set_auto_accept_quit(false)
	
	global_util.verbose = debug
	
	floating_explanation_control.hide()
	
	for option_button in development_option_buttons:
		option_button.perk_selected.connect(func(perk_slot: int, perk: String):
			var error := current_character.set_perk(PerkOptionButton.PERK_TYPE.DEVELOPMENT, perk_slot, perk)
			if not error.is_empty():
				global_util.rising_text(error, option_button.get_global_rect().end + Vector2(16, -32))
			request_update_controls = true
			)
		option_button.perk_hovered.connect(update_perk_popup.bind(option_button, PerkOptionButton.PERK_TYPE.DEVELOPMENT))
	
	for option_button in maneuver_option_buttons:
		option_button.perk_selected.connect(func(perk_slot: int, perk: String):
			var error := current_character.set_perk(PerkOptionButton.PERK_TYPE.MANEUVER, perk_slot, perk)
			if not error.is_empty():
				global_util.rising_text(error, option_button.get_global_rect().end + Vector2(16, -32))
			request_update_controls = true
			)
		option_button.perk_hovered.connect(update_perk_popup.bind(option_button, PerkOptionButton.PERK_TYPE.MANEUVER))
	
	for option_button in deep_word_option_buttons:
		option_button.perk_selected.connect(func(perk_slot: int, perk: String):
			var error := current_character.set_perk(PerkOptionButton.PERK_TYPE.DEEP_WORD, perk_slot, perk)
			if not error.is_empty():
				global_util.rising_text(error, option_button.get_global_rect().end + Vector2(16, -32))
			request_update_controls = true
			)
		option_button.perk_hovered.connect(update_perk_popup.bind(option_button, PerkOptionButton.PERK_TYPE.DEEP_WORD))
	
	perk_info_container.hide()
	
	var background_data := DataHandler.get_merged_data(DataHandler.DATA_TYPE.BACKGROUND)
	var background_ids = background_data.keys()
	for i in range(background_ids.size()):
		var background_id = background_ids[i]
		if background_id == "custom":
			custom_background_index = i
		var nice_name: String = background_data[background_id].background
		background_option_button.add_item(nice_name)
	_on_background_option_button_item_selected.call_deferred(0)
	
	for stat_name in custom_bg_stat_edit_controls.keys():
		var custom_bg_control = custom_bg_stat_edit_controls[stat_name]
		custom_bg_control.increase.connect(_on_custom_bg_change.bind(stat_name, true))
		custom_bg_control.decrease.connect(_on_custom_bg_change.bind(stat_name, false))
	custom_bg_popup.hide()
	
	for tab_name in part_menu_tabs:
		part_menu.add_tab(tab_name)
	part_menu.add_label_to_tab("Curios", "Only available via\nDevelopment or GM Fiat")
	
	var item_data := DataHandler.get_merged_data(DataHandler.DATA_TYPE.INTERNAL)
	for item_id in item_data.keys():
		var item_info = DataHandler.get_internal_data(item_id)
		var section_id: String = item_info.section
		if section_id == "any":
			for tab_name in part_menu_tabs:
				if tab_name != "Curios":
					part_menu.add_part_to_tab(tab_name, item_id, item_info)
		elif DataHandler.is_curio(item_info):
			part_menu.add_part_to_tab("Curios", item_id, item_info)
		elif section_id.capitalize() in part_menu_tabs:
			var tab_name = section_id.capitalize()
			part_menu.add_part_to_tab(tab_name, item_id, item_info)
		else:
			var error = "unknown tab '%s' for item: %s" % [section_id, item_id]
			push_error(error)
			print(error)
	
	for gear_section_control in gear_section_controls.values():
		gear_section_control.slot_entered.connect(_on_slot_mouse_entered)
		gear_section_control.slot_exited.connect(_on_slot_mouse_exited)
	
	inventory_system.current_actor = current_character
	inventory_system.clear_slot_info()
	
	register_ic_player()
	register_ic_base_mech_builder()
	register_ic_custom_bg()
	register_ic_manual_adjustment()
	register_ic_fisher_profile()
	
	# Narrative Labels
	var label_list_widgets := [
		descriptor_label_list_widget,
		equipment_label_list_widget,
	]
	for label_list_widget in label_list_widgets:
		label_list_widget.label_hovered.connect(_on_narrative_label_hovered)
		label_list_widget.label_added.connect(_on_narrative_label_added)
		label_list_widget.label_removed.connect(_on_narrative_label_removed)
	
	%GearContainer.hide()
	%FisherContainer.hide()
	%UnlocksManualAdjustmentControl.hide()
	%WeightCapManualAdjustmentControl.hide()
	input_context_system.push_input_context(input_context_system.INPUT_CONTEXT.PLAYER)
	_on_tab_bar_tab_changed(0)
	
	
	await get_tree().process_frame
	inventory_system.control_scale = gear_section_controls.values().front().scale.x
	
	$LostDataPreventer.saved_data = current_character.marshal(false)
	$LostDataPreventer.current_data = current_character.marshal(false)
	$LostDataPreventer.checksum()
	
	if global.path_to_shortcutted_file != null:
		await get_tree().process_frame
		input_context_system.push_input_context(input_context_system.INPUT_CONTEXT.POPUP_ACTIVE)
		popup_collection._on_open_file_dialog_file_selected(global.path_to_shortcutted_file)
		global.path_to_shortcutted_file = null
		await get_tree().create_timer(0.2).timeout
		request_update_controls = true




func update_perk_popup(perk: String, option_button: OptionButton, perk_type: PerkOptionButton.PERK_TYPE):
	if perk.is_empty():
		perk_info_container.hide()
		return
	
	perk_info_container.show()
	perk_info_container.set_deferred("size", Vector2())
	var popup = option_button.get_popup()
	if popup.visible:
		perk_info_container.global_position.x = [popup.position.x + popup.size.x, option_button.get_global_rect().end.x].max() + 8
	else:
		perk_info_container.global_position.x = option_button.get_global_rect().end.x + 8
	perk_info_container.global_position.y = option_button.get_global_rect().end.y - 24
	var perk_color
	match perk_type:
		PerkOptionButton.PERK_TYPE.DEVELOPMENT:
			var perk_info: Dictionary = DataHandler.get_development_data(perk)
			perk_title_label.text = perk_info.get("name", "")
			perk_info_label.text = perk_info.get("description", "")
			perk_color = global.colors["generic_perk"]
		PerkOptionButton.PERK_TYPE.MANEUVER:
			var perk_info: Dictionary = DataHandler.get_maneuver_data(perk)
			perk_title_label.text = perk_info.get("name", "")
			var text := ""
			# ap and range go on the same line
			var ap_cost = perk_info.get("ap_cost", 0)
			if (ap_cost is int) or (ap_cost is float):
				text += "AP: %d" % int(ap_cost)
			elif ap_cost is String:
				text += "AP: %s" % ap_cost
			if perk_info.has("range"):
				text += " - Range %d" % perk_info["range"]
			text += "\n"
			text += perk_info.get("action_text", "")
			perk_info_label.text = text
			if perk_info.get("category", "") == "mental":
				perk_color = global.colors["mental"]
			else:
				perk_color = global.colors["generic_perk"]
		PerkOptionButton.PERK_TYPE.DEEP_WORD:
			var perk_info: Dictionary = DataHandler.get_deep_word_data(perk)
			perk_title_label.text = perk_info.get("full_name", "")
			var text := ""
			text += "AP: %d" % perk_info.get("ap_cost", 0)
			if perk_info.has("range"):
				text += " - Range: %d" % perk_info.get("range")
			text += "\n"
			if perk_info.has("damage"):
				text += "Damage: %s" % perk_info.damage
			text += perk_info.get("action_text", "")
			if perk_info.has("extra_rules"):
				text += "\n" + perk_info.extra_rules
			var tags := []
			tags = add_tag_string(tags, perk_info, "fathomless")
			if perk_info.has("tags"):
				tags.append_array(perk_info.tags)
			if not tags.is_empty():
				text += "\n" + ", ".join(tags)
			perk_info_label.text = text
			perk_color = global.colors["deep_word"]
	if perk_color == null:
		perk_color_panel.self_modulate = Color.DIM_GRAY.darkened(0.2)
	else:
		perk_color_panel.self_modulate = perk_color
	
	await get_tree().process_frame
	while get_viewport_rect().size.y < perk_info_container.get_global_rect().end.y:
		perk_info_container.position.y -= 1

# this is very awkward
# ideally, the deep_words.json would be changed so all the entries have something like
#   "tags": ["Fathomless 3+"]
# instead of having fathomless be its own key.
func add_tag_string(tag_list: Array, info: Dictionary, tag: String) -> Array:
	if info.has(tag):
		var tag_string := "%s %d" % [tag.capitalize(), info[tag]]
		if tag.to_lower().begins_with("fathomless"):
			tag_string += "+"
		tag_list.append(tag_string)
	return tag_list

func register_ic_base_mech_builder():
	var ic := InputContext.new()
	ic.id = input_context_system.INPUT_CONTEXT.MECH_BUILDER
	ic.activate = func(_is_stack_growing: bool):
		stats_list_control.set_mouse_detector_filters(true)
		$DiabloStyleInventorySystem.show()
		%GearContainer.show()
		if OS.has_feature("editor"):
			$ModeDebugLabel.show()
	ic.deactivate = func(is_stack_growing: bool):
		stats_list_control.set_mouse_detector_filters(false)
		if not is_stack_growing:
			$DiabloStyleInventorySystem.hide()
			%GearContainer.hide()
			$ModeDebugLabel.hide()
			%GearHelpPanel.hide()
	ic.handle_input = func(event: InputEvent):
		if event.is_action_pressed("mouse_leftclick"):
			if inventory_system.pickup_item():
				get_viewport().set_input_as_handled()
		elif event.is_action_pressed("mouse_rightclick"):
			if inventory_system.item_info_popup():
				get_viewport().set_input_as_handled()
	input_context_system.register_input_context(ic)

func register_ic_custom_bg():
	var ic := InputContext.new()
	ic.id = input_context_system.INPUT_CONTEXT.MECH_BUILDER_CUSTOM_BACKGROUND
	ic.activate = func(_is_stack_growing: bool):
		custom_bg_popup.show()
		edit_bg_button.text = "Save Background"
	ic.deactivate = func(_is_stack_growing: bool):
		custom_bg_popup.hide()
		edit_bg_button.text = "Edit Background"
		request_update_controls = true
	ic.handle_input = func(_event: InputEvent):
		pass
	input_context_system.register_input_context(ic)

func register_ic_manual_adjustment():
	var ic := InputContext.new()
	ic.id = input_context_system.INPUT_CONTEXT.MECH_BUILDER_MANUAL_ADJUSTMENT
	ic.activate = func(_is_stack_growing: bool):
		stats_list_control.show_hide_spinboxes(true)
		developments_title_control.show_manual_adjustment_control()
		maneuvers_title_control.show_manual_adjustment_control()
		deep_words_title_control.show_manual_adjustment_control()
		%UnlocksManualAdjustmentControl.show()
		%WeightCapManualAdjustmentControl.show()
		manual_button.text = "Save Manual\nAdjustments"
		manual_button.set_pressed_no_signal(true)
		request_update_controls = true
	ic.deactivate = func(_is_stack_growing: bool):
		stats_list_control.show_hide_spinboxes(false)
		developments_title_control.hide_manual_adjustment_control()
		maneuvers_title_control.hide_manual_adjustment_control()
		deep_words_title_control.hide_manual_adjustment_control()
		%UnlocksManualAdjustmentControl.hide()
		%WeightCapManualAdjustmentControl.hide()
		manual_button.text = "Edit Manual\nAdjustments"
		# don't immediately double-pop
		manual_button.set_pressed_no_signal(false)
		request_update_controls = true
	ic.handle_input = func(event: InputEvent):
		if event.is_action_pressed("mouse_rightclick"):
			if inventory_system.item_info_popup():
				get_viewport().set_input_as_handled()
	input_context_system.register_input_context(ic)

func register_ic_player():
	var ic := InputContext.new()
	ic.id = input_context_system.INPUT_CONTEXT.PLAYER
	ic.activate = func(_is_stack_growing: bool):
		request_update_controls = true
	ic.deactivate = func(_is_stack_growing: bool):
		request_update_controls = true
	ic.handle_input = func(_event: InputEvent):
		pass
	input_context_system.register_input_context(ic)

func register_ic_fisher_profile():
	var ic := InputContext.new()
	ic.id = input_context_system.INPUT_CONTEXT.FISHER_PROFILE
	ic.activate = func(_is_stack_growing: bool):
		%FisherContainer.show()
		request_update_controls = true
	ic.deactivate = func(is_stack_growing: bool):
		if not is_stack_growing:
			%FisherContainer.hide()
			%FisherHelpPanel.hide()
		request_update_controls = true
	ic.handle_input = func(_event: InputEvent):
		pass
	input_context_system.register_input_context(ic)


#endregion




















func _process(_delta):
	$ModeDebugLabel.text = "Context: %s" % input_context_system.get_current_input_context_name().capitalize()
	
	#%UnsavedChangesLabel.text = "Changes Saved?\n"
	#var current_data = current_character.marshal(false)
	#if $LostDataPreventer.saved_data == current_data:
		#%UnsavedChangesLabel.text += "Yes"
	#else:
		#%UnsavedChangesLabel.text += "No"
	
	if request_update_controls:
		request_update_controls = false
		update_controls.call_deferred()





















#region Reactivity

func _on_slot_mouse_entered(slot_info: Dictionary):
	inventory_system.on_slot_mouse_entered(slot_info, current_character)
	request_update_controls = true

func _on_slot_mouse_exited(slot_info: Dictionary):
	inventory_system.on_slot_mouse_exited(slot_info)
	request_update_controls = true


var current_hover_stat := ""
func _on_stats_list_control_stat_mouse_entered(stat_name: String) -> void:
	current_hover_stat = stat_name
	request_update_controls = true

func _on_stats_list_control_stat_mouse_exited(stat_name: String) -> void:
	if current_hover_stat == stat_name:
		current_hover_stat = ""
		floating_explanation_control.text = ""
		request_update_controls = true

func _on_weight_mouse_detector_safe_mouse_entered() -> void:
	current_character.get_equipped_items().map(func(info: Dictionary):
		var item = info.get("internal", null)
		if item != null:
			item.show_weight()
		)
	_on_stats_list_control_stat_mouse_entered("weight_cap")

func _on_weight_mouse_detector_safe_mouse_exited() -> void:
	current_character.get_equipped_items().map(func(info: Dictionary):
		var item = info.get("internal", null)
		if item != null:
			item.hide_weight()
		)
	_on_stats_list_control_stat_mouse_exited("weight_cap")

func _on_unlocks_mouse_detector_safe_mouse_entered() -> void:
	_on_stats_list_control_stat_mouse_entered("unlocks")

func _on_unlocks_mouse_detector_safe_mouse_exited() -> void:
	_on_stats_list_control_stat_mouse_exited("unlocks")




func _on_part_menu_item_spawned(item_id: Variant) -> void:
	input_context_system.pop_to(input_context_system.INPUT_CONTEXT.MECH_BUILDER)
	inventory_system.on_part_menu_item_spawned(item_id)
	request_update_controls = true

func _on_level_selector_value_changed(value: float) -> void:
	var new_level := int(round(value))
	current_character.set_level(new_level)
	request_update_controls = true

func _on_unlock_toggle_button_down():
	var unlock_id = input_context_system.INPUT_CONTEXT.INVENTORY_SYSTEM_UNLOCK
	if input_context_system.get_current_input_context_id() == unlock_id:
		input_context_system.pop_input_context_stack()
	else:
		input_context_system.pop_to(input_context_system.INPUT_CONTEXT.MECH_BUILDER)
		input_context_system.push_input_context(unlock_id)
	#inventory_system.toggle_unlock_mode()
	request_update_controls = true

func _on_callsign_line_edit_text_changed(new_text: String) -> void:
	current_character.callsign = new_text
	# don't request update_controls() here, it messes with callsign lineedit

func _on_background_option_button_item_selected(index: int) -> void:
	var nice_name: String = background_option_button.get_item_text(index)
	if index == custom_background_index:
		nice_name = "Custom"
	var bg_id := nice_name.to_snake_case()
	current_character.load_background(bg_id)
	request_update_controls = true

func _on_edit_background_button_pressed() -> void:
	if input_context_system.get_current_input_context_id() == input_context_system.INPUT_CONTEXT.MECH_BUILDER_CUSTOM_BACKGROUND:
		input_context_system.pop_input_context_stack()
	else:
		input_context_system.pop_to(input_context_system.INPUT_CONTEXT.MECH_BUILDER)
		input_context_system.push_input_context(input_context_system.INPUT_CONTEXT.MECH_BUILDER_CUSTOM_BACKGROUND)


# connected to custom bg widget in _ready
func _on_custom_bg_change(stat_name: String, is_increase: bool):
	current_character.modify_custom_background(stat_name, is_increase)
	request_update_controls = true

# toggled_on reflects the new state, not the old one
func _on_manual_button_toggled(toggled_on: bool) -> void:
	global_util.fancy_print("manual button toggled signal", true)
	if (not toggled_on) and (input_context_system.get_current_input_context_id() == input_context_system.INPUT_CONTEXT.MECH_BUILDER_MANUAL_ADJUSTMENT):
		input_context_system.pop_input_context_stack()
	elif toggled_on:
		input_context_system.pop_to(input_context_system.INPUT_CONTEXT.MECH_BUILDER)
		input_context_system.push_input_context(input_context_system.INPUT_CONTEXT.MECH_BUILDER_MANUAL_ADJUSTMENT)

func _on_stats_list_control_manual_stat_increase(stat_name: String) -> void:
	current_character.manual_stat_increase(stat_name)
	request_update_controls = true

func _on_stats_list_control_manual_stat_decrease(stat_name: String) -> void:
	current_character.manual_stat_decrease(stat_name)
	request_update_controls = true

func _on_unlocks_manual_adjustment_control_increase() -> void:
	current_character.manual_stat_increase("unlocks")
	request_update_controls = true

func _on_unlocks_manual_adjustment_control_decrease() -> void:
	current_character.manual_stat_decrease("unlocks")
	request_update_controls = true

func _on_weight_cap_manual_adjustment_control_increase() -> void:
	current_character.manual_stat_increase("weight_cap")
	request_update_controls = true

func _on_weight_cap_manual_adjustment_control_decrease() -> void:
	current_character.manual_stat_decrease("weight_cap")
	request_update_controls = true

func _on_developments_perk_section_title_control_increase() -> void:
	current_character.manual_stat_change("developments", 1)
	request_update_controls = true

func _on_developments_perk_section_title_control_decrease() -> void:
	current_character.manual_stat_change("developments", -1)
	request_update_controls = true

func _on_maneuvers_perk_section_title_control_increase() -> void:
	current_character.manual_stat_change("maneuvers", 1)
	request_update_controls = true

func _on_maneuvers_perk_section_title_control_decrease() -> void:
	current_character.manual_stat_change("maneuvers", -1)
	request_update_controls = true

func _on_deep_words_perk_section_title_control_increase() -> void:
	current_character.manual_stat_change("deep_words", 1)
	request_update_controls = true

func _on_deep_words_perk_section_title_control_decrease() -> void:
	current_character.manual_stat_change("deep_words", -1)
	request_update_controls = true

func _on_diablo_style_inventory_system_something_changed() -> void:
	request_update_controls = true

func _on_save_menu_button_button_selected(button_id: int) -> void:
	
	
	if button_id == SaveLoadMenuButton.BUTTON_IDS.NEW_ACTOR:
		$LostDataPreventer.current_data = current_character.marshal(false)
		$LostDataPreventer.check_lost_data(func():
			input_context_system.clear()
			get_tree().reload_current_scene()
			)
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.SAVE_TO_FILE:
		popup_collection.popup_fsh_export_dialog(current_character)
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.SAVE_TO_PNG:
		# grab image before covering it up with export popup
		callsign_line_edit.release_focus()
		# in case we're in narrative mode
		input_context_system.pop_to(input_context_system.INPUT_CONTEXT.PLAYER)
		input_context_system.push_input_context(input_context_system.INPUT_CONTEXT.MECH_BUILDER)
		await get_tree().process_frame
		await get_tree().process_frame
		var border_rect := Rect2i(%MechImageRegion.get_global_rect())
		var image_to_save: Image = get_viewport().get_texture().get_image().get_region(border_rect)
		popup_collection.popup_png_file_dialog(current_character.callsign, image_to_save)
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.LOAD_FROM_FILE:
		$LostDataPreventer.current_data = current_character.marshal(false)
		$LostDataPreventer.check_lost_data(func(): popup_collection.popup_load_dialog())
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.SAVES_FOLDER:
		global.open_folder(DataHandler.save_paths["Gear"]["fsh"])
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.IMAGES_FOLDER:
		global.open_folder(DataHandler.save_paths["Gear"]["png"])

func _on_popup_collection_save_loaded(info: Dictionary) -> void:
	current_character.reset_gear_sections() # prevent lingering items
	current_character = GearwrightCharacter.unmarshal(info)
	inventory_system.current_actor = current_character
	inventory_system.clear_slot_info()
	current_character.enforce_weight_cap = enforce_weight_cap
	current_character.enforce_hardpoint_cap = enforce_hardpoint_cap
	current_character.enforce_tags = enforce_tags
	var internals := current_character.get_equipped_items()
	for internal_info in internals:
		if not internal_info.internal.is_inside_tree():
			inventory_system.add_scaled_child(internal_info.internal)
	
	$LostDataPreventer.saved_data = current_character.marshal(false)
	request_update_controls = true

func _on_weight_cap_check_button_toggled(toggled_on: bool) -> void:
	enforce_weight_cap = toggled_on
	current_character.enforce_weight_cap = toggled_on
	request_update_controls = true

func _on_unlocks_check_button_toggled(toggled_on: bool) -> void:
	enforce_hardpoint_cap = toggled_on
	current_character.enforce_hardpoint_cap = toggled_on
	request_update_controls = true

func _on_tags_check_button_toggled(toggled_on: bool) -> void:
	enforce_tags = toggled_on
	current_character.enforce_tags = toggled_on
	request_update_controls = true

enum MECH_BUILDER_TAB {
	GEAR,
	FISHER,
}

func _on_tab_bar_tab_changed(tab: int) -> void:
	var new_tab: MECH_BUILDER_TAB = MECH_BUILDER_TAB.values()[tab]
	input_context_system.pop_to(input_context_system.INPUT_CONTEXT.PLAYER)
	match new_tab:
		MECH_BUILDER_TAB.GEAR:
			input_context_system.push_input_context(input_context_system.INPUT_CONTEXT.MECH_BUILDER)
		MECH_BUILDER_TAB.FISHER:
			input_context_system.push_input_context(input_context_system.INPUT_CONTEXT.FISHER_PROFILE)

# connected in _ready to label list widgets
func _on_narrative_label_hovered(label_id: String):
	if label_id == "custom":
		%NarrativeLabelInfoContainer.hide()
		%CustomNarrativeLabelContainer.show()
		return
	else:
		%NarrativeLabelInfoContainer.show()
		%CustomNarrativeLabelContainer.hide()
	
	var label_info: Dictionary
	if current_character.custom_label_info.has(label_id):
		label_info = current_character.custom_label_info[label_id]
	else:
		label_info = DataHandler.get_label_data(label_id)
	%InfoNameLabel.text = label_info.name
	%InfoTypeLabel.text = "[i]%s[/i]" % label_info.label_type.capitalize()
	%InfoDescriptionLabel.text = label_info.description

# connected in _ready to label list widgets
func _on_narrative_label_added(label_id: String):
	if label_id == "custom":
		_on_narrative_custom_label_add_button_pressed()
		return
	
	current_character.add_label(label_id)
	request_update_controls = true

# connected in _ready to label list widgets
func _on_narrative_label_removed(label_id: String):
	current_character.remove_label(label_id)
	request_update_controls = true

func _on_backlash_stat_edit_control_increase() -> void:
	current_character.backlash = clamp(current_character.backlash + 1, 0, INF) 
	request_update_controls = true

func _on_backlash_stat_edit_control_decrease() -> void:
	current_character.backlash = clamp(current_character.backlash - 1, 0, INF) 
	request_update_controls = true

func _on_narrative_custom_label_add_button_pressed() -> void:
	var label_info := {}
	label_info.name = %NarrativeCustomLineEdit.text
	label_info.name = label_info.name.left(20)
	if %CustomLabelEquipmentCheckBox.button_pressed:
		label_info.label_type = "equipment"
	else:
		label_info.label_type = "descriptor"
	label_info.description = %CustomLabelTextEdit.text
	
	var label_id: String = label_info.name.to_snake_case()
	current_character.custom_label_info[label_id] = label_info
	current_character.custom_labels.append(label_id)
	
	request_update_controls = true

func _on_narrative_marbles_stat_edit_control_increase() -> void:
	current_character.modify_current_marbles(1)
	request_update_controls = true

func _on_narrative_marbles_stat_edit_control_decrease() -> void:
	current_character.modify_current_marbles(-1)
	request_update_controls = true

func _on_custom_background_name_line_edit_text_changed(new_text: String) -> void:
	current_character.custom_background_name = new_text.left(18)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		$LostDataPreventer.current_data = current_character.marshal(false)
		$LostDataPreventer.check_lost_data(func(): get_tree().quit())

func _on_main_menu_back_button_pressed() -> void:
	$LostDataPreventer.current_data = current_character.marshal(false)
	$LostDataPreventer.check_lost_data(func(): get_tree().change_scene_to_file("res://main_menu/main_menu.tscn"))

func _on_popup_collection_fsh_saved() -> void:
	$LostDataPreventer.saved_data = current_character.marshal(false)

func _on_help_button_pressed() -> void:
	if %GearContainer.is_visible_in_tree():
		%FisherHelpPanel.hide()
		%GearHelpPanel.visible = not %GearHelpPanel.visible
	else:
		%GearHelpPanel.hide()
		%FisherHelpPanel.visible = not %FisherHelpPanel.visible

func _on_novok_spin_box_value_changed(value: float) -> void:
	global_util.fancy_print("novok changed: %.0f" % value, true)
	current_character.novok = value


## Reactivity - things that reset internals

func _on_internals_reset_confirm_dialog_confirmed():
	current_character.unequip_all_internals()
	request_update_controls = true

func _on_frame_selector_load_frame(frame_name: String):
	# A special case, since the only data that will be lost is unlocks and
	# internals (and frame, but that doesn't matter).
	# so if those are unchanged, we can safely change the frame.
	
	var followup: Callable = func():
		current_character.load_frame(frame_name)
		request_update_controls = true
		$LostDataPreventer.saved_data = current_character.marshal(false)
	
	var saved_unlocks = $LostDataPreventer.saved_data.unlocks
	var saved_internals = $LostDataPreventer.saved_data.internals
	var current_marshalled = current_character.marshal(false)
	var current_unlocks = current_marshalled.unlocks
	var current_internals = current_marshalled.internals
	
	if (saved_unlocks == current_unlocks) and (saved_internals == current_internals):
		followup.call()
	else:
		$LostDataPreventer.current_data = current_character.marshal(false)
		$LostDataPreventer.check_lost_data(followup)

func _on_hardpoints_reset_confirm_dialog_confirmed():
	current_character.reset_gear_sections()
	request_update_controls = true

#endregion
















#region Rendering

func update_controls():
	inventory_system.fancy_update(current_character, gear_section_controls)
	
	stats_list_control.update(current_character)
	%UnlocksManualAdjustmentControl.get_spin_box().value = current_character.get_manual_stat_adjustment("unlocks")
	%WeightCapManualAdjustmentControl.get_spin_box().value = current_character.get_manual_stat_adjustment("weight_cap")
	
	# frame selector
	var frame_index := global_util.set_option_button_by_item_text(
			frame_selector,
			current_character.frame_name
	)
	if frame_index == -1:
		push_error("update_controls: bad frame: %s" % current_character.frame_name)
	
	# level spinner
	level_selector.set_value_no_signal(current_character.level)
	
	# hardpoint unlocks
	var used_unlock_count = current_character.get_unlocked_slots_count()
	var max_unlock_count = current_character.get_stat("unlocks")
	var unlocks_left_count: int = max_unlock_count - used_unlock_count
	#unlocks_remaining_label.text = "Unlocks Remaining:\n%d/%d" % [
	#unlocks_remaining_label.text = "Unlocks Remaining: %d/%d" % [
	unlocks_remaining_label.text = "%d/%d" % [
		unlocks_left_count,
		max_unlock_count,
	]
	if enforce_hardpoint_cap and unlocks_left_count < 0:
		unlocks_label_shaker.start_shaking()
	else:
		unlocks_label_shaker.stop_shaking()
	
	# weight
	var weight: int = current_character.get_stat("weight")
	var weight_cap: int = current_character.get_stat("weight_cap")
	#weight_label.text = "Weight:\n%d/%d" % [
	#weight_label.text = "Weight: %d/%d" % [
	weight_label.text = "%d/%d" % [
		weight,
		weight_cap,
	]
	if enforce_weight_cap and current_character.is_overweight_with_item(inventory_system.item_held):
		weight_label_shaker.start_shaking()
	else:
		weight_label_shaker.stop_shaking()
	
	nameplate.text = "EL %s | %s" % [
		str(current_character.level),
		current_character.frame_name.capitalize(),
	]
	
	callsign_line_edit.text = current_character.callsign
	
	# gear ability title & body text
	var ability_text = current_character.frame_stats.gear_ability
	gear_ability_text.text = ability_text
	gear_ability_title.text = "Gear Ability:\n%s" % current_character.frame_stats.gear_ability_name
	
	# background
	var current_background: String = current_character.background_stats.background
	if current_background.to_lower() == "custom":
		edit_bg_button.disabled = false
		if current_character.custom_background_name.is_empty():
			background_option_button.set_item_text(custom_background_index, "Custom")
		else:
			background_option_button.set_item_text(
					custom_background_index,
					current_character.custom_background_name
			)
		background_option_button.select(custom_background_index)
		current_background = current_character.custom_background_name
	else:
		edit_bg_button.disabled = true
		var background_index := global_util.set_option_button_by_item_text(
				background_option_button,
				current_background
		)
		if background_index == -1:
			push_error("update_controls: bad background: %s" % current_character.background_stats.background)
	
	core_integrity_control.update(current_character.get_core_integrity())
	repair_kits_control.update(current_character.get_stat("repair_kits"))
	
	# developments
	if 0 < current_character.get_development_count():
		%DevelopmentPlaceholder.hide()
	else:
		%DevelopmentPlaceholder.show()
	for option_button in development_option_buttons:
		option_button.update(current_character)
	
	# maneuvers
	if 0 < current_character.get_maneuver_count():
		%ManeuverPlaceholder.hide()
	else:
		%ManeuverPlaceholder.show()
	for option_button in maneuver_option_buttons:
		option_button.update(current_character)
	
	# deep words
	if 0 < current_character.get_deep_word_count():
		%DeepWordPlaceholder.hide()
	else:
		%DeepWordPlaceholder.show()
	for option_button in deep_word_option_buttons:
		option_button.update(current_character)
	
	# perk manual adjustments
	var manual_amount: int = current_character.get_manual_stat_adjustment("developments")
	developments_title_control.get_manual_adjustment_spinbox().set_value(manual_amount)
	manual_amount = current_character.get_manual_stat_adjustment("maneuvers")
	maneuvers_title_control.get_manual_adjustment_spinbox().set_value(manual_amount)
	manual_amount = current_character.get_manual_stat_adjustment("deep_words")
	deep_words_title_control.get_manual_adjustment_spinbox().set_value(manual_amount)
	
	# custom background
	for stat_name in custom_bg_stat_edit_controls.keys():
		var custom_bg_control = custom_bg_stat_edit_controls[stat_name]
		var stat_value = current_character.custom_background.count(stat_name)
		custom_bg_control.value = stat_value
	custom_bg_points_label.text = str(current_character.get_custom_bg_points_remaining())
	%CustomBackgroundNameLineEdit.text = current_character.custom_background_name
	
	# hover explanation
	if not current_hover_stat.is_empty() and input_context_system.is_in_stack(input_context_system.INPUT_CONTEXT.MECH_BUILDER):
		floating_explanation_control.text = current_character.get_stat_explanation(current_hover_stat)
	
	
	
	# Narrative page
	
	%NarrativeCallsignLabel.text = current_character.callsign
	%NarrativeBGLabel.text = "[i]%s[/i]" % current_background
	
	# labels
	# has to be a list to support duplicates
	var label_infos := []
	for label_id in current_character.labels:
		var label_info: Dictionary = DataHandler.get_label_data(label_id).duplicate()
		label_info.label_id = label_id
		label_infos.append(label_info)
	for label_id in current_character.custom_labels:
		var label_info: Dictionary = current_character.custom_label_info[label_id]
		label_info.label_id = label_id
		label_infos.append(label_info)
	equipment_label_list_widget.set_fisher_labels(label_infos)
	descriptor_label_list_widget.set_fisher_labels(label_infos)
	
	# backlash
	%BacklashStatEditControl.value = current_character.backlash
	
	# current marbles
	if current_character.are_marbles_quantum():
		%NarrativeMarblesStatEditControl.value = current_character.get_stat("marbles")
	else:
		%NarrativeMarblesStatEditControl.value = current_character.current_marbles
	%NarrativeMarblesStatEditControl.max_value = current_character.get_stat("marbles")
	
	%NovokSpinBox.value = current_character.novok

#endregion












































