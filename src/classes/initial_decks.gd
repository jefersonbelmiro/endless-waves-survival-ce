class_name InitialDecks

const decks = [
	{
		id = "mage_0",
		char_id = "mage",
		label = "MAGE",
		cards = {
			light_ball = { damage = 4, max_projectiles = 4, bounces = 2, cooldown = 4 },
			arc_lightning = { damage = 4, cooldown = 4, bounces = 4 },
			absolute_chaos = { cooldown = 4, duration = 4, attack_speed = 4, move_speed = 4 },
			dash = { cooldown = 4, passing_through = 4 },
			shield = { damage_block = 4, cooldown = 4, explosion = 4 },
			duplicator = null,
			double_damage = null,
			fateful_strike = null,
			ring_of_regeneration = null,
			ring_of_attack_speed = null,
			boots_of_speed = null,
		},
	},
	{
		id = "mage_1",
		char_id = "mage",
		label = "UNTOUCHABLE",
		cards = {
			spiral_ball = { base_damage_factor = 4, cooldown = 4, damage_knockback = 4, max_projectiles = 4, duration = 4, area = 4, explosion = 4 },
			fire_ball = { base_damage_factor = 4, cooldown = 4, max_projectiles = 4, scale_factor = 4 },
			absolute_chaos = { cooldown = 4, duration = 4, attack_speed = 4, move_speed = 4 },
			dash = { cooldown = 4, passing_through = 4 },
			shield = { damage_block = 4, cooldown = 4, explosion = 4 },
			ring_of_attack_speed = null,
			double_damage = null,
			knockback = null,
			fateful_strike = null,
			ring_of_area = null,
			ring_of_regeneration = null,
			boots_of_speed = null,
		},
	},
	{
		id = "mage_2",
		char_id = "mage",
		label = "SPELL_ICE_BLAST_LABEL",
		cards = {
			ice_ball = { cooldown = 4, area = 4, max_projectiles = 4, accurate = 0 },
			light_ball = { damage = 4, max_projectiles = 4, bounces = 2, cooldown = 4 },
			absolute_chaos = { cooldown = 4, duration = 4, attack_speed = 4, move_speed = 4 },
			dash = { cooldown = 4, passing_through = 4 },
			shield = { damage_block = 4, cooldown = 4, explosion = 4 },
			frost_attack = null,
			ice_blast = null,
			duplicator = null,
			ring_of_area = null,
			ring_of_regeneration = null,
			ring_of_attack_speed = null,
			boots_of_speed = null,
		},
	},
	{
		id = "knight_0",
		char_id = "knight",
		label = "KNIGHT",
		cards = {
			abyssal_sword = { base_damage_factor = 4, damage_knockback = 4, area = 4 },
			absolute_chaos = { cooldown = 4, duration = 4, attack_speed = 4, move_speed = 4 },
			bulldoze = { cooldown = 4, duration = 4, defense = 4, base_damage_factor = 4, move_speed = 4 },
			earthshock = { damage = 4, cooldown = 4, area = 4 },
			ring_of_area = null,
			ring_of_regeneration = null,
			ring_of_attack_speed = null,
			boots_of_speed = null,
			fateful_strike = null,
			critical_strike = null,
			double_damage = null,
		},
	},
	{
		id = "knight_1",
		char_id = "knight",
		label = "UNSTOPPABLE",
		cards = {
			abyssal_sword = { base_damage_factor = 4, damage_knockback = 4, area = 4 },
			bulldoze = { cooldown = 4, duration = 4, defense = 4, base_damage_factor = 4, move_speed = 4 },
			dash = { cooldown = 4, passing_through = 4, explosion = 4 },
			earthshock = { damage = 4, cooldown = 4, area = 4 },
			shield = { damage_block = 4, cooldown = 4, explosion = 4 },
			fateful_strike = null,
			double_damage = null,
			ring_of_regeneration = null,
			ring_of_attack_speed = null,
			boots_of_speed = null,
			helmet_of_armor = null,
			platemail_of_health = null,
			rusted_shield = null,
		},
	},
	{
		id = "rogue_0",
		char_id = "rogue",
		label = "ROGUE",
		cards = {
			dagger = { base_damage_factor = 4, cooldown = 4, max_projectiles = 4, damage_knockback = 4, pass_through = 0 },
			absolute_chaos = { cooldown = 4, duration = 4, attack_speed = 4, move_speed = 4 },
			dash = { cooldown = 4, passing_through = 4, explosion = 4 },
			mace = { damage = 4, cooldown = 4, damage_knockback = 4, duration = 4 },
			duplicator = null,
			double_damage = null,
			observer_ward = null,
			critical_strike = null,
			fateful_strike = null,
			ring_of_attack_speed = null,
		},
	},
	{
		id = "rogue_1",
		char_id = "rogue",
		label = "UNTOUCHABLE",
		cards = {
			dagger = { base_damage_factor = 4, cooldown = 4, max_projectiles = 4, damage_knockback = 4, pass_through = 0 },
			bulldoze = { cooldown = 4, duration = 4, defense = 4, base_damage_factor = 4, move_speed = 4 },
			dash = { cooldown = 4, passing_through = 4, explosion = 4 },
			mace = { damage = 4, cooldown = 4, damage_knockback = 4, duration = 4 },
			ring_of_evasion = null,
			duplicator = null,
			double_damage = null,
			critical_strike = null,
			fateful_strike = null,
			ring_of_attack_speed = null,
		},
	},
	{
		id = "archer_0",
		char_id = "archer",
		label = "ARCHER",
		cards = {
			arrow = { max_projectiles = 4, base_damage_factor = 4, damage_knockback = 4, spread = 4 },
			absolute_chaos = { cooldown = 4, duration = 4, attack_speed = 4, move_speed = 4 },
			dash = { cooldown = 4, passing_through = 4 },
			critical_strike = null,
			fateful_strike = null,
			boots_of_speed = null,
			ring_of_regeneration = null,
			ring_of_attack_speed = null,
			double_damage = null,
		},
	},
	{
		id = "archer_1",
		char_id = "archer",
		label = "SPELL_ICE_BLAST_LABEL",
		cards = {
			arrow = { max_projectiles = 4, base_damage_factor = 4, damage_knockback = 4, spread = 4 },
			absolute_chaos = { cooldown = 4, duration = 4, attack_speed = 4, move_speed = 4 },
			dash = { cooldown = 4, passing_through = 4 },
			frost_attack = null,
			ice_blast = null,
			boots_of_speed = null,
			ring_of_regeneration = null,
			ring_of_attack_speed = null,
		},
	},
	{
		id = "druid_0",
		char_id = "druid",
		label = "DRUID",
		cards = {
			boomerang = { base_damage_factor = 4, cooldown = 4, damage_knockback = 4 },
			absolute_chaos = { cooldown = 4, duration = 4, attack_speed = 4, move_speed = 4 },
			dash = { cooldown = 4, passing_through = 4, explosion = 4 },
			boots_of_speed = null,
			ring_of_attack_speed = null,
			fateful_strike = null,
			knockback = null,
			observer_ward = null,
		},
	},
	{
		id = "caveman_0",
		char_id = "caveman",
		label = "CAVEMAN",
		cards = {
			club = { base_damage_factor = 4, cooldown = 4, damage_knockback = 4, area = 4 },
			bulldoze = { cooldown = 4, duration = 4, defense = 4, base_damage_factor = 4, move_speed = 4 },
			dash = { cooldown = 4, passing_through = 4, explosion = 4 },
			earthshock = { damage = 4, cooldown = 4, area = 4 },
			boots_of_speed = null,
			fateful_strike = null,
			critical_strike = null,
			knockback = null,
			double_damage = null,
			ring_of_regeneration = null,
			ring_of_attack_speed = null,
		},
	},
]

static func create():
	var result = {}
	for deck_index in decks.size():
		var deck = decks[deck_index].duplicate(true)
		var cards = {}
		for card_id in deck.cards.keys():
			var upgrade_data_indexes = deck.cards[card_id]
			var card_data = Entities.create_spell_data(card_id)
			var upgrade_data = CardHelper.create_deck_upgrades_data(card_data)
			if upgrade_data_indexes && upgrade_data:
				for key in upgrade_data.keys():
					if !upgrade_data_indexes.has(key):
						upgrade_data[key].active = false
					else:
						var index = upgrade_data_indexes[key]
						upgrade_data[key].active = true
						upgrade_data[key].max_index = index
						if index > upgrade_data[key].unlock_index:
							upgrade_data[key].unlock_index = index
			cards[card_id] = upgrade_data
		deck.cards = cards
		result[deck.id] = deck
	return result
