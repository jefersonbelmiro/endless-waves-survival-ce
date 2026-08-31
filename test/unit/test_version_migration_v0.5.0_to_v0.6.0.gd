extends "res://test/framework/test.gd"


func title():
	return "Migrate v0.5.0 to v0.6.0"


func test_changes():
	var persisted = persisted_data_v0_5_0_base.duplicate(true)
	var result = Version.migrate(persisted, "v0.6.0")
	assert_contains(result, expected_changes)


const persisted_data_v0_5_0_base = {
	"version": "v0.5.0",
	"selected_char_id": "char_rogue",
	"selected_map_id": "skeletal_arena",
	"last_deck_id": 3,
	"meta": {
		"coins": 1671,
		"maps": { },
		"backpack": {
			"size": 8,
			"data": [
				{ "size": 2, "id": "consumable_potion_of_healing" },
				{ "size": 3, "id": "consumable_potion_of_damage" },
				{ "size": 4, "id": "consumable_potion_of_move_speed" },
				{ "size": 5, "id": "consumable_potion_of_cooldown" },
				{ "size": 0, "id": null },
				{ "size": 0, "id": null },
				{ "size": 0, "id": null },
				{ "size": 0, "id": null }
			]
		},
		"decks": [
			{
				"label": "MAGE",
				"cards": [
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
					"platemail_of_health"
				],
			},
			{
				"label": "KNIGHT",
				"cards": [
					"spin_attack",
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
					"critical_strike"
				],
			},
			{
				"label": "ROGUE",
				"cards": [
					"dagger",
					"absolute_chaos",
					"dash",
					"duplicator",
					"observer_ward",
					"critical_strike",
					"fateful_strike",
					"ring_of_attack_speed",
					"bracer_of_damage",
					"experience"
				],
			},
			{
				"label": "deck #4",
				"cards": [
					"dash"
				]
			}
		],
		"cards": [ ]
	},
	"selected_deck_id": 3
}

const expected_changes = {
	"version": "v0.6.0",
	"selected_char_id": "rogue",
	"selected_map_id": "skeletal_arena",
	"selected_deck": {
		"mage": 0,
		"knight": 1,
		"rogue": 2,
		"archer": 4
	},
	"last_deck_id": 3,
	"meta": {
		"coins": 1671,
		"maps": {

		},
		"backpack": {
			"size": 8,
			"data": [
				{ "size": 2, "id": "consumable_potion_of_healing" },
				{ "size": 3, "id": "consumable_potion_of_damage" },
				{ "size": 4, "id": "consumable_potion_of_move_speed" },
				{ "size": 5, "id": "consumable_potion_of_cooldown" },
				{ "size": 0, "id": null },
				{ "size": 0, "id": null },
				{ "size": 0, "id": null },
				{ "size": 0, "id": null }
			]
		},
		"decks": [
			{
				"label": "MAGE",
				"cards": [
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
					"platemail_of_health"
				],
				"char_id": "mage"
			},
			{
				"label": "KNIGHT",
				"cards": [
					"spin_attack",
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
					"critical_strike"
				],
				"char_id": "knight"
			},
			{
				"label": "ROGUE",
				"cards": [
					"dagger",
					"absolute_chaos",
					"dash",
					"duplicator",
					"observer_ward",
					"critical_strike",
					"fateful_strike",
					"ring_of_attack_speed",
					"bracer_of_damage",
					"experience"
				],
				"char_id": "rogue"
			},
			{
				"label": "deck #4",
				"cards": [
					"dash"
				]
			},
			{
				"char_id": "archer",
				"label": "ARCHER",
				"cards": [
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
					"duplicator"
				]
			}
		],
		"cards": [ ]
	}
}
	



