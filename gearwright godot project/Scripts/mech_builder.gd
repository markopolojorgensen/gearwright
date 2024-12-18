extends Control

const item_scene = preload("res://Scenes/item.tscn")
# const slot_scene = preload("res://Scenes/grid_slot.tscn")

signal item_installed(item)
signal item_removed(item)

#signal set_gear_ability(frame_data)

signal new_save_loaded(user_data)

#signal incrememnt_lock_tally(change)
#signal reset_lock_tally

@export var debug := false

# TODO go through all these and yeet unused ones
#@onready var item_inventory_container: Container = %ItemInventory
#@onready var stats_container: Container = %StatsVBoxContainer
@onready var stats_list_control: Control = %StatsListControl
@onready var export_popup: Popup = %ExportPopup
@onready var screenshot_popup: Popup = %ScreenshotPopup
@onready var internals_reset_dialog: ConfirmationDialog = %InternalsResetConfirmDialog
@onready var hardpoints_reset_dialog: ConfirmationDialog = %HardpointsResetConfirmDialog
#@onready var file_dialog: FileDialog = %FileDialog
@onready var save_menu: MenuButton = %SaveOptionsMenu
@onready var save_menu_popup: PopupMenu = save_menu.get_popup()
@onready var callsign_line_edit: LineEdit = %CallsignLineEdit
@onready var developments_container = %DevelopmentsContainer
@onready var maneuvers_container = %ManeuversContainer
@onready var deep_words_container = %DeepWordsContainer
@onready var floating_explanation_control: Control = %FloatingExplanationControl
@onready var explanation_label: Label = %ExplanationLabel

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
#@onready var background_selector: OptionButton = %BackgroundSelector
@onready var background_option_button: OptionButton = %BackgroundOptionButton
@onready var edit_bg_button: Button = %EditBackgroundButton
@onready var custom_bg_popup: Container = %CustomBGPanelContainer
@onready var custom_bg_points_label: Label = %CustomBGPointsLabel


#@onready var containers = [
	#%ChestContainer,
	#%LeftArmContainer,
	#%RightArmContainer,
	#%HeadContainer,
	#%LegContainer,
#]

@onready var gear_section_controls = {
	GearwrightCharacter.gear_section_ids.HEAD:      %HeadGearSectionControl,
	GearwrightCharacter.gear_section_ids.TORSO:     %TorsoGearSectionControl,
	GearwrightCharacter.gear_section_ids.LEFT_ARM:  %LeftArmGearSectionControl,
	GearwrightCharacter.gear_section_ids.RIGHT_ARM: %RightArmGearSectionControl,
	GearwrightCharacter.gear_section_ids.LEGS:      %LegsGearSectionControl,
}

#var grid_array := []
enum Modes {
	EQUIP,
	PLACE,
	UNLOCK,
}
var mode = Modes.EQUIP
var item_held
#var current_slot

# keys:
#   gear_section_id
#   x
#   y
var current_slot_info: Dictionary
# can't assign null to these, so use current_slot_info.is_empty()
#   to find out if a slot is currently being hovered
var current_gear_section: GearSection
var current_gear_section_control: GearSectionControl
var current_grid_slot: GridSlot
var current_grid_slot_control: GridSlotControl


#var icon_anchor: Vector2

#var default_unlocks := []

#var gear_data = DataHandler.get_gear_template()
#var internals := {}
#var current_frame := ""
#var current_background := ""
#var custom_background := []

var current_character := GearwrightCharacter.new()

# don't call update_controls() directly, use this
# prevents many updates on a single frame
#   also prevents ui from asking for data before it's loaded
var request_update_controls := false





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
	
	#current_character.load_frame("lonestar")
	#for gear_section_id in gear_section_ids.values():
		#print(gear_section_id)
		#print(typeof(gear_section_id))
		#print(gear_section_id_to_name(gear_section_id))
		#print(str(gear_section_controls[gear_section_id]))
		#print(str(gear_sections[gear_section_id]))
		#gear_section_controls[gear_section_id].initialize(gear_sections[gear_section_id])
	
	#item_inventory_container.item_spawned.connect(_on_item_inventory_item_spawned)
	#for container in containers:
		#for i in container.capacity:
			#create_slot(container)

