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
var fish_scale: float = 1.0

@onready var fish_name_input: LineEdit = %FishNameInput

@onready var export_view_container: Container = %ExportViewContainer
@onready var fsh_export_popup: Popup = $FshExportPopup
@onready var png_export_popup: Popup = $PngExportPopup
var image_to_save: Image
@onready var open_file_dialog: FileDialog = $OpenFileDialog

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
		internal_name = internal_name as String
		var infos: Array = infos_by_internal_name[internal_name]
		var legend_number_start: int = legend_number
		#var legend_number_end: int = legend_number
		for info in infos:
			info = info as Dictionary
			info.internal.set_legend_number(legend_number)
			#legend_number_end = legend_number
			#legend_number += 1
		var legend_item := internals_legend_list_item_scene.instantiate()
		legend_item.set_legend_name(internal_name.capitalize())
		legend_item.set_legend_number(str(legend_number_start))
		#if legend_number_start == legend_number_end:
		#else:
			## never used now, lol
			#legend_item.set_legend_number("%d-%d" % [legend_number_start, legend_number_end])
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
			for gsid in GearwrightFish.LEVIATHAN_FISH_GSIDS:
				create_gear_section_control(gsid)
			fish_scale = 1.75
			position_leviathan.call_deferred()
		GearwrightFish.SIZE.SERPENT_LEVIATHAN:
			for gsid in GearwrightFish.SERPENT_LEVIATHAN_FISH_GSIDS:
				create_gear_section_control(gsid)
			fish_scale = 1.25
			position_serpent_leviathan.call_deferred()
		GearwrightFish.SIZE.SILTSTALKER_LEVIATHAN:
			for gsid in GearwrightFish.SILTSTALKER_LEVIATHAN_FISH_GSIDS:
				create_gear_section_control(gsid)
			fish_scale = 1.5
			position_siltstalker_leviathan.call_deferred()
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
	var actual_scale = min(factor.x, factor.y) * 0.9
	fish_scale = actual_scale
	inventory_system.control_scale = fish_scale
	control.scale = Vector2(1.0, 1.0) * fish_scale

func center_control_manually(control: Control, location: Vector2):
	control.global_position = location - (control.size * 0.5 * control.scale)

const FISH_GRID_GAP: float = 16.0

func position_leviathan():
	var center := %FreeRangeGearSections.get_global_rect().get_center() as Vector2
	var tail_gsc: Control = gear_section_controls[GearwrightFish.FISH_GSIDS.TAIL]
	var body_gsc: Control = gear_section_controls[GearwrightFish.FISH_GSIDS.BODY]
	var head_gsc: Control = gear_section_controls[GearwrightFish.FISH_GSIDS.HEAD]
	
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
	var tip_gsc: Control = gear_section_controls[GearwrightFish.FISH_GSIDS.TIP]
	var tail_gsc: Control = gear_section_controls[GearwrightFish.FISH_GSIDS.TAIL]
	var body_gsc: Control = gear_section_controls[GearwrightFish.FISH_GSIDS.BODY]
	var neck_gsc: Control = gear_section_controls[GearwrightFish.FISH_GSIDS.NECK]
	var head_gsc: Control = gear_section_controls[GearwrightFish.FISH_GSIDS.HEAD]
	
	tip_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	tail_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	body_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	neck_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	head_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	
	center_control_manually(body_gsc, center)
	
	neck_gsc.position.x = body_gsc.position.x + (4 * FISH_GRID_GAP)
	neck_gsc.position.y = body_gsc.position.y - (neck_gsc.size.y * fish_scale) - (FISH_GRID_GAP * 0.5)
	
	head_gsc.position.x = neck_gsc.position.x + (neck_gsc.size.x * fish_scale) + FISH_GRID_GAP
	head_gsc.position.y = neck_gsc.position.y
	
	tail_gsc.position.x = body_gsc.position.x - (4 * FISH_GRID_GAP)
	tail_gsc.position.y = body_gsc.position.y + (body_gsc.size.y * fish_scale) + (FISH_GRID_GAP * 0.5)
	
	tip_gsc.position.x = tail_gsc.position.x - (tip_gsc.size.x * fish_scale) - FISH_GRID_GAP
	tip_gsc.position.y = tail_gsc.position.y

