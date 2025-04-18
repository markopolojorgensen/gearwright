extends Node2D

signal save_loaded(info: Dictionary)
signal fsh_saved

@export_enum("Gear", "Fish") var save_style := "Gear"

@onready var fsh_export_popup: Popup = %FshExportPopup
@onready var png_export_popup: Popup = %PngExportPopup
@onready var open_file_dialog: FileDialog = %OpenFileDialog

var actor: GearwrightActor
var image_to_save: Image
var inform_input_context_system := true

func _ready() -> void:
	register_ic_popup()

func register_ic_popup():
	var ic := InputContext.new()
	ic.id = input_context_system.INPUT_CONTEXT.POPUP_ACTIVE
	ic.activate = func(_is_stack_growing: bool):
		pass
	ic.deactivate = func(_is_stack_growing: bool):
		inform_input_context_system = false
		fsh_export_popup.hide()
		png_export_popup.hide()
		open_file_dialog.hide()
		inform_input_context_system = true
	ic.handle_input = func(_event: InputEvent):
		pass
	input_context_system.register_input_context(ic)

# popup_hide is emitted even when confirmed, so the ic stack pop happens
# only the file dialog (not a popup) needs the manual ic stack pop on confirm

func popup_fsh(new_actor: GearwrightActor):
	actor = new_actor
	_popup(fsh_export_popup, actor.callsign)

func _on_fsh_export_popup_export(filename: String) -> void:
	var folder_path = DataHandler.save_paths[save_style]["fsh"]
	var path = folder_path + filename
	
	var json := JSON.stringify(actor.marshal(), "  ")
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(json)
	file.close()
	
	global.open_folder(folder_path)
	fsh_saved.emit()

func _on_fsh_export_popup_popup_hide() -> void:
	conditional_pop()



func popup_png(suggestion: String, new_image: Image):
	image_to_save = new_image
	_popup(png_export_popup, suggestion)

func _on_png_export_popup_export(filename: String) -> void:
	var folder_path = DataHandler.save_paths[save_style]["png"]
	image_to_save.save_png(folder_path + filename)
	global.open_folder(folder_path)

func _on_png_export_popup_popup_hide() -> void:
	conditional_pop()


func _popup(popup: Popup, suggestion: String):
	popup.set_line_edit_text(suggestion)
	popup.popup()
	input_context_system.push_input_context(input_context_system.INPUT_CONTEXT.POPUP_ACTIVE)




func popup_load_dialog():
	open_file_dialog.current_dir = DataHandler.save_paths[save_style]["fsh"]
	open_file_dialog.popup()
	input_context_system.push_input_context(input_context_system.INPUT_CONTEXT.POPUP_ACTIVE)

func _on_open_file_dialog_file_selected(path: String) -> void:
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
	save_loaded.emit(info)
	input_context_system.pop_input_context_stack()

func _on_open_file_dialog_canceled() -> void:
	conditional_pop()

func conditional_pop():
	if inform_input_context_system and (input_context_system.get_current_input_context_id() == input_context_system.INPUT_CONTEXT.POPUP_ACTIVE):
		input_context_system.pop_input_context_stack()