#func create_slot(container):
	#var new_slot = slot_scene.instantiate()
	#new_slot.slot_ID = grid_array.size()
	#container.add_child(new_slot)
	#grid_array.push_back(new_slot)
	#new_slot.slot_entered.connect(_on_slot_mouse_entered)
	#new_slot.slot_exited.connect(_on_slot_mouse_exited)

#endregion








func _process(_delta):
	$ModeDebugLabel.text = "Mode: %s" % str(Modes.find_key(mode))
	
	if Input.is_action_just_pressed("mouse_leftclick"):
		if (export_popup.visible
				or save_menu.is_popup_active() # file dialog
				or screenshot_popup.visible
				or save_menu_popup.visible
				or internals_reset_dialog.visible
				or hardpoints_reset_dialog.visible
				or global_util.is_warning_popup_active()
		):
			return
		match mode:
			Modes.EQUIP:
				pickup_item()
				#for container in containers:
					#if container.get_global_rect().has_point(get_global_mouse_position()):
						#pickup_item()
			Modes.PLACE:
				place_item()
				#for container in containers:
					#if container.get_global_rect().has_point(get_global_mouse_position()):
						#place_item()
			Modes.UNLOCK:
				toggle_current_slot_lock()
				#for container in containers:
					#if container.get_global_rect().has_point(get_global_mouse_position()):
						#toggle_locked()
	elif Input.is_action_just_pressed("mouse_rightclick"):
		match mode:
			Modes.PLACE:
				drop_item()
	
	if request_update_controls:
		request_update_controls = false
		update_controls.call_deferred()
	
	update_floating_explanation_control()

func update_floating_explanation_control():
	if floating_explanation_control.is_visible_in_tree():
		floating_explanation_control.size = Vector2()
		floating_explanation_control.global_position = get_global_mouse_position()
		floating_explanation_control.global_position.x -= floating_explanation_control.size.x


func pickup_item():
	#if not current_slot or not current_slot.installed_item:
		#return
	if current_slot_info.is_empty():
		return
	if not current_grid_slot.installed_item:
		return
	
	#var column_count = current_slot.get_parent().columns
	#item_held = current_slot.installed_item
	item_held = current_grid_slot.installed_item
	item_held.grid_anchor = null
	item_held.selected = true
	
	for cell in current_gear_section.grid.get_valid_entries():
		var grid_slot: GridSlot = current_gear_section.grid.get_contents_v(cell)
		if grid_slot.installed_item == item_held:
			grid_slot.installed_item = null
	#for grid in item_held.item_grids:
		#var grid_to_check = item_held.grid_anchor.slot_ID + grid[0] + grid[1] * column_count
		#grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
		#grid_array[grid_to_check].installed_item = null
		#internals.erase(grid_to_check)
	
	item_removed.emit(item_held)
	#stats_container.update_weight_label_effect(item_held.item_data)
	
	#if is_slot_open(current_slot):
		#set_grids.call_deferred(current_slot)
	
	mode = Modes.PLACE
	
	request_update_controls = true

