extends Control

const gear_section_control_scene = preload("res://actor_builders/inventory_system/gear_section_control.tscn")

const part_menu_tabs := ["Far", "Close", "Mental", "Active", "Passive", "Mitigation"]
@onready var part_menu: PartMenu = %PartMenu

const internals_legend_list_item_scene := preload("res://actor_builders/fish_builder/internal_legend_list_item.tscn")
@onready var internals_legend_container: Container = %InternalsLegendContainer

@onready var inventory_system: DiabloStyleInventorySystem = $DiabloStyleInventorySystem
@onready var fish_size_selector: OptionButton = %FishSizeSelector
@onready var floating_explanation_control: Control = $FloatingExplanationControl
@onready var fish_name_input: LineEdit = %FishNameInput
@onready var export_view_container: Container = %ExportViewContainer
@onready var gear_section_controls := {}
@onready var stats_list_control: Container = %StatsListControl
@onready var popup_collection = %PopupCollection
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
@onready var empty_hardpoints_label: Label = %EmptyHardpointsLabel

var request_update_controls: bool = false
var current_character := GearwrightFish.new()
# this is a pun
# these are scale values for the gear section controls
var fish_scale: float = 1.0
var legend_font_size = 21

# duplicated in mech_builder, alas
var enforce_tags := true

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
	current_character.enforce_tags = enforce_tags
	_on_fish_size_selector_fish_size_selected.call_deferred(current_character.size)
	inventory_system.current_actor = current_character
	inventory_system.clear_slot_info()
	
	for gear_section_control in gear_section_controls.values():
		gear_section_control.slot_entered.connect(_on_slot_entered)
		gear_section_control.slot_exited.connect(_on_slot_exited)
	
	for stat_name in mutation_edit_controls.keys():
		var mutation_control = mutation_edit_controls[stat_name]
		mutation_control.increase.connect(_on_mutation_change.bind(stat_name, true))
		mutation_control.decrease.connect(_on_mutation_change.bind(stat_name, false))
	
	$LostDataPreventer.saved_data = current_character.marshal()
	
	register_ic_fish_builder_base()
	input_context_system.push_input_context(input_context_system.INPUT_CONTEXT.FISH_BUILDER)
	
	if global.path_to_shortcutted_file != null:
		await get_tree().process_frame
		input_context_system.push_input_context(input_context_system.INPUT_CONTEXT.POPUP_ACTIVE)
		popup_collection._on_open_file_dialog_file_selected(global.path_to_shortcutted_file)
		global.path_to_shortcutted_file = null
		set_deferred("request_update_controls", true)



func register_ic_fish_builder_base():
	var ic := InputContext.new()
	ic.id = input_context_system.INPUT_CONTEXT.FISH_BUILDER
	ic.activate = func(_is_stack_growing: bool):
		stats_list_control.set_mouse_detector_filters(true)
	ic.deactivate = func(_is_stack_growing: bool):
		stats_list_control.set_mouse_detector_filters(false)
	ic.handle_input = func(event: InputEvent):
		if event.is_action_pressed("mouse_leftclick"):
			if inventory_system.pickup_item():
				get_viewport().set_input_as_handled()
		elif event.is_action_pressed("mouse_rightclick"):
			if inventory_system.item_info_popup():
				get_viewport().set_input_as_handled()
	input_context_system.register_input_context(ic)

func _process(_delta: float) -> void:
	%InputContextDebugLabel.text = "Context: %s" % input_context_system.get_current_input_context_name().capitalize()
	%FishScaleLabel.text = "Fish Scale: %.2f" % fish_scale
	
	if request_update_controls:
		request_update_controls = false
		update_controls()


