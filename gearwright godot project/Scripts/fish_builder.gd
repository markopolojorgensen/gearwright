extends Control

@onready var part_menu: PartMenu = %PartMenu
const part_menu_tabs := ["Far", "Close", "Mental", "Active", "Passive", "Mitigation"]

@onready var inventory_system: DiabloStyleInventorySystem = $DiabloStyleInventorySystem
const gear_section_control_scene = preload("res://Scenes/gear_section_control.tscn")
@onready var gear_section_controls := {}
	#GearwrightFish.FISH_GSIDS.TIP: %TipGearSectionControl,
	#GearwrightFish.FISH_GSIDS.TAIL: %TailGearSectionControl,
	#GearwrightFish.FISH_GSIDS.BODY: %BodyGearSectionControl,
	#GearwrightFish.FISH_GSIDS.NECK: %NeckGearSectionControl,
	#GearwrightFish.FISH_GSIDS.HEAD: %HeadGearSectionControl,
	#GearwrightFish.FISH_GSIDS.LEFT_LEGS: %LeftLegsGearSectionControl,
	#GearwrightFish.FISH_GSIDS.RIGHT_LEGS: %RightLegsGearSectionControl,
	#GearwrightFish.FISH_GSIDS.LEFT_ARM: %LeftArmGearSectionControl,
	#GearwrightFish.FISH_GSIDS.RIGHT_ARM: %RightArmGearSectionControl,
#}
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

const internals_legend_list_item_scene := preload("res://Scenes/internal_legend_list_item.tscn")
@onready var internals_legend_container: Container = %InternalsLegendContainer

var request_update_controls: bool = false

var current_character := GearwrightFish.new()

# this is a pun
# these are scale values for the gear section controls
const fish_scales := {
	GearwrightFish.SIZE.SMALL:                 Vector2(1.0, 1.0) * 2.0,
	GearwrightFish.SIZE.MEDIUM:                Vector2(1.0, 1.0) * 1.8,
	GearwrightFish.SIZE.LARGE:                 Vector2(1.0, 1.0) * 1.6,
	GearwrightFish.SIZE.MASSIVE:               Vector2(1.0, 1.0) * 1.4,
	GearwrightFish.SIZE.LEVIATHAN:             Vector2(1.0, 1.0),
	GearwrightFish.SIZE.SERPENT_LEVIATHAN:     Vector2(1.0, 1.0),
	GearwrightFish.SIZE.SILTSTALKER_LEVIATHAN: Vector2(1.0, 1.0),
}
var fish_scale: float = 1.0

@onready var export_view_container: Container = %ExportViewContainer

@onready var fish_name_input: LineEdit = %FishNameInput

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
	_on_fish_size_selector_fish_size_selected.call_deferred(current_character.size)
	
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
	
	global_util.clear_children(internals_legend_container)
	var internal_infos := current_character.get_equipped_items()
	for i in range(internal_infos.size()):
		# {
		#  "slot": {"gear_section_name": "right_arm", "gear_section_id": 2, "x": 1, "y": 0},
		#  "internal_name": "thorn_spitter_i",
		#  "internal": Item:<Node2D#406730067125>
		# }
		var info: Dictionary = internal_infos[i]
		info.internal.set_legend_number(i+1)
		var legend_item := internals_legend_list_item_scene.instantiate()
		legend_item.set_legend_name(info.internal_name.capitalize())
		legend_item.set_legend_number(i+1)
		internals_legend_container.add_child(legend_item)
	
	fish_name_input.text = current_character.callsign


















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
		gear_section_control.queue_free()
		#if current_character.has_gear_section(gear_section_id):
			#gear_section_control.show()
			## gear_section_control.scale = fish_scales[fish_size]
		#else:
			#gear_section_control.hide()
	
	gear_section_controls.clear()
	
	var center := %FreeRangeGearSections.get_global_rect().get_center() as Vector2
	#var icon := Sprite2D.new()
	#icon.texture = preload("res://Assets/Icon.png")
	#icon.scale = Vector2(0.01, 0.01)
	#add_child(icon)
	#icon.position = center
	match fish_size:
		GearwrightFish.SIZE.SMALL, GearwrightFish.SIZE.MEDIUM, GearwrightFish.SIZE.LARGE, GearwrightFish.SIZE.MASSIVE:
			var gs_control := create_gear_section_control(GearwrightFish.FISH_GSIDS.BODY)
			automagically_scale_control.call_deferred(gs_control)
			center_control_manually.call_deferred(gs_control, center)
		GearwrightFish.SIZE.LEVIATHAN:
			for gsid in [GearwrightFish.FISH_GSIDS.TAIL, GearwrightFish.FISH_GSIDS.BODY, GearwrightFish.FISH_GSIDS.HEAD]:
				create_gear_section_control(gsid)
			fish_scale = 2.0
			position_leviathan.call_deferred()
		GearwrightFish.SIZE.SERPENT_LEVIATHAN:
			pass
		GearwrightFish.SIZE.SILTSTALKER_LEVIATHAN:
			pass
		_:
			print(fish_size)
			breakpoint
	
	inventory_system.control_scale = fish_scale
	
	for gear_section_control in gear_section_controls.values():
		gear_section_control.slot_entered.connect(_on_slot_entered)
		gear_section_control.slot_exited.connect(_on_slot_exited)
	
	request_update_controls = true

func create_gear_section_control(gsid: GearwrightFish.FISH_GSIDS) -> Control:
	var gs_control: Control = gear_section_control_scene.instantiate()
	gs_control.is_fish_mode = true
	gs_control.fish_gear_section_id = gsid
	%FreeRangeGearSections.add_child(gs_control)
	gs_control.initialize(current_character.get_gear_section(gsid))
	gear_section_controls[gsid] = gs_control
	return gs_control

# for gear_section_controls
func automagically_scale_control(control: Control):
	var max_size: Vector2 = %FreeRangeGearSections.size
	var factor = max_size / control.size
	var actual_scale = min(factor.x, factor.y)
	fish_scale = actual_scale
	inventory_system.control_scale = fish_scale
	control.scale = Vector2(1.0, 1.0) * actual_scale

func center_control_manually(control: Control, location: Vector2):
	control.global_position = location - (control.size * 0.5 * control.scale)

func position_leviathan():
	var center := %FreeRangeGearSections.get_global_rect().get_center() as Vector2
	var tail_gsc: Control = gear_section_controls[GearwrightFish.FISH_GSIDS.TAIL]
	var body_gsc: Control = gear_section_controls[GearwrightFish.FISH_GSIDS.BODY]
	var head_gsc: Control = gear_section_controls[GearwrightFish.FISH_GSIDS.HEAD]
	
	tail_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	body_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	head_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	
	center_control_manually(body_gsc, center)
	
	tail_gsc.position.x = body_gsc.position.x - (tail_gsc.size.x * tail_gsc.scale.x) - 16
	tail_gsc.position.y = body_gsc.position.y
	
	head_gsc.position.x = body_gsc.position.x + (body_gsc.size.x * body_gsc.scale.x) + 16
	head_gsc.position.y = body_gsc.position.y

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

func _on_save_options_menu_new_fish_pressed() -> void:
	get_tree().reload_current_scene()

#endregion