func place_item():
	if current_slot_info.is_empty():
		return
	
	#if not current_character.is_valid_internal_equip(
			#item_held,
			#current_slot_info.gear_section_id,
			#Vector2i(current_slot_info.x, current_slot_info.y)
	#):
		#return
	var current_slot_cell := Vector2i(current_slot_info.x, current_slot_info.y)
	if not current_character.equip_internal(
			item_held,
			current_slot_info.gear_section_id,
			current_slot_cell
	):
		return
	
	#var column_count = current_slot.get_parent().columns
	#var calculated_grid_id = current_slot.slot_ID + icon_anchor.x * column_count + icon_anchor.y
	#if calculated_grid_id >= grid_array.size():
		#return
	
	#var item_cells := current_character.get_item_cells(
			#item_held,
			#current_slot_info.gear_section_id,
			#current_slot_cell
	#)
	#var top_left_cell = item_cells.reduce(func(best: Vector2i, current: Vector2i):
		#best.x = min(best.x, current.x)
		#best.y = min(best.y, current.y)
		#return best
		#, Vector2i(1000, 1000))
	#var anchor_grid_slot_control: GridSlotControl = current_gear_section_control.control_grid.get_contents_v(top_left_cell)
	
	#item_held.get_parent().remove_child(item_held) # TODO maybe we need this?
	#anchor_grid_slot_control.get_parent().add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	
	#item_held.snap_to(grid_array[calculated_grid_id].global_position)
	#item_held.snap_to(anchor_grid_slot_control.global_position)
	
	#item_held.grid_anchor = current_slot
	#for grid in item_held.item_grids:
		#var grid_to_check = current_slot.slot_ID + grid[0] + grid[1] * column_count
		#grid_array[grid_to_check].state = grid_array[grid_to_check].States.TAKEN
		#grid_array[grid_to_check].installed_item = item_held
	#item_held.grid_anchor = anchor_grid_slot_control
	#for cell in item_cells:
		#if not current_gear_section.grid.is_within_size_v(cell):
			#continue
		#
		#var grid_slot: GridSlot = current_gear_section.grid.get_contents_v(cell)
		#assert(not grid_slot.is_locked)
		#assert(grid_slot.installed_item == null)
		#grid_slot.installed_item = item_held
	#current_grid_slot.is_primary_install_point = true
	
	item_installed.emit(item_held) # TODO yeet?
	#internals[current_slot.slot_ID] = item_held
	
	item_held = null
	mode = Modes.EQUIP
	#stats_container.update_weight_label_effect(null)
	#clear_grid()
	
	request_update_controls = true

func toggle_current_slot_lock():
	if current_slot_info.is_empty():
		return
	
	current_character.toggle_unlock(
			current_slot_info.gear_section_id,
			current_slot_info.x,
			current_slot_info.y
	)
	
	## slot is a default unlock
	#if current_grid_slot.is_default_unlock:
		#return
	## slot has something in it
	#if current_grid_slot.installed_item != null:
		#return
	#
	## locked, but no unlocks left
	## allow player to re-lock non-default unlocked slots
	## allow player to unlock non-default locked slots when they have unlocks left
	#if (current_grid_slot.is_locked) and (not current_character.has_unlocks_remaining()):
		#return
	#
	#current_grid_slot.is_locked = not current_grid_slot.is_locked
	#gear_data["unlocks"] = get_unlocked_slots()
	
	request_update_controls = true
	
	#if not current_slot or not is_lock_toggleable(current_slot):
		#return
	#
	#if current_slot.is_locked:
		#current_slot.unlock()
		#gear_data["unlocks"].push_back(current_slot.slot_ID)
		#incrememnt_lock_tally.emit(1)
		#
	#else:
		#if !current_slot.installed_item:
			#current_slot.lock()
			#gear_data["unlocks"].erase(current_slot.slot_ID)
			#incrememnt_lock_tally.emit(-1)
	#
	#if is_lock_toggleable(current_slot):
		#set_lock_grids.call_deferred(current_slot)

func drop_item():
	if not item_held:
		return
	item_held.queue_free()
	item_held = null
	mode = Modes.EQUIP
	request_update_controls = true