func position_siltstalker_leviathan():
	var center := %FreeRangeGearSections.get_global_rect().get_center() as Vector2
	#center.y += FISH_GRID_GAP
	var llegs_gsc: Control = gear_section_controls[GearwrightFish.FISH_GSIDS.LEFT_LEGS]
	var body_gsc: Control = gear_section_controls[GearwrightFish.FISH_GSIDS.BODY]
	var rlegs_gsc: Control = gear_section_controls[GearwrightFish.FISH_GSIDS.RIGHT_LEGS]
	var larm_gsc: Control = gear_section_controls[GearwrightFish.FISH_GSIDS.LEFT_ARM]
	var rarm_gsc: Control = gear_section_controls[GearwrightFish.FISH_GSIDS.RIGHT_ARM]
	
	llegs_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	body_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	rlegs_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	larm_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	rarm_gsc.scale = Vector2(1.0, 1.0) * fish_scale
	
	#center_control_manually(body_gsc, center)
	
	body_gsc.global_position.x = center.x - (body_gsc.size.x * fish_scale * 0.5)
	body_gsc.global_position.y = center.y - (body_gsc.size.y * fish_scale) - (FISH_GRID_GAP * 0.25)
	
	llegs_gsc.position.x = body_gsc.position.x - (llegs_gsc.size.x * fish_scale) - FISH_GRID_GAP
	llegs_gsc.position.y = body_gsc.position.y
	
	rlegs_gsc.position.x = body_gsc.position.x + (body_gsc.size.x * fish_scale) + FISH_GRID_GAP
	rlegs_gsc.position.y = body_gsc.position.y
	
	larm_gsc.global_position.x = center.x - (larm_gsc.size.x * fish_scale) - (FISH_GRID_GAP * 0.5)
	larm_gsc.global_position.y = center.y + (FISH_GRID_GAP * 0.25)
	
	rarm_gsc.global_position.x = center.x + (FISH_GRID_GAP * 0.5)
	rarm_gsc.position.y = larm_gsc.position.y


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

func _on_stats_list_control_stat_mouse_exited(stat_name) -> void:
	if current_hover_stat == stat_name:
		current_hover_stat = ""
		floating_explanation_control.text = ""

func _on_template_selector_type_selected(fish_type: GearwrightFish.TYPE) -> void:
	current_character.set_fish_type(fish_type)
	request_update_controls = true

func _on_mutation_change(stat_name: String, is_increase: bool):
	current_character.modify_mutation(stat_name, is_increase)
	request_update_controls = true

# TODO disconnect & yeet
func _on_save_options_menu_new_fish_pressed() -> void:
	get_tree().reload_current_scene()

func _on_save_menu_button_button_selected(button_id: SaveLoadMenuButton.BUTTON_IDS) -> void:
	if button_id == SaveLoadMenuButton.BUTTON_IDS.NEW_ACTOR:
		get_tree().reload_current_scene()
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.SAVE_TO_FILE:
		fsh_export_popup.set_line_edit_text(current_character.callsign)
		fsh_export_popup.popup()
	elif button_id == SaveLoadMenuButton.BUTTON_IDS.SAVE_TO_PNG:
		# grab image before covering it up with export popup
		fish_name_input.release_focus()
		await get_tree().process_frame
		await get_tree().process_frame
		var border_rect := Rect2i(export_view_container.get_global_rect())
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
	var json := JSON.stringify(current_character.marshal(), "  ")
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(json)
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
	var new_fish := GearwrightFish.unmarshal(info)
	_on_fish_size_selector_fish_size_selected(new_fish.size)
	current_character = new_fish
	# TODO maybe yeet get_equipped_items
	var internals := current_character.get_equipped_items()
	for internal_info in internals:
		if not internal_info.internal.is_inside_tree():
			add_child(internal_info.internal)
	
	request_update_controls = true

func _on_fish_name_input_text_changed(new_text: String) -> void:
	current_character.callsign = new_text

#endregion






















