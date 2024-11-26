extends MenuButton
@onready var screenshot_popup = $ScreenshotPopup
@onready var mech_border_container = $"../../ColorRect"
@onready var file_dialog = $FileDialog
@onready var menu = get_popup()
@onready var export_popup = $ExportPopup
@onready var callsign_input = %CallsignLineEdit

signal new_gear_pressed
signal load_save_data(user_data)
var buttons_to_add := ["New Gear", "Save to File", "Load from File", "Open Saves Folder", "Screenshot", "Open Screenshot Folder"]
var image

func _ready():
	for button_name in buttons_to_add:
		menu.add_item(button_name)
	
	menu.id_pressed.connect(_on_item_pressed)
	file_dialog.file_selected.connect(read_save_file)

func _on_item_pressed(id):
	var action = buttons_to_add[id]
	
	match (action.to_lower()):
		"new gear":
			new_gear_pressed.emit()
		"save to file":
			save_current_build()
		"load from file":
			file_dialog.popup()
		"open saves folder":
			open_folder("Saves")
		"screenshot":
			save_screenshot()
		"open screenshot folder":
			open_folder("Screenshots")
		"copy to clipboard":
			pass

func save_current_build():
	export_popup.popup()

func read_save_file(a_path):
	var file = FileAccess.open(a_path, FileAccess.READ)
	var save_data = JSON.parse_string(file.get_as_text())
	file.close()
	
	load_save_data.emit(save_data)

func save_screenshot():
	callsign_input.release_focus()
	file_dialog.visible = false
	await get_tree().create_timer(0.1).timeout
	var border_rect = Rect2i(mech_border_container.get_global_rect())
	image = get_viewport().get_texture().get_image().get_region(border_rect)
	
	screenshot_popup.popup()

func _on_screenshot_popup_screenshot_name_confirm(file_name):
	image.save_png("user://Screenshots/" + file_name + ".png")
	
	open_folder("Screenshots")

func open_folder(folder_name):
	var path
	if OS.has_feature("editor"):
		path = ProjectSettings.globalize_path("user://%s" % folder_name)
	else:
		path = OS.get_user_data_dir().path_join(folder_name)
	OS.shell_show_in_file_manager(path, true)
