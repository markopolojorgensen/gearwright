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
@onready var unlocks_remaining: Label = %UnlocksRemainingLabel
@onready var nameplate: Label = %LevelBackgroundNameplate
@onready var gear_ability_title: Label = %GearAbilityTitle
@onready var gear_ability_text: Label = %GearAbilityText
@onready var core_integrity_control: Control = %CoreIconContainer
@onready var repair_kits_control: Control = %RepairIconContainer
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
@onready var fsh_export_popup: Popup = $FshExportPopup
@onready var png_export_popup: Popup = $PngExportPopup
@onready var open_file_dialog: FileDialog = $OpenFileDialog

@onready var gear_section_controls = {
	GearwrightActor.GSIDS.FISHER_HEAD:      %HeadGearSectionControl,
	GearwrightActor.GSIDS.FISHER_TORSO:     %TorsoGearSectionControl,
	GearwrightActor.GSIDS.FISHER_LEFT_ARM:  %LeftArmGearSectionControl,
	GearwrightActor.GSIDS.FISHER_RIGHT_ARM: %RightArmGearSectionControl,
	GearwrightActor.GSIDS.FISHER_LEGS:      %LegsGearSectionControl,
}

@onready var part_menu: PartMenu = %PartMenu
const part_menu_tabs := ["Head", "Chest", "Arm", "Leg", "Curios"]

@onready var inventory_system: DiabloStyleInventorySystem = $DiabloStyleInventorySystem

var current_character := GearwrightCharacter.new()

# don't call update_controls() directly, use this
# prevents many updates on a single frame
#   also prevents ui from asking for data before it's loaded
var request_update_controls := false

var image_to_save: Image

var enforce_weight_cap := true
var enforce_hardpoint_cap := true
# TODO: enforce tags

#region initialization

func _ready():
	global_util.verbose = debug
	if not debug:
		$ModeDebugLabel.hide()
	
	floating_explanation_control.hide()
	
	for option_button in development_option_buttons:
		option_button.perk_selected.connect(func(perk_slot: int, perk: String):
			current_character.set_perk(PerkOptionButton.PERK_TYPE.DEVELOPMENT, perk_slot, perk)
			request_update_controls = true
			)
	
	for option_button in maneuver_option_buttons:
		option_button.perk_selected.connect(func(perk_slot: int, perk: String):
			current_character.set_perk(PerkOptionButton.PERK_TYPE.MANEUVER, perk_slot, perk)
			request_update_controls = true
			)
	
	for option_button in deep_word_option_buttons:
		option_button.perk_selected.connect(func(perk_slot: int, perk: String):
			current_character.set_perk(PerkOptionButton.PERK_TYPE.DEEP_WORD, perk_slot, perk)
			request_update_controls = true
			)
	
	for background_id in DataHandler.background_data.keys():
		var nice_name: String = DataHandler.background_data[background_id].background
		background_option_button.add_item(nice_name)
	_on_background_option_button_item_selected.call_deferred(0)
	
	for stat_name in custom_bg_stat_edit_controls.keys():
		var custom_bg_control = custom_bg_stat_edit_controls[stat_name]
		custom_bg_control.increase.connect(_on_custom_bg_change.bind(stat_name, true))
		custom_bg_control.decrease.connect(_on_custom_bg_change.bind(stat_name, false))
	custom_bg_popup.hide()
	
	for tab_name in part_menu_tabs:
		part_menu.add_tab(tab_name)
	
	for item_id in DataHandler.item_data.keys():
		var item_data = DataHandler.get_internal_data(item_id)
		var section_id: String = item_data.section
		if section_id == "any":
			for tab_name in part_menu_tabs:
				if tab_name != "Curios":
					part_menu.add_part_to_tab(tab_name, item_id, item_data)
		elif is_curio(item_data):
			part_menu.add_part_to_tab("Curios", item_id, item_data)
		elif section_id.capitalize() in part_menu_tabs:
			var tab_name = section_id.capitalize()
			part_menu.add_part_to_tab(tab_name, item_id, item_data)
		else:
			var error = "unknown tab '%s' for item: %s" % [section_id, item_id]
			push_error(error)
			print(error)

func is_curio(item_data: Dictionary):
	for tag in item_data.tags:
		if "fathomless" in tag.to_lower():
			return true
	return false

#endregion




















func _process(_delta):
	$ModeDebugLabel.text = "Mode: %s" % str(inventory_system.get_mode())
	
	# TODO switch to InputContext style
	if Input.is_action_just_pressed("mouse_leftclick"):
		if (
				png_export_popup.visible
				or fsh_export_popup.visible
				or open_file_dialog.visible
				or internals_reset_dialog.visible
				or hardpoints_reset_dialog.visible
				or custom_bg_popup.visible
				or global_util.is_warning_popup_active()
		):
			return
		inventory_system.leftclick(current_character)
	elif Input.is_action_just_pressed("mouse_rightclick"):
		inventory_system.rightclick(current_character)
	
	if request_update_controls:
		request_update_controls = false
		update_controls.call_deferred()





















