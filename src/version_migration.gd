class_name VersionMigration


static func migrate_v0_4_0(persisted_data):
	persisted_data.meta.maps = {}
	return persisted_data


static func migrate_v0_5_0(persisted_data):
	persisted_data.selected_map_id = persisted_data.selected_map_id.replace("map_", "")
	return persisted_data


static func migrate_v0_6_0(persisted_data):
	# decks
	var chars_ids = ["mage", "knight", "rogue", "archer"]
	var decks = FP.safe_get(persisted_data, 'meta.decks', []) 
	var deck_id_by_char_id = {}
	for deck_index in decks.size():
		var deck = decks[deck_index]
		var cards = []
		for card_index in deck.cards.size():
			var card = deck.cards[card_index]
			cards.append(card.replace("spell_", ""))
		deck.cards = cards
		var label = deck.label.to_lower()
		if !'char_id' in deck && chars_ids.has(label):
			deck.char_id = label
		if 'char_id' in deck:
			deck_id_by_char_id[deck.char_id] = deck_index
		else:
			deck_id_by_char_id["shared"] = deck_index

	# char id
	if 'selected_char_id' in persisted_data:
		persisted_data.selected_char_id = persisted_data.selected_char_id.replace("char_", "")

	# create selected deck dict
	persisted_data.selected_deck = { mage = 0, knight = 0, rogue = 0 }

	# set current deck to current char
	if 'selected_deck_id' in persisted_data:
		persisted_data.selected_deck[persisted_data.selected_char_id] = persisted_data.selected_deck_id
		persisted_data.erase('selected_deck_id')

	for char_id in persisted_data.selected_deck.keys():
		if deck_id_by_char_id.has(char_id):
			persisted_data.selected_deck[char_id] = deck_id_by_char_id[char_id]
		elif deck_id_by_char_id.has("shared"):
			persisted_data.selected_deck[char_id] = deck_id_by_char_id.shared
		else:
			var shared_deck = {
				label = "deck #%s" % [decks.size()],
				cards = [
					"absolute_chaos",
					"dash",
					"critical_strike",
					"fateful_strike",
					"boots_of_speed",
					"ring_of_regeneration",
					"ring_of_attack_speed",
				]
			}
			decks.append(shared_deck)
			deck_id_by_char_id.shared = decks.size() - 1 
			persisted_data.selected_deck[char_id] = deck_id_by_char_id.shared

	# add archer deck
	var archer_0 = {
		char_id = "archer",
		label = "ARCHER",
		cards = [
			"arrow",
			"absolute_chaos",
			"dash",
			"critical_strike",
			"fateful_strike",
			"boots_of_speed",
			"experience",
			"ring_of_regeneration",
			"ring_of_attack_speed",
			"bracer_of_damage",
			"duplicator",
		]
	}
	decks.append(archer_0)
	persisted_data.selected_deck.archer = decks.size() - 1
	
	persisted_data.meta.decks = decks
	return persisted_data


static func migrate_v0_7_0(persisted_data):
	# set cards and decks from array to dictionary
	var decks = FP.safe_get(persisted_data, 'meta.decks', []) 
	var card_ignore = ["light_ball_bounce", "accurate_ice_ball", "giant_fireball"]
	var deck_dict = {}
	for deck_index in decks.size():
		var deck = decks[deck_index]
		var cards = {}
		for card_index in deck.cards.size():
			var card_id = deck.cards[card_index]
			if card_ignore.has(card_id):
				continue
			var card_data = Entities.create_spell_data(card_id)
			cards[card_id] = CardHelper.create_deck_upgrades_data(card_data)
		deck.cards = cards
		deck_dict[str(deck_index)] = deck
	persisted_data.last_deck_id = decks.size() - 1
	persisted_data.meta.decks = deck_dict

	# set deck ids to string
	for char_id in persisted_data.selected_deck.keys():
		persisted_data.selected_deck[char_id] = str(persisted_data.selected_deck[char_id])

	return persisted_data


static func migrate_v0_7_1(persisted_data):
	var decks = FP.safe_get(persisted_data, 'meta.decks', {}) 

	# set deck id
	for deck_id in decks.keys():
		var deck = decks[deck_id]
		deck.id = deck_id

	return persisted_data


static func migrate_v0_9_0(persisted_data):
	var decks = FP.safe_get(persisted_data, 'meta.decks', {}) 
	var initial_decks = InitialDecks.create()

	# remove empty objects to card without upgrades_data
	for deck_id in decks.keys():
		var deck = decks[deck_id]
		for card_id in deck.cards.keys():
			var card = deck.cards[card_id]
			if !card || card.size() == 0:
				deck.cards[card_id] = null

	for deck_id in initial_decks.keys():
		var deck = initial_decks[deck_id]
		decks[deck_id] = deck.duplicate(true)

	persisted_data.meta.decks = decks
	return persisted_data



static func migrate_v0_14_0(persisted_data):
	var decks = FP.safe_get(persisted_data, 'meta.decks', {}) 
	var initial_decks = InitialDecks.create()

	# add druid default decks
	for deck_id in initial_decks.keys():
		var deck = initial_decks[deck_id]
		if deck.char_id != 'druid':
			continue
		decks[deck_id] = deck.duplicate(true)

	persisted_data.selected_deck.druid = 'druid_0'
	persisted_data.meta.decks = decks
	return persisted_data


static func migrate_v0_16_0(persisted_data):
	var decks = FP.safe_get(persisted_data, 'meta.decks', {}) 
	var initial_decks = InitialDecks.create()

	# add caveman default decks
	for deck_id in initial_decks.keys():
		var deck = initial_decks[deck_id]
		if deck.char_id != 'caveman':
			continue
		decks[deck_id] = deck.duplicate(true)

	persisted_data.selected_deck.caveman = 'caveman_0'
	persisted_data.meta.decks = decks
	return persisted_data


static func migrate_v0_19_0(persisted_data):
	var decks = FP.safe_get(persisted_data, 'meta.decks', {}) 
	
	for deck_id in decks.keys():
		var deck = decks[deck_id]
		if 'invulnerability' in deck.cards:
			deck.cards.erase('invulnerability')

	persisted_data.meta.decks = decks
	return persisted_data


static func migrate_v0_21_0(persisted_data):
	persisted_data.meta.traits = []
	return persisted_data


static func migrate_v0_22_0(persisted_data):
	persisted_data.score_data = Persistent.data.score_data

	# rename spin_attack to abyssal_sword
	var decks = FP.safe_get(persisted_data, 'meta.decks', {}) 
	for deck_id in decks.keys():
		var deck = decks[deck_id]
		if 'spin_attack' in deck.cards:
			var card_data = Entities.create_spell_data('abyssal_sword')
			var upgrade_data = CardHelper.create_deck_upgrades_data(card_data)
			deck.cards['abyssal_sword'] = upgrade_data
			deck.cards.erase('spin_attack')
	persisted_data.meta.decks = decks

	return persisted_data


static func migrate_v0_24_0(persisted_data):
	var score_data = persisted_data.score_data
	score_data.last_score_sended = 0
	score_data.maps = {}

	# for map_id in score_data.maps:
	# 	var score = score_data.maps[map_id]
	# 	score_data.maps[map_id] = {
	# 		score = score,
	# 	}

	return persisted_data