# func check_slot_availability(a_Slot):
# I modified this from the original, not sure if it works anymore lmao
# references to can_place should use this instead I guess
# not sure that is_slot_open is actually a good name, hmmmm
#func is_slot_open(slot_info: Dictionary):
	#var column_count = slot.get_parent().columns
	#for grid in item_held.item_grids:
		#var grid_to_check = slot.slot_ID + grid[0] + grid[1] * column_count
		#var line_switch_check = slot.slot_ID % column_count + grid[0]
		#if line_switch_check < 0 or line_switch_check >= column_count:
			#return false
		#if grid_to_check < 0 or grid_to_check >= grid_array.size():
			#return false
		#if grid_array[grid_to_check].state == grid_array[grid_to_check].States.TAKEN or grid_array[grid_to_check].is_locked:
			#return false
		#if grid_array[grid_to_check].get_parent() != current_slot.get_parent():
			#return false
		#if item_held.item_data["section"] != "any" and !grid_array[grid_to_check].get_parent().get_name().ends_with(item_held.item_data["section"].capitalize() + "Container"):
			#return false
		#if not stats_container.is_under_weight_limit(item_held.item_data):
			#return false
	#
	#return true

#func set_grids(slot):
	#var column_count = slot.get_parent().columns
	#for grid in item_held.item_grids:
		#var grid_to_check = slot.slot_ID + grid[0] + grid[1] * column_count
		#var line_switch_check = slot.slot_ID % column_count + grid[0]
		#if line_switch_check < 0 or line_switch_check >= column_count:
			#continue
		#if grid_to_check < 0 or grid_to_check >= grid_array.size():
			#continue
		#if grid_array[grid_to_check].get_parent() != current_slot.get_parent():
			#continue
		#if is_slot_open(slot):
			#grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.FREE)
			#
			#if grid[1] < icon_anchor.x:
				#icon_anchor.x = grid[1]
			#if grid[0] < icon_anchor.y:
				#icon_anchor.y = grid[0]
		#else:
			#grid_array[grid_to_check].set_color(grid_array[grid_to_check].States.TAKEN)

#func clear_grid():
	#for grid in grid_array:
		#grid.set_color(grid.States.DEFAULT)

# used to be check_lock_availability, modified can_lock
#func is_lock_toggleable(slot):
	#if not slot.is_locked and default_unlocks.has(slot.slot_ID):
		#return false
	#if slot.installed_item:
		#return false
	#if slot.is_locked and not stats_container.unlocks_remaining():
		#return false
	#return true

#func set_lock_grids(slot):
	#if is_lock_toggleable(slot):
		#grid_array[slot.slot_ID].set_color(grid_array[slot.slot_ID].States.FREE)
	#else: 
		#grid_array[slot.slot_ID].set_color(grid_array[slot.slot_ID].States.TAKEN)





















#region Reactivity

# Grid Slots

func _on_slot_mouse_entered(slot_info: Dictionary):
	#icon_anchor = Vector2(10000, 10000)
	#current_slot = a_Slot
	current_slot_info = {}
	current_slot_info.x = slot_info.x
	current_slot_info.y = slot_info.y
	current_slot_info.gear_section_id = slot_info.gear_section_id
	current_gear_section         = current_character.gear_sections[slot_info.gear_section_id]
	current_gear_section_control = slot_info.gear_section_control
	current_grid_slot         = current_gear_section.grid.get_contents(slot_info.x, slot_info.y)
	current_grid_slot_control = slot_info.grid_slot_control
	
	request_update_controls = true
	
	# moved to update_gear_section_controls
	#if item_held:
		#if is_slot_open(current_slot):
			#set_grids.call_deferred(current_slot)
	
	#moved to update_gear_section_controls()
	#if mode == Modes.UNLOCK:
		#if is_slot_open(current_slot):
			#set_lock_grids.call_deferred(current_slot)


func _on_slot_mouse_exited(slot_info: Dictionary):
	if (
			(slot_info.x == current_slot_info.x)
			and (slot_info.y == current_slot_info.y)
			and (slot_info.gear_section_id == current_slot_info.gear_section_id)
	):
		current_slot_info = {}
	request_update_controls = true
	#if mode == Modes.UNLOCK:
		#current_slot.set_color(current_slot.States.TAKEN)
		#for grid in grid_array:
			#if not default_unlocks.has(grid.slot_ID):
				#grid.set_color(grid.States.DEFAULT)
	#else:
		#clear_grid()

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







