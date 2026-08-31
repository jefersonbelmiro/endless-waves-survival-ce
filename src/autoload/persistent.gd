extends Node

signal loaded()
signal changed()

const FILE_NAME = "persistent_v2.data"
const CRYPTO_KEY = "4E635266556A586E"

var file_path = "user://%s" % [FILE_NAME]

var data = {
	version = Version.CURRENT,
	selected_char_id = "mage",
	selected_map_id = "green_field",
	selected_deck = { 
		mage = "mage_0", 
		knight = "knight_0", 
		rogue = "rogue_0", 
		archer = "archer_0",
		druid = "druid_0",
		caveman = "caveman_0",
	},
	last_deck_id = 100,
	meta = {
		coins = 0,
		maps = {},
		backpack = { size = 8, data = [], },
		traits = [],
		decks = {}
	},
	score_data = {
		user_id = null,
		user_password = null,
		user_email = null,
		user_name = null,
		token = null,
		token_expires = null,
		leaderboard = [],
		last_score_sended = 0,
		maps = {},
	}
}

var loaded = false

func _ready():
	connect("loaded", self, "_on_loaded")


func map_is_unlocked(map_id: String):
	return data.meta.maps.has(map_id)


func get_map(map_id: String):
	return get_data('meta.maps.' + map_id, { level = 1, unlock_level = 1, hight_score = 0, mode = Global.MAP_MODES.ENDLESS })


func map_has_next_level(map_id: String):
	var map_data = Database.get_map(map_id) 
	var map_levels = map_data.levels if 'levels' in map_data else 1
	if map_levels <= 1:
		return false
	if !data.meta.maps.has(map_id):
		return true
	elif data.meta.maps[map_id].unlock_level + 1 <= map_levels:
		return true
	return false


func map_unlock_next_level(map_id: String):
	var map_data = Database.get_map(map_id) 
	var map_levels = map_data.levels if 'levels' in map_data else 1
	if map_levels <= 1:
		return false
	var map_meta = get_map(map_id)

	# selected level is more than one away from last unlock level
	if map_meta.level < map_meta.unlock_level:
		return false

	if map_meta.unlock_level + 1 <= map_levels:
		map_meta.unlock_level += 1
		data.meta.maps[map_id] = map_meta
		return true
	return false


func map_select_level(map_id: String, level: int):
	var map_meta = get_map(map_id)
	map_meta.level = level
	set_data("meta.maps." + map_id, map_meta)


func map_select_mode(map_id: String, mode: int):
	var map_meta = get_map(map_id) 
	map_meta.mode = mode
	set_data("meta.maps." + map_id, map_meta)


func deck_get_selected_id_from_char(char_id: String):
	return get_data('selected_deck.%s' % [char_id])


func deck_get_selected_from_char(char_id: String):
	var selected_deck_id = deck_get_selected_id_from_char(char_id)
	if selected_deck_id == null:
		return null
	return get_deck(selected_deck_id)


func get_last_deck_id():
	return data.last_deck_id


func set_last_deck_id(id):
	data.last_deck_id = int(id)


func get_decks():
	return get_data('meta.decks', {})


func get_decks_from_char(char_id: String):
	var decks = get_decks()
	var result = {}
	for id in decks.keys():
		if !'char_id' in decks[id] || decks[id].char_id == char_id:
			result[id] = decks[id]
	return result


func get_deck(id: String):
	var decks = get_decks()
	if decks.has(id):
		return decks[id]
	return null


func get_coins():
	return get_data('meta.coins', 0)


func get_backpack():
	return get_data('meta.backpack')


func get_backpack_total_items():
	var size = 0
	var backpack_data = get_data('meta.backpack.data', [])
	for index in backpack_data.size():
		size += backpack_data[index].size
	return size


func get_traits():
	return get_data('meta.traits')


func get_traits_total_items():
	var size = 0
	var traits_data = get_data('meta.traits', [])
	for index in traits_data.size():
		size += traits_data[index].size
	return size


func get_score_data():
	return get_data('score_data')


func save_data():
	Global.debounce_func(self, '_save_data')


func _save_data():
	var plataform_sdk = Global.get_plataform_sdk()
	var json_string = to_json(data)
	var error = OK
	if plataform_sdk && plataform_sdk.has_method("persist_data"):
		var raw_data = Encryptor.encrypt(CRYPTO_KEY, json_string)
		error = plataform_sdk.persist_data(FILE_NAME, raw_data)
		# failted to persit, use default persist
		if error == FAILED:
			error = Encryptor.encrypt_file(file_path, CRYPTO_KEY, json_string)
	else:
		error = Encryptor.encrypt_file(file_path, CRYPTO_KEY, json_string)
	if error != OK:
		return false
	emit_signal("changed")
	return true


func _migrate_file():
	var plataform_sdk = Global.get_plataform_sdk()
	if plataform_sdk && plataform_sdk.has_method('migrate_persited_file'):
		plataform_sdk.migrate_persited_file()


func _load_data() -> bool:
	if loaded:
		return true
	_migrate_file()

	var raw_data
	var plataform_sdk = Global.get_plataform_sdk()
	if plataform_sdk && plataform_sdk.has_method("load_data"):
		var encrypted_data = plataform_sdk.load_data(FILE_NAME)
		if encrypted_data:
			raw_data = Encryptor.decrypt(CRYPTO_KEY, encrypted_data)
		# error, use default load data
		elif encrypted_data == FAILED:
			raw_data = Encryptor.decrypt_file(file_path, CRYPTO_KEY)
	else:
		raw_data = Encryptor.decrypt_file(file_path, CRYPTO_KEY)

	if !raw_data:
		loaded = true
		emit_signal("loaded")
		return false

	var json_parse = JSON.parse(raw_data)
	if json_parse.error != OK || !json_parse.result:
		loaded = true
		emit_signal("loaded")
		return false

	var parsed_data = json_parse.result
	if !parsed_data:
		loaded = true
		emit_signal("loaded")
		return false

	data = Version.migrate(parsed_data)
	loaded = true
	emit_signal("loaded")
	return true


func get_data(path, default_value = null):
	return FP.safe_get(data, path, default_value)


func set_data(path, value):
	return FP.safe_set(data, path, value)


func load_data():
	if loaded:
		return
	data.meta.decks = InitialDecks.create() 
	_load_data()


func _on_loaded():
	_sanitize_decks()


func _sanitize_decks():
	var decks = data.meta.decks
	for deck_id in decks.keys():
		var deck = decks[deck_id] 
		for card_id in deck.cards.keys():
			var deck_data = deck.cards[card_id]
			# card without upgrades_data
			if !deck_data:
				continue
			var card_data = Database.get_spell(card_id)
			
			if !card_data || !'upgrades_data' in card_data:
				push_error("invalid card data: wihout upgrade_data property %s" % [card_id])
				continue

			# check removed upgrades
			for upgrade_id in deck_data.keys():
				if !card_data.upgrades_data.has(upgrade_id):
					deck_data.erase(upgrade_id)

			# check new upgrades
			for upgrade_id in card_data.upgrades_data.keys():
				if !deck_data.has(upgrade_id):
					var upgrade = card_data.upgrades_data[upgrade_id].duplicate(true)
					deck_data[upgrade_id] = CardHelper.create_deck_upgrade_data(upgrade)
			


