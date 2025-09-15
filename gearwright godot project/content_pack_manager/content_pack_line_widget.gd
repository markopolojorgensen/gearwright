extends Container

signal toggled(toggled_on: bool)
signal yeet

func fancy_update(content_pack: ContentPack):
	%NameLabel.text = content_pack.dir_name
	#%NameLabel.text += "     (%s)" % ProjectSettings.globalize_path(info.path)
	%CheckButton.set_pressed_no_signal(content_pack.is_enabled)
	%VersionLabel.text = content_pack.pack_version

func _on_check_button_toggled(toggled_on: bool) -> void:
	toggled.emit(toggled_on)

func _on_yeet_button_pressed() -> void:
	yeet.emit()
