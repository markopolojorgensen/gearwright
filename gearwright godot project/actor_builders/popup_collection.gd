extends Node2D

signal save_loaded(info: Dictionary)
signal fsh_saved

@export_enum("Gear", "Fish") var save_style := "Gear"

@onready var open_file_dialog: FileDialog = %OpenFileDialog
@onready var fsh_export_dialog: FileDialog = %FshExportFileDialog
@onready var png_export_dialog: FileDialog = %PngExportFileDialog

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
		inform_input_context_system = false # prevents an extra pop whenever this IC is popped
		open_file_dialog.hide()
		fsh_export_dialog.hide()
		png_export_dialog.hide()
		inform_input_context_system = true
	ic.handle_input = func(_event: InputEvent):
		pass
	input_context_system.register_input_context(ic)






#func old_popup_fsh(new_actor: GearwrightActor):
	#actor = new_actor
	#_popup(fsh_export_popup, actor.callsign)

func _on_fsh_export_popup_export(filename: String) -> void:
	var folder_path = DataHandler.save_paths[save_style]["fsh"]
	var path = folder_path + filename
	
	var json := JSON.stringify(actor.marshal(), "  ")
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(json)
	file.close()
	
	fsh_saved.emit()
	conditional_pop()

func _on_fsh_export_popup_popup_hide() -> void:
	conditional_pop()



#func popup_png(suggestion: String, new_image: Image):
	#image_to_save = new_image
	#_popup(png_export_popup, suggestion)

func _on_png_export_popup_export(filename: String) -> void:
	var folder_path = DataHandler.save_paths[save_style]["png"]
	image_to_save.save_png(folder_path + filename)
	conditional_pop()

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




func popup_fsh_export_dialog(new_actor: GearwrightActor):
	actor = new_actor
	var dir = DataHandler.save_paths[save_style]["fsh"]
	fsh_export_dialog.current_dir = dir
	fsh_export_dialog.root_subfolder = dir
	if actor.callsign.is_empty():
		fsh_export_dialog.current_file = ""
	else:
		fsh_export_dialog.current_file = actor.callsign + ".fsh"
	fsh_export_dialog.popup()
	input_context_system.push_input_context(input_context_system.INPUT_CONTEXT.POPUP_ACTIVE)

func _on_fsh_export_file_dialog_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	var json := JSON.stringify(actor.marshal(), "  ")
	file.store_string(json)
	file.close()
	
	fsh_saved.emit()
	conditional_pop()

func _on_fsh_export_file_dialog_canceled() -> void:
	conditional_pop()



func popup_png_file_dialog(suggestion: String, new_image: Image):
	image_to_save = new_image
	var dir = DataHandler.save_paths[save_style]["png"]
	png_export_dialog.current_dir = dir
	png_export_dialog.root_subfolder = dir
	if suggestion.is_empty():
		png_export_dialog.current_file = ""
	else:
		png_export_dialog.current_file = suggestion + ".png"
	png_export_dialog.popup()
	input_context_system.push_input_context(input_context_system.INPUT_CONTEXT.POPUP_ACTIVE)

func _on_png_export_file_dialog_file_selected(path: String) -> void:
	image_to_save.save_png(path)
	conditional_pop()

func _on_png_export_file_dialog_canceled() -> void:
	conditional_pop()








func conditional_pop():
	if inform_input_context_system and (input_context_system.get_current_input_context_id() == input_context_system.INPUT_CONTEXT.POPUP_ACTIVE):
		input_context_system.pop_input_context_stack()




