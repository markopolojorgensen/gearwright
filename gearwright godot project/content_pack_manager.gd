extends Node

const content_packs_path = "user://external_content/"
const metadata_path      = "user://external_content/content_pack_metadata"

# does not load automatically!

# key: directory name
# value: ContentPack
var content_packs := {}

func load_from_file():
	content_packs.clear()
	
	# load content packs from metadata file
	load_metadata_file()
	
	# examine actual content pack directories
	var external_dir_info := global_util.dir_contents(content_packs_path)
	for dir in external_dir_info.dirs:
		if dir in content_packs.keys():
			continue
		
		var content_pack := ContentPack.new()
		content_pack.dir_name = dir
		content_pack.is_enabled = true
		content_packs[dir] = content_pack

func load_metadata_file():
	if not FileAccess.file_exists(metadata_path):
		push_warning("metadata file not found: %s" % ProjectSettings.globalize_path(metadata_path))
		return
	
	var file = FileAccess.open(metadata_path, FileAccess.READ)
	var file_contents: Dictionary = file.get_var()
	file.close()
	for key: String in file_contents.keys():
		var content_pack := ContentPack.unmarshal(file_contents[key])
		if content_pack.is_valid():
			content_packs[key] = content_pack

func save_to_file():
	var info := {}
	for key: String in content_packs.keys():
		info[key] = content_packs[key].marshal()
	var file = FileAccess.open(metadata_path, FileAccess.WRITE)
	file.store_var(info)
	file.close()

func iterate_over_packs(callable: Callable):
	for key: String in content_packs.keys():
		var content_pack: ContentPack = content_packs[key]
		callable.call(key, content_pack)

func obilterate(content_pack: ContentPack):
	var was_erased := content_packs.erase(content_pack.dir_name)
	if not was_erased:
		push_warning("failed to erase %s" % content_pack.dir_name)
		return
	save_to_file()
	var globalized_path := ProjectSettings.globalize_path(content_pack.get_full_path())
	assert(DirAccess.dir_exists_absolute(globalized_path))
	OS.move_to_trash(globalized_path)
	print(content_pack.get_reference_count())
	load_from_file()
	DataHandler.load_all_data()

