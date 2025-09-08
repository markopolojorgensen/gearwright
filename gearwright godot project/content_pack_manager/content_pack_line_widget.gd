extends HBoxContainer

signal toggled(toggled_on: bool)
signal yeet

func _on_check_button_toggled(toggled_on: bool) -> void:
	toggled.emit(toggled_on)

func fancy_update(content_pack: ContentPack):
	%NameLabel.text = content_pack.dir_name
	#%NameLabel.text += "     (%s)" % ProjectSettings.globalize_path(info.path)
	%CheckButton.set_pressed_no_signal(content_pack.is_enabled)

func _on_yeet_button_pressed() -> void:
	yeet.emit()