#region Reactivity

# Grid Slots

func _on_slot_mouse_entered(slot_info: Dictionary):
	inventory_system.on_slot_mouse_entered(slot_info, current_character)
	request_update_controls = true

func _on_slot_mouse_exited(slot_info: Dictionary):
	inventory_system.on_slot_mouse_exited(slot_info)
	request_update_controls = true

# TODO probably move these, huh
# entered
func _on_head_gear_section_control_slot_entered(slot_info: Dictionary) -> void:
	_on_slot_mouse_entered(slot_info)

func _on_chest_gear_section_control_slot_entered(slot_info: Dictionary) -> void:
	_on_slot_mouse_entered(slot_info)

func _on_left_arm_gear_section_control_slot_entered(slot_info: Dictionary) -> void:
	_on_slot_mouse_entered(slot_info)

func _on_right_arm_gear_section_control_slot_entered(slot_info: Dictionary) -> void:
	_on_slot_mouse_entered(slot_info)

func _on_legs_gear_section_control_slot_entered(slot_info: Dictionary) -> void:
	_on_slot_mouse_entered(slot_info)

# exited
func _on_head_gear_section_control_slot_exited(slot_info: Dictionary) -> void:
	_on_slot_mouse_exited(slot_info)

func _on_chest_gear_section_control_slot_exited(slot_info: Dictionary) -> void:
	_on_slot_mouse_exited(slot_info)

func _on_left_arm_gear_section_control_slot_exited(slot_info: Dictionary) -> void:
	_on_slot_mouse_exited(slot_info)

func _on_right_arm_gear_section_control_slot_exited(slot_info: Dictionary) -> void:
	_on_slot_mouse_exited(slot_info)

func _on_legs_gear_section_control_slot_exited(slot_info: Dictionary) -> void:
	_on_slot_mouse_exited(slot_info)






var current_hover_stat := ""
func _on_stats_list_control_stat_mouse_entered(stat_name: String) -> void:
	current_hover_stat = stat_name
	floating_explanation_control.text = current_character.get_stat_explanation(stat_name)

func _on_stats_list_control_stat_mouse_exited(stat_name: String) -> void:
	if current_hover_stat == stat_name:
		current_hover_stat = ""
		floating_explanation_control.text = ""





func _on_part_menu_item_spawned(item_id: Variant) -> void:
	inventory_system.on_part_menu_item_spawned(item_id)
	request_update_controls = true

func _on_level_selector_value_changed(value: float) -> void:
	var new_level := int(round(value))
	current_character.set_level(new_level)
	request_update_controls = true

func _on_unlock_toggle_button_down():
	inventory_system.toggle_unlock_mode()
	request_update_controls = true

func _on_callsign_line_edit_text_changed(new_text: String) -> void:
	current_character.callsign = new_text
	# don't request update_controls() here, it messes with callsign lineedit

func _on_background_option_button_item_selected(index: int) -> void:
	var nice_name: String = background_option_button.get_item_text(index)
	var bg_id := nice_name.to_snake_case()
	current_character.load_background(bg_id)
	request_update_controls = true

func _on_edit_background_button_pressed() -> void:
	if custom_bg_popup.visible:
		custom_bg_popup.hide()
		edit_bg_button.text = "Edit Background"
		stats_list_control.set_mouse_detector_filters(true)
	else:
		custom_bg_popup.show()
		edit_bg_button.text = "Save Background"
		stats_list_control.set_mouse_detector_filters(false)

# connected to custom bg widget in _ready
func _on_custom_bg_change(stat_name: String, is_increase: bool):
	current_character.modify_custom_background(stat_name, is_increase)
	request_update_controls = true

func _on_diablo_style_inventory_system_something_changed() -> void:
	request_update_controls = true

func _on_save_menu_button_button_selected(button_id: int) -> void:
	if button_id == SaveLoadMenuButton.BUTTON_IDS.NEW_ACTOR:
		get_tree().reload_current_scene()
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.SAVE_TO_FILE:
		fsh_export_popup.set_line_edit_text(current_character.callsign)
		fsh_export_popup.popup()
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.SAVE_TO_PNG:
		# grab image before covering it up with export popup
		callsign_line_edit.release_focus()
		await get_tree().process_frame
		await get_tree().process_frame
		var border_rect := Rect2i(%MechImageRegion.get_global_rect())
		image_to_save = get_viewport().get_texture().get_image().get_region(border_rect)
		
		png_export_popup.set_line_edit_text(current_character.callsign)
		png_export_popup.popup()
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.LOAD_FROM_FILE:
		open_file_dialog.popup()
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.SAVES_FOLDER:
		global.open_folder("Saves")
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.IMAGES_FOLDER:
		global.open_folder("Screenshots")