func update_controls():
	inventory_system.fancy_update(current_character, gear_section_controls)
	
	global_util.set_option_button_by_item_text(fish_size_selector, GearwrightFish.get_size_as_string(current_character.size))
	global_util.set_option_button_by_item_text(%TypeSelector, GearwrightFish.get_type_as_string(current_character.type))
	
	stats_list_control.update(current_character)
	
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
	
	for info in internal_infos:
		info.internal.scale = Vector2(fish_scale, fish_scale)
	
	# key: internal_name
	# value: list of infos
	var infos_by_internal_name := {}
	for i in range(internal_infos.size()):
		# {
		#  "slot": {"gear_section_name": "right_arm", "gear_section_id": 2, "x": 1, "y": 0},
		#  "internal_name": "thorn_spitter_i",
		#  "internal": Item:<Node2D#406730067125>
		# }
		var info: Dictionary = internal_infos[i]
		var internal_name: String = info.internal_name
		internal_name = internal_name.to_snake_case()
		if not infos_by_internal_name.has(internal_name):
			infos_by_internal_name[internal_name] = []
		infos_by_internal_name[internal_name].append(info)
	
	var legend_number: int = 0
	for internal_name in infos_by_internal_name.keys():
		legend_number += 1
		internal_name = internal_name as String # redundant
		var infos: Array = infos_by_internal_name[internal_name]
		var legend_number_start: int = legend_number
		#var legend_number_end: int = legend_number
		for info in infos:
			info = info as Dictionary
			info.internal.set_legend_number(legend_number, %LegendNumbersCheckButton.button_pressed)
			internal_name = info.internal.item_data.name
			#legend_number_end = legend_number
			#legend_number += 1
		var legend_item := internals_legend_list_item_scene.instantiate()
		#legend_item.set_legend_name(internal_name.capitalize())
		legend_item.set_legend_name(internal_name)
		legend_item.set_legend_number(str(legend_number_start))
		var info := infos.front() as Dictionary
		legend_item.set_color.call_deferred(global.colors[info.internal.item_data.type])
		internals_legend_container.add_child(legend_item)
	
	fish_name_input.text = current_character.callsign
	
	var empty_hardpoint_count := current_character.get_empty_hardpoint_count()
	empty_hardpoints_label.text = "Empty Hardpoints: %d" % empty_hardpoint_count
	if empty_hardpoint_count <= 6:
		empty_hardpoints_label.modulate = Color.LIGHT_GREEN
	else:
		empty_hardpoints_label.modulate = Color.LIGHT_CORAL
	
	for legend_item in internals_legend_container.get_children():
		legend_item.set_font_size(legend_font_size)
	await get_tree().process_frame
	
	# legend size
	var total_height: float = get_internal_legend_items_total_height()
	while (legend_font_size < 20) and (total_height <= (internals_legend_container.get_parent().size.y * 0.7)):
		legend_font_size = clamp(legend_font_size + 1, 1, 20)
		for legend_item in internals_legend_container.get_children():
			legend_item.set_font_size(legend_font_size)
		await get_tree().process_frame
		total_height = get_internal_legend_items_total_height()
	const min_font_size = 8
	total_height = get_internal_legend_items_total_height()
	while (min_font_size < legend_font_size) and (internals_legend_container.get_parent().size.y <= total_height):
		legend_font_size = clamp(legend_font_size - 1, min_font_size, 20)
		for legend_item in internals_legend_container.get_children():
			legend_item.set_font_size(legend_font_size)
		await get_tree().process_frame
		total_height = get_internal_legend_items_total_height()

func get_internal_legend_items_total_height() -> float:
	return global_util.sum_array(internals_legend_container.get_children().map(func(control: Control):
		return control.size.y + 4 # internals_legend_container.get_theme_constant("separation")
	))










#region Fish Sizes

func _on_fish_size_selector_fish_size_selected(fish_size: GearwrightFish.SIZE) -> void:
	$LostDataPreventer.current_data = current_character.marshal()
	$LostDataPreventer.check_lost_data(change_fish_size.bind(fish_size))

