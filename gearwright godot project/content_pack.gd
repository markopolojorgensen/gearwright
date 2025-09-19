class_name ContentPack
extends RefCounted

var dir_name: String
var is_enabled := true
var pack_version := "no version found"

func is_perma_enabled() -> bool:
	return "gearwright fish data" in dir_name.to_lower()

func get_full_path() -> String:
	return content_pack_manager.content_packs_path.path_join(dir_name)

func is_valid() -> bool:
	return DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(get_full_path()))

func _to_string() -> String:
	return "<ContentPack: %s | enabled: %s>" % [dir_name, str(is_enabled)]

func marshal() -> Dictionary:
	var info := {}
	info.dir_name = dir_name
	info.is_enabled = is_enabled
	return info

static func unmarshal(info: Dictionary) -> ContentPack:
	var content_pack := ContentPack.new()
	content_pack.dir_name = info.dir_name
	content_pack.is_enabled = info.is_enabled
	content_pack.pack_version = info.get("version", "no version found")
	return content_pack

