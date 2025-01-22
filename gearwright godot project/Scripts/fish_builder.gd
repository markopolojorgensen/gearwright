extends Control

@onready var part_menu: PartMenu = %PartMenu
const part_menu_tabs := ["Far", "Close", "Mental", "Active", "Passive", "Mitigation"]

@onready var inventory_system: DiabloStyleInventorySystem = $DiabloStyleInventorySystem
@onready var gear_section_controls := {
	GearwrightFish.GEAR_SECTION_IDS.TIP: %TipGearSectionControl,
	GearwrightFish.GEAR_SECTION_IDS.TAIL: %TailGearSectionControl,
	GearwrightFish.GEAR_SECTION_IDS.BODY: %BodyGearSectionControl,
	GearwrightFish.GEAR_SECTION_IDS.NECK: %NeckGearSectionControl,
	GearwrightFish.GEAR_SECTION_IDS.HEAD: %HeadGearSectionControl,
	GearwrightFish.GEAR_SECTION_IDS.LEFT_LEGS: %LeftLegsGearSectionControl,
	GearwrightFish.GEAR_SECTION_IDS.RIGHT_LEGS: %RightLegsGearSectionControl,
	GearwrightFish.GEAR_SECTION_IDS.LEFT_ARM: %LeftArmGearSectionControl,
	GearwrightFish.GEAR_SECTION_IDS.RIGHT_ARM: %RightArmGearSectionControl,
}
@onready var fish_size_selector: OptionButton = %FishSizeSelector
@onready var floating_explanation_control: Control = $FloatingExplanationControl

@onready var mutation_edit_controls := {
	"close":         %CloseCustomStatEditControl,
	"far":             %FarCustomStatEditControl,
	"mental":       %MentalCustomStatEditControl,
	"power":         %PowerCustomStatEditControl,
	"evasion":     %EvasionCustomStatEditControl,
	"willpower": %WillpowerCustomStatEditControl,
	"speed":         %SpeedCustomStatEditControl,
	"sensors":     %SensorsCustomStatEditControl,
	"ballast":     %BallastCustomStatEditControl,
}

var request_update_controls: bool = false

var current_character := GearwrightFish.new()

func _ready():
	for tab_name in part_menu_tabs:
		part_menu.add_tab(tab_name)
	
	for item_id in DataHandler.fish_item_data.keys():
		var item_data = DataHandler.get_fish_internal_data(item_id)
		var tab_name: String = item_data.type.capitalize()
		if tab_name in part_menu_tabs:
			part_menu.add_part_to_tab(tab_name, item_id, item_data)
		else:
			var error = "unknown tab '%s' for item: %s" % [tab_name, item_id]
			push_error(error)
			print(error)
	
	part_menu.set_grid_column_count(3)
	
	current_character.initialize()
	_on_fish_size_selector_fish_size_selected(current_character.size)
	
	for gear_section_control in gear_section_controls.values():
		gear_section_control.slot_entered.connect(_on_slot_entered)
		gear_section_control.slot_exited.connect(_on_slot_exited)
	
	for stat_name in mutation_edit_controls.keys():
		var mutation_control = mutation_edit_controls[stat_name]
		mutation_control.increase.connect(_on_mutation_change.bind(stat_name, true))
		mutation_control.decrease.connect(_on_mutation_change.bind(stat_name, false))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("mouse_leftclick"):
		#if (export_popup.visible
				#or save_menu.is_popup_active() # file dialog
				#or screenshot_popup.visible
				#or save_menu_popup.visible
				#or internals_reset_dialog.visible
				#or hardpoints_reset_dialog.visible
				#or global_util.is_warning_popup_active()
		#):
			#return
		inventory_system.leftclick(current_character)
	elif Input.is_action_just_pressed("mouse_rightclick"):
		inventory_system.rightclick(current_character)
	
	if request_update_controls:
		request_update_controls = false
		update_controls()

func update_controls():
	inventory_system.fancy_update(current_character, gear_section_controls)
	
	global_util.set_option_button_by_item_text(fish_size_selector, GearwrightFish.get_size_as_string(current_character.size))
	global_util.set_option_button_by_item_text(%TypeSelector, GearwrightFish.get_type_as_string(current_character.type))
	
	%StatsListControl.update(current_character)
	
	# mutations
	%MutationsRemainingLabel.text = str(current_character.get_mutations_remaining())
	%SameMutationsLimitLabel.text = str(current_character.get_same_mutations_limit())
	for mutation_name in mutation_edit_controls.keys():
		var mutation_control = mutation_edit_controls[mutation_name]
		var count: int = current_character.mutations.count(mutation_name)
		mutation_control.value = count
	
	var fish_type_name: String = GearwrightFish.get_type_as_string(current_character.type).capitalize()
	var fish_size_name: String = GearwrightFish.get_size_as_string(current_character.size).capitalize()
	%FishNameplate.text = "%s %s Fish" % [fish_type_name, fish_size_name]

























#region Reactivity

func _on_diablo_style_inventory_system_something_changed() -> void:
	request_update_controls = true

func _on_part_menu_item_spawned(item_id: Variant) -> void:
	inventory_system.on_part_menu_item_spawned(item_id)
	request_update_controls = true

func _on_fish_size_selector_fish_size_selected(fish_size: GearwrightFish.SIZE) -> void:
	current_character.reset_gear_sections()
	
	current_character = GearwrightFish.new()
	current_character.size = fish_size
	current_character.initialize()
	
	# reinitialize gear section controls
	for gear_section_id in gear_section_controls.keys():
		var gear_section_control: GearSectionControl = gear_section_controls[gear_section_id]
		gear_section_control.reset()
		if current_character.has_gear_section(gear_section_id):
			gear_section_control.show()
		else:
			gear_section_control.hide()
	
	request_update_controls = true

func _on_slot_entered(slot_info: Dictionary):
	inventory_system.on_slot_mouse_entered(slot_info, current_character)
	request_update_controls = true

func _on_slot_exited(slot_info: Dictionary):
	inventory_system.on_slot_mouse_exited(slot_info)
	request_update_controls = true

func _on_stats_list_control_stat_mouse_entered(stat_name: String) -> void:
	floating_explanation_control.text = current_character.get_stat_explanation(stat_name)

func _on_stats_list_control_stat_mouse_exited() -> void:
	floating_explanation_control.text = ""

func _on_template_selector_type_selected(fish_type: GearwrightFish.TYPE) -> void:
	current_character.set_fish_type(fish_type)
	request_update_controls = true

func _on_mutation_change(stat_name: String, is_increase: bool):
	current_character.modify_mutation(stat_name, is_increase)
	request_update_controls = true


#endregion