func change_fish_size(fish_size: GearwrightFish.SIZE) -> void:
	current_character.reset_gear_sections()
	
	current_character = GearwrightFish.new()
	current_character.size = fish_size
	current_character.initialize()
	current_character.enforce_tags = enforce_tags
	inventory_system.current_actor = current_character
	inventory_system.clear_slot_info()
	
	# reinitialize gear section controls
	for gear_section_id in gear_section_controls.keys():
		var gear_section_control: GearSectionControl = gear_section_controls[gear_section_id]
		gear_section_control.reset()
		gear_section_control.queue_free()
	
	gear_section_controls.clear()
	
	var center := %FreeRangeGearSections.get_global_rect().get_center() as Vector2
	match fish_size:
		GearwrightFish.SIZE.SMALL, GearwrightFish.SIZE.MEDIUM:
			var gs_control := create_gear_section_control(GearwrightActor.GSIDS.FISH_BODY)
			# previously they scaled to like 3.2 or something
			fish_scale = 0.8 # same as large automagically scales to
			gs_control.scale = Vector2(1.0, 1.0) * fish_scale
			#automagically_scale_control.call_deferred(gs_control)
			center_control_manually.call_deferred(gs_control, center)
		GearwrightFish.SIZE.LARGE, GearwrightFish.SIZE.MASSIVE:
			var gs_control := create_gear_section_control(GearwrightActor.GSIDS.FISH_BODY)
			automagically_scale_control.call_deferred(gs_control)
			center_control_manually.call_deferred(gs_control, center)
		GearwrightFish.SIZE.LEVIATHAN:
			for gsid in GearwrightFish.LEVIATHAN_FISH_GSIDS:
				create_gear_section_control(gsid)
			fish_scale = 0.5
			position_leviathan.call_deferred()
		GearwrightFish.SIZE.SERPENT_LEVIATHAN:
			for gsid in GearwrightFish.SERPENT_LEVIATHAN_FISH_GSIDS:
				create_gear_section_control(gsid)
			fish_scale = 0.35
			position_serpent_leviathan.call_deferred()
		GearwrightFish.SIZE.SILTSTALKER_LEVIATHAN:
			for gsid in GearwrightFish.SILTSTALKER_LEVIATHAN_FISH_GSIDS:
				create_gear_section_control(gsid)
			fish_scale = 0.4
			position_siltstalker_leviathan.call_deferred()
		_:
			print(fish_size)
			breakpoint
	
	inventory_system.control_scale = fish_scale
	
	for gear_section_control in gear_section_controls.values():
		gear_section_control.slot_entered.connect(_on_slot_entered)
		gear_section_control.slot_exited.connect(_on_slot_exited)
	
	$LostDataPreventer.saved_data = current_character.marshal()
	request_update_controls = true

func create_gear_section_control(gsid: GearwrightActor.GSIDS) -> Control:
	var gs_control: Control = gear_section_control_scene.instantiate()
	gs_control.gear_section_id = gsid
	%FreeRangeGearSections.add_child(gs_control)
	gs_control.initialize(current_character.get_gear_section(gsid))
	gear_section_controls[gsid] = gs_control
	return gs_control

# for gear_section_controls
func automagically_scale_control(control: Control):
	var max_size: Vector2 = %FreeRangeGearSections.size
	var bounded_max_size = max_size * 0.95
	var factor = bounded_max_size / control.size
	var actual_scale = [factor.x, factor.y, 0.8].min() # maxes out at 0.8 for better ux
	fish_scale = actual_scale
	inventory_system.control_scale = fish_scale
	control.scale = Vector2(1.0, 1.0) * fish_scale

func center_control_manually(control: Control, location: Vector2):
	control.global_position = location - (control.size * 0.5 * control.scale)

const FISH_GRID_GAP: float = 32.0

func position_leviathan():
	var center := %FreeRangeGearSections.get_global_rect().get_center() as Vector2
	center.x -= 4
	var tail_gsc: Control = gear_section_controls[GearwrightActor.GSIDS.FISH_TAIL]
	var body_gsc: Control = gear_section_controls[GearwrightActor.GSIDS.FISH_BODY]
	var head_gsc: Control = gear_section_controls[GearwrightActor.GSIDS.FISH_HEAD]
	
	tail_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	body_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	head_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	
	center_control_manually(body_gsc, center)
	
	tail_gsc.position.x = body_gsc.position.x - (tail_gsc.size.x * tail_gsc.scale.x) - FISH_GRID_GAP
	tail_gsc.position.y = body_gsc.position.y
	
	head_gsc.position.x = body_gsc.position.x + (body_gsc.size.x * body_gsc.scale.x) + FISH_GRID_GAP
	head_gsc.position.y = body_gsc.position.y