func _on_fsh_export_popup_export(filename: String) -> void:
	var path = "user://Saves/" + filename
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	#file.store_string(get_user_data_string())
	file.store_string(JSON.stringify(current_character.marshal(), "  "))
	file.close()
	
	global.open_folder("Saves")

func _on_png_export_popup_export(filename: String) -> void:
	image_to_save.save_png("user://Screenshots/" + filename)
	global.open_folder("Screenshots")

func _on_open_file_dialog_file_selected(path: String) -> void:
	inventory_system.drop_item()
	current_character.reset_gear_sections() # prevent lingering items
	
	var file = FileAccess.open(path, FileAccess.READ)
	var file_text = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(file_text) != Error.OK:
		var message = "JSON Parse Error at line %d: '%s'" % [json.get_error_line(), json.get_error_message()]
		global_util.popup_warning("Failed to load fisher!", message)
		push_warning(message)
		return
	
	var info: Dictionary = json.data as Dictionary
	current_character = GearwrightCharacter.unmarshal(info)
	current_character.enforce_weight_cap = enforce_weight_cap
	current_character.enforce_hardpoint_cap = enforce_hardpoint_cap
	var internals := current_character.get_equipped_items()
	for internal_info in internals:
		if not internal_info.internal.is_inside_tree():
			add_child(internal_info.internal)
	
	request_update_controls = true

func _on_weight_cap_check_button_toggled(toggled_on: bool) -> void:
	enforce_weight_cap = toggled_on
	current_character.enforce_weight_cap = toggled_on

func _on_unlocks_check_button_toggled(toggled_on: bool) -> void:
	enforce_hardpoint_cap = toggled_on
	current_character.enforce_hardpoint_cap = toggled_on





## Reactivity - things that reset internals

func _on_internals_reset_confirm_dialog_confirmed():
	current_character.unequip_all_internals()
	request_update_controls = true

func _on_frame_selector_load_frame(frame_name: String):
	current_character.load_frame(frame_name)
	request_update_controls = true

func _on_hardpoints_reset_confirm_dialog_confirmed():
	current_character.reset_gear_sections()
	request_update_controls = true

#endregion
















#region Rendering

func update_controls():
	inventory_system.fancy_update(current_character, gear_section_controls)
	
	update_stats_list_control()
	
	# frame selector
	var frame_index := global_util.set_option_button_by_item_text(
			frame_selector,
			current_character.frame_name
	)
	if frame_index == -1:
		push_error("update_controls: bad frame: %s" % current_character.frame_name)
	
	# level spinner
	level_selector.set_value_no_signal(current_character.level)
	
	# hardpoint info
	var used_unlock_count = current_character.get_unlocked_slots_count()
	var max_unlock_count = current_character.get_max_unlocks()
	var unlocks_left_count: int = max_unlock_count - used_unlock_count
	unlocks_remaining.text = "Unlocks Remaining:\n%d/%d" % [
		unlocks_left_count,
		max_unlock_count,
	]
	if enforce_hardpoint_cap and unlocks_left_count < 0:
		%UnlocksLabelShaker.start_shaking()
	else:
		%UnlocksLabelShaker.stop_shaking()
	
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
	var background_index := global_util.set_option_button_by_item_text(
			background_option_button,
			current_character.background_stats.background
	)
	if background_index == -1:
		push_error("update_controls: bad background: %s" % current_character.background_stats.background)
	if current_character.background_stats.background.to_snake_case() == "custom":
		edit_bg_button.disabled = false
	else:
		edit_bg_button.disabled = true
	
	core_integrity_control.update(current_character.get_core_integrity())
	repair_kits_control.update(current_character.get_repair_kits())
	
	# developments
	if 0 < current_character.get_level_development_count():
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
	
	# custom background
	for stat_name in custom_bg_stat_edit_controls.keys():
		var custom_bg_control = custom_bg_stat_edit_controls[stat_name]
		var stat_value = current_character.custom_background.count(stat_name)
		custom_bg_control.value = stat_value
	custom_bg_points_label.text = str(current_character.get_custom_bg_points_remaining())

func update_stats_list_control():
	stats_list_control.update(current_character)
	
	if not enforce_weight_cap:
		stats_list_control.under_weight()
		return
	
	if current_character.is_overweight_with_item(inventory_system.item_held):
		stats_list_control.over_weight()
	else:
		stats_list_control.under_weight()

#endregion