func _on_stats_list_control_stat_mouse_entered(stat_name: String) -> void:
	explanation_label.text = current_character.get_stat_explanation(stat_name)
	if not explanation_label.text.is_empty():
		floating_explanation_control.show()
		update_floating_explanation_control()

func _on_stats_list_control_stat_mouse_exited() -> void:
	floating_explanation_control.hide()





func _on_item_inventory_item_spawned(item_id):
	if item_held:
		return
	var new_item = item_scene.instantiate()
	add_child(new_item)
	new_item.load_item(item_id)
	new_item.selected = true
	item_held = new_item
	mode = Modes.PLACE
	request_update_controls = true

func _on_level_selector_change_level(new_level: int):
	current_character.set_level(new_level)
	request_update_controls = true
	#gear_data["level"] = a_Level

func _on_save_options_menu_load_save_data(info: Dictionary):
	drop_item()
	current_character.reset_gear_sections() # prevent lingering items
	
	current_character = GearwrightCharacter.unmarshal(info)
	var internals := current_character.get_equipped_items()
	for internal_info in internals:
		if not internal_info.internal.is_inside_tree():
			add_child(internal_info.internal)
	#gear_data = DataHandler.get_gear_template()
	
	if current_character.custom_background.is_empty():
		breakpoint
	%BackgroundEditMenu._on_mech_builder_new_save_loaded(current_character)
	#developments_container._on_level_selector_change_level(current_character.level)
	
	new_save_loaded.emit(info)
	
	request_update_controls = true
	#var temp_unlocks = PackedInt32Array(info["unlocks"])
	#for index in temp_unlocks:
		#if index in gear_data["unlocks"]:
			#breakpoint # tsnh?
			#continue
		#
		#grid_array[index].unlock()
		#gear_data["unlocks"].push_back(index)
		#incrememnt_lock_tally.emit(1)
	#
	#for grid in info["internals"]:
		#print("installing " + info["internals"][grid])
		#install_item(info["internals"][grid], int(grid))

#func install_item(a_Item_ID, _a_Index):
	#if !DataHandler.item_data.has(a_Item_ID):
		#return
	#
	#icon_anchor = Vector2(10000, 10000)
	#var column_count = grid_array[a_Index].get_parent().columns
	#var new_item = item_scene.instantiate()
	#grid_array[a_Index].get_parent().add_child(new_item)
	#new_item.load_item(a_Item_ID.to_snake_case())
	#
	#new_item.grid_anchor = grid_array[a_Index]
	#
	#for grid in new_item.item_grids:
		#if grid[1] < icon_anchor.x: icon_anchor.x = grid[1]
		#if grid[0] < icon_anchor.y: icon_anchor.y = grid[0]
		#var grid_to_check = a_Index + grid[0] + grid[1] * column_count
		#grid_array[a_Index].state = grid_array[grid_to_check].States.TAKEN
		#grid_array[a_Index].installed_item = new_item
	#
	#var calculated_grid_id = a_Index + icon_anchor.x * column_count + icon_anchor.y
	#new_item.snap_to(grid_array[calculated_grid_id].global_position)
	#internals[a_Index] = new_item
	#item_installed.emit(new_item)

func _on_unlock_toggle_button_down():
	if item_held:
		drop_item()
	
	if mode == Modes.UNLOCK:
		#clear_grid()
		mode = Modes.EQUIP
	else:
		mode = Modes.UNLOCK
		#for grid in grid_array:
			#if default_unlocks.has(grid.slot_ID):
				#grid.set_color(grid.States.TAKEN)
	
	request_update_controls = true

func _on_background_selector_load_background(background_name: String):
	current_character.load_background(background_name)
	request_update_controls = true
	#current_background = a_Background_data["background"].to_snake_case()

func _on_background_edit_menu_background_stat_updated(stat, _value, was_added):
	global_util.fancy_print("custom background change: %s %s (added: %s)" % [
		str(stat), str(_value), str(was_added)
	])
	if was_added:
		current_character.custom_background.append(stat)
	else:
		current_character.custom_background.erase(stat)
	request_update_controls = true

