extends Node

signal loaded()

var drive_path = 'res://'
var data = {}
var loaded = false

func _ready():
	self.load()


func load():
	data = {}
	_load_data('src/chars', "char")
	_load_data('src/spells', "spell")
	_load_data('src/consumables', "consumable")
	_load_data('src/enemies', "enemy")
	_load_data('src/npc', "npc")
	_load_data('src/maps', "map")
	loaded = true
	emit_signal("loaded")


func get(id: String):
	if !has(id):
		return null
	return data[id]


# @DEPRECATED
# @SEE get_card
func get_spell(uid: String):
	return get_card(uid)


func get_card(uid: String):
	return get("spell_" + uid)


func get_spells():
	var result = []
	for uid in data.keys():
		if uid.begins_with('spell_'):
			result.append(data[uid])
	return result


func get_consumable(id: String):
	return get("consumable_" + id.replace("consumable_", ""))


func get_consumables():
	var result = []
	for uid in data.keys():
		if uid.begins_with('consumable_'):
			result.append(data[uid])
	return result


func get_enemy(id: String):
	return get("enemy_" + id)


func get_enemies():
	var result = []
	for uid in data.keys():
		if uid.begins_with('enemy_'):
			result.append(data[uid])
	return result


func get_map(id: String):
	return get("map_" + id)


func get_maps():
	var result = []
	for uid in data.keys():
		if uid.begins_with('map_'):
			result.append(data[uid])
	return result


func get_npc(id: String):
	return get("npc_" + id)


func get_char(id: String):
	return get("char_" + id)


func get_chars():
	var result = []
	for uid in data.keys():
		if uid.begins_with('char_'):
			result.append(data[uid])
	return result


func has(id: String):
	return data.has(id)


func get_duplicate(id: String):
	var item = get(id)
	assert(item, "ERROR: not found database item with id " + id)
	return item.duplicate(true)


func _load_data(path: String, type: String):
	var files = get_files_in_directory(drive_path + path)
	for file_path in files:
		var instance = _load_json(file_path) 
		if 'class' in instance:
			instance.class = load(instance.class)
		if 'icon' in instance:
			instance.icon = load(instance.icon)
		# @FIXME
		if 'scene' in instance:
			instance.scene = load(instance.scene)
		var uid = instance.id
		if 'uid' in instance:
			uid = instance.uid
		else:
			uid = "%s_%s" % [type, uid]
			instance.uid = uid
		data[uid] = instance
	

func _load_json(path):
	var file = File.new()
	file.open(path, File.READ)
	return parse_json(file.get_as_text())


func get_files_in_directory(path: String) -> Array:
	var files = []
	var dir = Directory.new()

	if dir.open(path) == OK:
		dir.list_dir_begin(true, false)
		_add_dir_contents(dir, files)
	else:
		push_error("An error occurred when trying to access the path: " + path)

	return files

func _add_dir_contents(dir: Directory, files: Array):
	var file_name = dir.get_next()

	while (file_name != ""):
		var path = dir.get_current_dir() + "/" + file_name
		if dir.current_is_dir():
			files.append_array(get_files_in_directory(path))
		elif file_name.ends_with(".json"):
			files.append(path)

		file_name = dir.get_next()

	dir.list_dir_end()
