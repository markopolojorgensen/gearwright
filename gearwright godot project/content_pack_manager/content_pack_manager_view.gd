extends PanelContainer

@onready var lines_container: Container = %LinesContainer
@onready var file_dialog: FileDialog = %FileDialog
@onready var yeet_confirm_dialog: ConfirmationDialog = %YeetConfirmationDialog

const cp_line_widget_scene := preload("res://content_pack_manager/content_pack_line_widget.tscn")

var content_pack_to_yeet: ContentPack

func _ready():
	fancy_update.call_deferred()
	yeet_confirm_dialog.hide()
	yeet_confirm_dialog.get_child(1, true).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	file_dialog.hide()

func fancy_update():
	global_util.clear_children(lines_container)
	content_pack_manager.iterate_over_packs(func(_key: String, content_pack: ContentPack):
		var widget = cp_line_widget_scene.instantiate()
		lines_container.add_child(widget)
		widget.toggled.connect(func(is_enabled):
			content_pack.is_enabled = is_enabled
			content_pack_manager.save_to_file()
		)
		widget.yeet.connect(func():
			content_pack_to_yeet = content_pack
			yeet_confirm_dialog.dialog_text = "Are you sure you want to delete %s?\nThis cannot be undone." % content_pack.dir_name
			yeet_confirm_dialog.popup_centered()
		)
		widget.fancy_update(content_pack)
	)

func _on_add_content_pack_button_pressed() -> void:
	file_dialog.current_path = "user://"
	file_dialog.popup()

func _on_directory_button_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path(content_pack_manager.content_packs_path))

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		content_pack_manager.save_to_file()
		get_tree().quit()

func _on_back_button_pressed() -> void:
	content_pack_manager.save_to_file()
	DataHandler.load_all_data()
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

func _on_yeet_confirmation_dialog_confirmed() -> void:
	content_pack_manager.obilterate(content_pack_to_yeet)
	fancy_update.call_deferred()

func _on_file_dialog_file_selected(_path: String) -> void:
	fancy_update.call_deferred()