# TODO yeet
func _on_developments_container_development_added(_development_data: Dictionary) -> void:
	pass
	#current_character.add_development(development_data.name.to_snake_case())
	#request_update_controls = true
#
func _on_developments_container_development_removed(_development_data: Dictionary) -> void:
	pass
	#current_character.remove_development(development_data.name.to_snake_case())
	#request_update_controls = true

func _on_callsign_line_edit_text_changed(new_text: String) -> void:
	current_character.callsign = new_text
	# don't request update_controls() here, it messes with callsign lineedit

func _on_export_popup_export_requested(filename: String) -> void:
	var path = "user://Saves/" + filename + ".fsh"
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	#file.store_string(get_user_data_string())
	file.store_string(JSON.stringify(current_character.marshal(), "  "))
	file.close()
	
	var folder_path
	if OS.has_feature("editor"):
		folder_path = ProjectSettings.globalize_path("user://Saves")
	else:
		folder_path = OS.get_user_data_dir().path_join("Saves")
	OS.shell_show_in_file_manager(folder_path, true)

func _on_background_option_button_item_selected(index: int) -> void:
	var nice_name: String = background_option_button.get_item_text(index)
	var bg_id := nice_name.to_snake_case()
	current_character.load_background(bg_id)
	request_update_controls = true

func _on_edit_background_button_pressed() -> void:
	
	pass # Replace with function body.





## Reactivity - things that reset internals

func _on_internals_reset_confirm_dialog_confirmed():
	current_character.unequip_all_internals()
	request_update_controls = true
	#internals_reset()

func _on_save_options_menu_new_gear_pressed():
	get_tree().reload_current_scene()
	#for grid in grid_array:
	#	grid.lock()
	#for index in default_unlocks:
	#	grid_array[index].unlock()
	#emit_signal("reset_lock_tally")
	
	#internals_reset()
	#gear_data = DataHandler.get_gear_template()

func _on_frame_selector_load_frame(frame_name: String):
	current_character.load_frame(frame_name)
	request_update_controls = true
	
	#set_gear_ability.emit(a_Frame_data)
	#var default_unlocks := PackedInt32Array(a_Frame_data["default_unlocks"])
	#current_frame = a_Frame_name
	#
	#for gear_section in gear_sections.values():
		#gear_section.reset()
	#
	#for index in default_unlocks:
		##grid_array[index].unlock()
		#var info := grid_array_index_to_gear_section_info(index)
		#var grid_slot: GridSlot = info.grid_slot
		#grid_slot.is_locked = false
		#grid_slot.is_default_unlock = true
	#
	#gear_data["unlocks"].clear()
	#reset_lock_tally.emit()
	
	#internals_reset()

func _on_hardpoints_reset_confirm_dialog_confirmed():
	current_character.reset_gear_sections()
	request_update_controls = true
	
	#for grid in grid_array:
		#grid.lock()
	#for index in default_unlocks:
		#grid_array[index].unlock()
	#reset_lock_tally.emit()
	
	#internals_reset()
	#gear_data["unlocks"].clear()

#func internals_reset():
	#for slot in internals:
		#for grid in internals[slot].item_grids:
			#var grid_to_check = slot + grid[0] + grid[1] * grid_array[slot].get_parent().columns
			#grid_array[grid_to_check].state = grid_array[grid_to_check].States.FREE
			#grid_array[grid_to_check].installed_item = null
		#item_removed.emit(internals[slot])
		#internals[slot].queue_free()
	#internals.clear()

#endregion
















#region Rendering