func position_serpent_leviathan():
	var center := %FreeRangeGearSections.get_global_rect().get_center() as Vector2
	center.y += FISH_GRID_GAP
	var tip_gsc: Control = gear_section_controls[GearwrightActor.GSIDS.FISH_TIP]
	var tail_gsc: Control = gear_section_controls[GearwrightActor.GSIDS.FISH_TAIL]
	var body_gsc: Control = gear_section_controls[GearwrightActor.GSIDS.FISH_BODY]
	var neck_gsc: Control = gear_section_controls[GearwrightActor.GSIDS.FISH_NECK]
	var head_gsc: Control = gear_section_controls[GearwrightActor.GSIDS.FISH_HEAD]
	
	tip_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	tail_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	body_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	neck_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	head_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	
	center_control_manually(body_gsc, center)
	body_gsc.position.x -= 16
	body_gsc.position.y -= 18
	
	neck_gsc.position.x = body_gsc.position.x + (2 * FISH_GRID_GAP)
	neck_gsc.position.y = body_gsc.position.y - (neck_gsc.size.y * fish_scale) - (FISH_GRID_GAP / 8.0)
	
	head_gsc.position.x = neck_gsc.position.x + (neck_gsc.size.x * fish_scale) + FISH_GRID_GAP
	head_gsc.position.y = neck_gsc.position.y
	
	tail_gsc.position.x = body_gsc.position.x - (2 * FISH_GRID_GAP)
	tail_gsc.position.y = body_gsc.position.y + (body_gsc.size.y * fish_scale) + (FISH_GRID_GAP / 8.0)
	
	tip_gsc.position.x = tail_gsc.position.x - (tip_gsc.size.x * fish_scale) - FISH_GRID_GAP
	tip_gsc.position.y = tail_gsc.position.y

func position_siltstalker_leviathan():
	var center := %FreeRangeGearSections.get_global_rect().get_center() as Vector2
	#center.y += FISH_GRID_GAP
	var llegs_gsc: Control = gear_section_controls[GearwrightActor.GSIDS.FISH_LEFT_LEGS]
	var body_gsc: Control = gear_section_controls[GearwrightActor.GSIDS.FISH_BODY]
	var rlegs_gsc: Control = gear_section_controls[GearwrightActor.GSIDS.FISH_RIGHT_LEGS]
	var larm_gsc: Control = gear_section_controls[GearwrightActor.GSIDS.FISH_LEFT_ARM]
	var rarm_gsc: Control = gear_section_controls[GearwrightActor.GSIDS.FISH_RIGHT_ARM]
	
	llegs_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	body_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	rlegs_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	larm_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	rarm_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	
	#center_control_manually(body_gsc, center)
	center.x -= 32
	
	body_gsc.global_position.x = center.x - (body_gsc.size.x * fish_scale * 0.5)
	body_gsc.global_position.y = center.y - (body_gsc.size.y * fish_scale) - (FISH_GRID_GAP * 0.25)
	
	llegs_gsc.position.x = body_gsc.position.x - (llegs_gsc.size.x * fish_scale) - (FISH_GRID_GAP * 0.5)
	llegs_gsc.position.y = body_gsc.position.y
	
	rlegs_gsc.position.x = body_gsc.position.x + (body_gsc.size.x * fish_scale) + (FISH_GRID_GAP * 1.5)
	rlegs_gsc.position.y = body_gsc.position.y
	
	larm_gsc.global_position.x = center.x - (larm_gsc.size.x * fish_scale)# - (FISH_GRID_GAP * 0.5)
	larm_gsc.global_position.y = center.y + (FISH_GRID_GAP * 0.25)
	
	rarm_gsc.global_position.x = center.x + FISH_GRID_GAP # + (FISH_GRID_GAP * 0.5)
	rarm_gsc.position.y = larm_gsc.position.y

#endregion









#region Reactivity

func _on_diablo_style_inventory_system_something_changed() -> void:
	request_update_controls = true

func _on_part_menu_item_spawned(item_id: Variant) -> void:
	inventory_system.on_part_menu_item_spawned(item_id)
	request_update_controls = true

func _on_slot_entered(slot_info: Dictionary):
	inventory_system.on_slot_mouse_entered(slot_info, current_character)
	request_update_controls = true

func _on_slot_exited(slot_info: Dictionary):
	inventory_system.on_slot_mouse_exited(slot_info)
	request_update_controls = true

var current_hover_stat := ""
func _on_stats_list_control_stat_mouse_entered(stat_name: String) -> void:
	current_hover_stat = stat_name
	floating_explanation_control.text = current_character.get_stat_explanation(stat_name)
	
	if stat_name.to_lower() == "weight":
		current_character.get_equipped_items().map(func(info: Dictionary):
			var item = info.get("internal", null)
			if item != null:
				item.show_weight()
				item.hide_legend_number()
			)

