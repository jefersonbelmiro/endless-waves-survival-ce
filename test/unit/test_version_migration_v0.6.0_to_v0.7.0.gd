extends "res://test/framework/test.gd"


func title():
	return "Migrate v0.6.0 to v0.7.0"


func test_base_without_changes():
	var base = persisted_data_v0_6_0_base.duplicate(true)
	var result = Version.migrate(persisted_data_v0_6_0_base.duplicate(true), "v0.7.0")
	var expected = FP.patch_dictionary(
		base, 
		{
			version = "v0.7.0",
			last_deck_id = 3,
			selected_deck = {
				mage = "0",
				knight = "1",
				rogue = "2",
				archer = "3",
			},
			meta = {
				backpack = {
					size = 8,
					data = [],
				},
				decks = result.meta.decks
			}
		}
	)
	
	assert_contains(result, expected)


func test_deck_changes():
	var base = persisted_data_v0_6_0_base.duplicate(true)
	var decks = base.meta.decks

	# add new deck
	decks.append({
		char_id = "rogue",
		label = "new rogue deck",
		cards = ["dagger", "boots_of_speed"]
	})
	base.selected_deck.rogue = 4

	# edit existend deck
	decks[0].label = "MAGE edited"
	decks[0].cards = ["light_ball"]

	var result = Version.migrate(base, "v0.7.0")
	var expected = FP.patch_dictionary(
		base, 
		{
			version = "v0.7.0",
			last_deck_id = 4,
			selected_deck = {
				mage = "0",
				knight = "1",
				rogue = "4",
				archer = "3",
			},
			meta = {
				decks = {
					"0": {
						char_id = "mage",
						label = "MAGE edited",
					}
				}
			}
		}
	)
	
	assert_contains(result, expected)
	var expected_card_size = [1, 13, 10, 11, 2, 2, 1]
	for index in result.meta.decks.size():
		assert_eq(result.meta.decks[str(index)].cards.size(), expected_card_size[index])


func test_deck_added():
	var base = persisted_data_v0_6_0_base.duplicate(true)
	var decks = base.meta.decks
	decks.append({
		char_id = "archer",
		label = "new archer deck",
		cards = ["arrow", "boots_of_speed"]
	})
	decks.append({
		char_id = "mage",
		label = "new mage deck",
		cards = ["light_ball", "ring_of_area"]
	})
	decks.append({
		char_id = "knight",
		label = "new knight deck",
		cards = ["mace"]
	})

	var result = Version.migrate(base, "v0.7.0")
	var expected = FP.patch_dictionary(
		base, 
		{
			version = "v0.7.0",
			last_deck_id = 6,
			selected_deck = {
				mage = "0",
				knight = "1",
				rogue = "2",
				archer = "3",
			},
			meta = {
				decks = {
					"4": {
						char_id = "archer",
						label = "new archer deck",
					},
					"5": {
						char_id = "mage",
						label = "new mage deck",
					},
					"6": {
						char_id = "knight",
						label = "new knight deck",
					}
				}
			}
		}
	)
	
	assert_contains(result, expected)
	assert_eq(result.meta.decks.size(), 7)
	var expected_card_size = [11, 13, 10, 11, 2, 2, 1]
	for index in result.meta.decks.size():
		assert_eq(result.meta.decks[str(index)].cards.size(), expected_card_size[index])


const persisted_data_v0_6_0_base = {
	version = 'v0.6.0',
	selected_char_id = "mage",
	selected_map_id = "green_field",
	selected_deck = {
		mage = 0,
		knight = 1,
		rogue = 2,
		archer = 3,
	},
	meta = {
		coins = 0,
		maps = {},
		cards = [],
		backpack = {
			size = 8,
			data = [],
		},
		decks = [
			{
				char_id = "mage",
				label = "MAGE",
				cards = [
					"light_ball",
					"absolute_chaos",
					"dash",
					"duplicator",
					"light_ball_bounce",
					"ice_ball",
					"accurate_ice_ball",
					"boots_of_speed",
					"shield",
					"ring_of_regeneration",
					"ring_of_attack_speed",
					"experience",
					"platemail_of_health",
				]
			},
			{
				char_id = "knight",
				label = "KNIGHT",
				cards = [
					"abyssal_sword",
					"earthshock",
					"mace",
					"absolute_chaos",
					"dash",
					"experience",
					"bracer_of_damage",
					"ring_of_regeneration",
					"ring_of_area",
					"magnet",
					"boots_of_speed",
					"fateful_strike",
					"critical_strike",
				]
			},
			{
				char_id = "rogue",
				label = "ROGUE",
				cards = [
					"dagger",
					"absolute_chaos",
					"dash",
					"duplicator",
					"observer_ward",
					"critical_strike",
					"fateful_strike",
					"ring_of_attack_speed",
					"bracer_of_damage",
					"experience",
				]
			},
			{
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
			},
		]
	},
}