func update_controls():
	# updates controls on data from gear_section / grid_slot
	# also clears all highlights / filters
	for gear_section_id in gear_section_controls.keys():
		var gear_section: GearSection = current_character.gear_sections[gear_section_id]
		var gear_section_control: GearSectionControl = gear_section_controls[gear_section_id]
		gear_section_control.update(gear_section)
	
	update_internal_items()
	
	update_place_mode()
	update_unlock_mode()
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
	#+ str(a_Maximum - a_Current) + "/" + str(a_Maximum)
	var used_unlock_count = current_character.get_unlocked_slots().size()
	var max_unlock_count = current_character.get_max_unlocks()
	unlocks_remaining.text = "Unlocks Remaining: %d/%d" % [
		max_unlock_count - used_unlock_count,
		max_unlock_count,
	]
	
	# EL 1 | bg | frame Label
	nameplate.text = "EL %s | %s | %s" % [
		str(current_character.level),
		current_character.background_stats.background,
		current_character.frame_name,
	]
	
	# callsign
	callsign_line_edit.text = current_character.callsign
	
	# gear ability title & body text
	var ability_text = current_character.frame_stats.gear_ability
	var temp_font_size = 14
	var min_x = 220
	var min_y = 80
	while get_theme_default_font().get_multiline_string_size(ability_text, HORIZONTAL_ALIGNMENT_LEFT, min_x, temp_font_size).y > min_y:
		temp_font_size = temp_font_size - 1
	gear_ability_text.set("theme_override_font_sizes/font_size", temp_font_size)
	gear_ability_text.text = ability_text
	gear_ability_title.text = "Gear Ability:\n%s" % current_character.frame_stats.gear_ability_name
	
	# background
	var background_index := global_util.set_option_button_by_item_text(
			#background_selector,
			background_option_button,
			current_character.background_stats.background
	)
	if background_index == -1:
		push_error("update_controls: bad background: %s" % current_character.background_stats.background)
	#%BackgroundEditButton._on_background_selector_load_background(current_character.background_stats.background)
	if current_character.background_stats.background.to_snake_case() == "custom":
		edit_bg_button.show()
	else:
		edit_bg_button.hide()
	
	
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

func update_internal_items():
	# gsid -> gear_section_id
	var internals: Array = current_character.get_equipped_items()
	for i in range(internals.size()):
		#  
		#   slot (gear_section_id, gear_section_name, x, y)
		#   internal_name
		#   internal: actual Item value
		var internal_info: Dictionary = internals[i]
		var gsid: int = internal_info.slot.gear_section_id
		var primary_cell := Vector2i(internal_info.slot.x, internal_info.slot.y)
		var item = internal_info.internal
		var item_cells := current_character.get_item_cells(item, gsid, primary_cell)
		var top_left_cell = item_cells.reduce(func(best: Vector2i, current: Vector2i):
			best.x = min(best.x, current.x)
			best.y = min(best.y, current.y)
			return best
			, Vector2i(1000, 1000))
		var gear_section_control: GearSectionControl = gear_section_controls[gsid]
		var anchor_grid_slot_control: GridSlotControl = gear_section_control.control_grid.get_contents_v(top_left_cell)
		item.snap_to(anchor_grid_slot_control.global_position)
		item.grid_anchor = anchor_grid_slot_control


func update_place_mode():
	if mode != Modes.PLACE:
		return
	if item_held == null:
		return
	
	# correct section
	var valid_section_ids := GearwrightCharacter.item_section_to_valid_section_ids(item_held.item_data.section)
	for gear_section_id in gear_section_controls.keys():
		var gear_section_control: GearSectionControl = gear_section_controls[gear_section_id]
		if gear_section_id in valid_section_ids:
			gear_section_control.clear_grey_out()
		else:
			gear_section_control.grey_out()
	
	# no hovered slot
	if current_slot_info.is_empty():
		return
	
	var gsid: int = current_slot_info.gear_section_id
	var primary_cell := Vector2i(current_slot_info.x, current_slot_info.y)
	var item_cells := current_character.get_item_cells(item_held, gsid, primary_cell)
	var grid_slot_controls := item_cells.map(func(cell):
		if current_gear_section_control.control_grid.is_within_size_v(cell):
			return current_gear_section_control.control_grid.get_contents_v(cell)
		else:
			return null
		)
	grid_slot_controls = grid_slot_controls.filter(func(gsc): return gsc != null)
	if current_character.is_valid_internal_equip(item_held, gsid, primary_cell):
		for grid_slot_control in grid_slot_controls:
			if grid_slot_control != null:
				grid_slot_control.color_good()
	else:
		for grid_slot_control in grid_slot_controls:
			if grid_slot_control != null:
				grid_slot_control.color_bad()

