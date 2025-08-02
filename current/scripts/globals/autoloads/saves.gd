extends Node


var data: Dictionary = {}
var settings: Dictionary = {}
var encryption_key: String = OS.get_unique_id()
var save_loaded: bool = false
const save_extension: String = ".open_vpet"
const checksum_extension: String = ".COLLAR"
var autosave_tick: int = 0
var autosave_interval: int = 36000


func _ready() -> void:
	make_dir("user://saves")
	make_dir("user://backup")
	make_dir("user://fallback")
	make_dir("user://fonts")
	data = load_file_encrypted("open_vpet")
	settings = load_file("settings")
	SignalBus.load_finished.emit()
	save_loaded = true


func _physics_process(_delta: float) -> void:
	auto_save()


func auto_save() -> void:
	autosave_tick = autosave_tick + 1
	if autosave_tick > autosave_interval:
		autosave_tick = 0
		while get_tree() == null:
			await get_tree().process_frame
		
		if get_or_add("settings", "auto_save", true):
			save_game()


func set_value(dictionary: String, key: String, value: Variant) -> void:
	match dictionary:
		"settings":
			settings[key] = value
		_:
			if(not data.has(dictionary)):
				data[dictionary] = {}
			data[dictionary][key] = value


func has(dictionary: String, key: String) -> bool:
	if data.has(dictionary) and data[dictionary].has(key):
		return true
	else:
		return false


func get_or_add(dictionary: String, key: String, default_value: Variant) -> Variant:
	match dictionary:
		"settings":
			return settings.get_or_add(key, default_value)
		_:
			return data.get_or_add(dictionary, {}).get_or_add(key, default_value)


func get_or_return(dictionary: String, key: String, default_value: Variant) -> Variant:
	match dictionary:
		"settings":
			return settings.get(key, default_value)
		_:
			return data.get(dictionary, {}).get(key, default_value)


func save_game() -> void:
	store_player_state()
	Multithreading.add_task(save_file_encrypted.bind(data, "open_vpet"))
	Multithreading.add_task(save_file.bind(settings, "settings"))


func store_player_state() -> void:
	pass


func make_dir(dir: String) -> void:
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_absolute(dir)


func save_file(content: Variant, location: String) -> void:
	var content_json: String = JSON.stringify(content, "\t")
	write_json(content_json, "user://saves/", location)
	write_json(content_json, "user://backup/", location) 
	write_json(content_json, "user://fallback/", location)


func save_file_encrypted(content: Variant, location: String) -> void:
	var content_json: String = JSON.stringify(content, "\t")
	write_json_encrypted(content_json, "user://saves/", location) 
	write_json_encrypted(content_json, "user://backup/", location) 
	write_json_encrypted(content_json, "user://fallback/", location)
	save_file(data, location + ".readable")


func write_json_encrypted(content: Variant, dir: String, location: String) -> void:
	open_write_encrypted(dir + location + save_extension).store_line(content)
	open_write_encrypted(dir + location + checksum_extension).store_line(FileAccess.get_sha256(dir + location + save_extension))


func write_json(content: Variant, dir: String, location: String) -> void:
	open_write(dir + location + save_extension).store_line(content)


func load_file_encrypted(location: String) -> Variant:
	var content: JSON = JSON.new()
	if sanity_check_encrypted("user://saves/", location, content):
		return content.data
	elif sanity_check_encrypted("user://backup/", location, content):
		return content.data
	elif sanity_check_encrypted("user://fallback/", location, content):
		return content.data
	else:
		return {}


func load_file(location: String) -> Variant:
	var content: JSON = JSON.new()
	if sanity_check("user://saves/", location, content):
		return content.data
	elif sanity_check("user://backup/", location, content):
		return content.data
	elif sanity_check("user://fallback/", location, content):
		return content.data
	else:
		return {}


func sanity_check_encrypted(dir: String, location: String, content: JSON) -> bool:
	if (
		FileAccess.file_exists(dir + location + save_extension)
		and FileAccess.file_exists(dir + location + checksum_extension)
		and open_read_encrypted(dir + location + checksum_extension) != null 
		and open_read_encrypted(dir + location + save_extension) != null
	):
		return (
		FileAccess.get_sha256(dir + location + save_extension) == open_read_encrypted(dir + location + checksum_extension).get_line()
		and content.parse(open_read_encrypted(dir + location + save_extension).get_as_text()) == OK
		)
	
	return false


func sanity_check_checksum(dir: String, location: String, content: JSON) -> bool:
	var sanity: bool = false
	if (
		FileAccess.file_exists(dir + location + save_extension)
		and FileAccess.file_exists(dir + location + checksum_extension)
		and open_read(dir + location + checksum_extension) != null 
		and open_read(dir + location + save_extension) != null
	):
		sanity = (
		FileAccess.get_sha256(dir + location + save_extension) == open_read(dir + location + checksum_extension).get_line() 
		and content.parse(open_read(dir + location + save_extension).get_as_text()) == OK
		)
	
	return sanity


func sanity_check(dir: String, location: String, content: JSON) -> bool:
	var sanity: bool = false
	if (
		FileAccess.file_exists(dir + location + save_extension) and open_read(dir + location + save_extension) != null
	):
		sanity = content.parse(open_read(dir + location + save_extension).get_as_text()) == OK
	return sanity


func open_write_encrypted(path: String) -> FileAccess:
	return FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, encryption_key)


func open_write(path: String) -> FileAccess:
	return FileAccess.open(path, FileAccess.WRITE)


func open_read_encrypted(path: String) -> FileAccess:
	return FileAccess.open_encrypted_with_pass(path, FileAccess.READ, encryption_key)


func open_read(path: String) -> FileAccess:
	return FileAccess.open(path, FileAccess.READ)