func _on_stats_list_control_stat_mouse_exited(stat_name) -> void:
	if current_hover_stat == stat_name:
		current_hover_stat = ""
		floating_explanation_control.text = ""
	
	if stat_name.to_lower() == "weight":
		current_character.get_equipped_items().map(func(info: Dictionary):
			var item = info.get("internal", null)
			if item != null:
				item.hide_weight()
				if %LegendNumbersCheckButton.button_pressed:
					item.show_legend_number()
			)

func _on_template_selector_type_selected(fish_type: GearwrightFish.TYPE) -> void:
	current_character.set_fish_type(fish_type)
	request_update_controls = true

func _on_mutation_change(stat_name: String, is_increase: bool):
	current_character.modify_mutation(stat_name, is_increase)
	request_update_controls = true

func _on_save_menu_button_button_selected(button_id: SaveLoadMenuButton.BUTTON_IDS) -> void:
	if button_id == SaveLoadMenuButton.BUTTON_IDS.NEW_ACTOR:
		$LostDataPreventer.current_data = current_character.marshal()
		$LostDataPreventer.check_lost_data(func():
			input_context_system.clear()
			get_tree().reload_current_scene()
			)
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.SAVE_TO_FILE:
		popup_collection.popup_fsh(current_character)
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.SAVE_TO_PNG:
		# grab image before covering it up with export popup
		fish_name_input.release_focus()
		await get_tree().process_frame
		await get_tree().process_frame
		var border_rect := Rect2i(export_view_container.get_global_rect())
		var image_to_save: Image = get_viewport().get_texture().get_image().get_region(border_rect)
		popup_collection.popup_png(current_character.callsign, image_to_save)
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.LOAD_FROM_FILE:
		$LostDataPreventer.current_data = current_character.marshal()
		$LostDataPreventer.check_lost_data(func(): popup_collection.popup_load_dialog())
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.SAVES_FOLDER:
		global.open_folder(LocalDataHandler.paths["Fish"]["fsh"])
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.IMAGES_FOLDER:
		global.open_folder(LocalDataHandler.paths["Fish"]["png"])

func _on_popup_collection_save_loaded(info: Dictionary) -> void:
	current_character.reset_gear_sections() # prevent lingering items
	var new_fish := GearwrightFish.unmarshal(info)
	change_fish_size(new_fish.size) # skip LostDataPreventer
	current_character = new_fish
	inventory_system.current_actor = current_character
	inventory_system.clear_slot_info()
	current_character.enforce_tags = enforce_tags
	var internals := current_character.get_equipped_items()
	for internal_info in internals:
		if not internal_info.internal.is_inside_tree():
			inventory_system.add_scaled_child(internal_info.internal)
	
	$LostDataPreventer.saved_data = current_character.marshal()
	request_update_controls = true

func _on_open_file_dialog_canceled() -> void:
	input_context_system.pop_to(input_context_system.INPUT_CONTEXT.FISH_BUILDER)

func _on_fish_name_input_text_changed(new_text: String) -> void:
	current_character.callsign = new_text

func _on_internals_reset_confirm_dialog_confirmed() -> void:
	current_character.unequip_all_internals()
	current_character.set_fish_type(GearwrightFish.TYPE.COMMON)
	current_character.callsign = ""
	request_update_controls = true

func _on_tree_exited() -> void:
	input_context_system.clear()

func _on_legend_numbers_check_button_toggled(_toggled_on: bool) -> void:
	request_update_controls = true

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		$LostDataPreventer.current_data = current_character.marshal()
		$LostDataPreventer.check_lost_data(func(): get_tree().quit())

func _on_main_menu_back_button_pressed() -> void:
	$LostDataPreventer.current_data = current_character.marshal()
	$LostDataPreventer.check_lost_data(func(): get_tree().change_scene_to_file("res://main_menu/main_menu.tscn"))

func _on_popup_collection_fsh_saved() -> void:
	$LostDataPreventer.saved_data = current_character.marshal()

func _on_help_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%HelpPanel.show()
	else:
		%HelpPanel.hide()

func _on_tags_check_button_toggled(toggled_on: bool) -> void:
	enforce_tags = toggled_on
	current_character.enforce_tags = toggled_on
	print("setting enforce tags to %s" % str(toggled_on))
	request_update_controls = true


#endregion