func update_unlock_mode():
	if mode != Modes.UNLOCK:
		return
	
	# default frame unlocks
	for id in gear_section_controls.keys():
		var gear_section_control: GearSectionControl = gear_section_controls[id]
		var gear_section: GearSection = current_character.gear_sections[id]
		var cells := gear_section.grid.get_valid_entries()
		for cell in cells:
			# cell is Vector2i
			var grid_slot: GridSlot = gear_section.grid.get_contents_v(cell)
			var grid_slot_control: GridSlotControl = gear_section_control.control_grid.get_contents_v(cell)
			if grid_slot.is_default_unlock:
				grid_slot_control.color_bad()
	
	update_current_unlock_highlight()

func update_current_unlock_highlight():
	if current_slot_info.is_empty():
		return
	
	if current_grid_slot.is_default_unlock:
		return
	
	if current_grid_slot.is_locked:
		if current_character.has_unlocks_remaining():
			current_grid_slot_control.color_good()
		else:
			current_grid_slot_control.color_bad()
	else:
		# not a default unlock, not locked, should be allowed to re-lock it
		current_grid_slot_control.color_good()

func update_stats_list_control():
	stats_list_control.update(current_character)
	if current_character.is_overweight_with_item(item_held):
		stats_list_control.over_weight()
	else:
		stats_list_control.under_weight()

#endregion







#region Data Interrogation
## all the reasons we can't put the held item in the current slot:
##   there is no held item
##   there is no current slot
##   it would put us over weight
##   wrong section (e.g. trying to put head gear in leg)
##   for each slot that would become occupied:
##     there's already something there
##     slot is out of bounds
##     slot is locked
#func can_place_current_item() -> bool:
	## there is no held item
	#if item_held == null:
		#return false
	#
	## there is no current slot
	#if current_slot_info.is_empty():
		#return false
	#
	## it would put us over weight
	#if is_overweight_with_held_item():
		#return false
	#
	## wrong section (e.g. trying to put head gear in leg)
	#var gear_section_id = current_slot_info.gear_section_id
	#var valid_section_ids := GearwrightCharacter.item_section_to_valid_section_ids(item_held.item_data.section)
	#if not gear_section_id in valid_section_ids:
		#return false
	#
	## for each slot that would become occupied:
	#var cells := get_item_held_cells()
	#for i in range(cells.size()):
		#var cell: Vector2i = cells[i]
		#
		## slot is out of bounds
		#if not current_gear_section.grid.is_within_size_v(cell):
			#return false
		#
		#var grid_slot: GridSlot = current_gear_section.grid.get_contents_v(cell)
		## slot is locked
		#if grid_slot.is_locked:
			#return false
		#
		## there's already something there
		#if grid_slot.installed_item != null:
			#return false
	#
	#return true

#func is_overweight_with_held_item():
	#var weight := current_character.get_weight()
	#if item_held:
		#weight += item_held.item_data.weight
	#if weight > current_character.get_weight_cap():
		#return true
	#else:
		#return false

## item_held.item_grids -> actual coords based on current_slot_info
## item.item_grids is an array
## each element is a 2-element array representing coordinates
##
## this function returns a list of Vector2i elements
## some of these might be out of bounds!
#func get_item_held_cells() -> Array:
	#if item_held == null:
		#return []
	#if current_slot_info.is_empty():
		#return []
	#
	#var item_cell_offsets: Array = item_held.item_grids.map(func(coord): return Vector2i(coord[0], coord[1]))
	#var current_slot_coord := Vector2i(current_slot_info.x, current_slot_info.y)
	#var item_cells := item_cell_offsets.map(func(offset): return current_slot_coord + offset)
	#return item_cells

#endregion













