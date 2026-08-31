extends "res://test/framework/test.gd"


func title():
	return "Migrate v0.7.0 to v0.7.1"


func test_with_changes():
	var base = persisted_data_v0_7_0.duplicate(true)
	var result = Version.migrate(persisted_data_v0_7_0.duplicate(true), "v0.7.1")
	var expected = FP.patch_dictionary(
		base, 
		{
			version = "v0.7.1",
			selected_char_id = "archer",
			selected_map_id = "flying_assault",
			selected_deck = {
				mage = "12",
				knight = "1",
				rogue = "6",
				archer = "10"
			},
			last_deck_id = 12,
			meta = {
				coins = 25,
				decks = {
					"0": { id = "0", },
					"2": { id = "2", },
					"3": { id = "3", },
					"4": { id = "4", },
					"5": { id = "5", },
					"6": { id = "6", },
					"7": { id = "7", },
					"8": { id = "8", },
					"9": { id = "9", },
					"10": { id = "10", },
					"11": { id = "11", },
					"12": { id = "12", },
				},
			}
		}
	)

	assert_contains(result, expected)


const persisted_data_v0_7_0 = {
	"version": "v0.7.0",
	"selected_char_id": "archer",
	"selected_map_id": "flying_assault",
	"selected_deck": {
		"mage": "12",
		"knight": "1",
		"rogue": "6",
		"archer": "10"
	},
	"last_deck_id": 12,
	"meta": {
		"coins": 25,
		"maps": {
			"flying_assault": {
				"level": 1,
				"unlock_level": 1,
				"hight_score": 0,
				"mode": 0
			},
			"skeletal_arena": {
				"level": 1,
				"unlock_level": 1,
				"hight_score": 0,
				"mode": 1
			}
		},
		"backpack": {
			"size": 8,
			"data": [
				{ "size": 1, "id": "consumable_potion_of_healing" },
				{ "size": 1, "id": "consumable_potion_of_damage" },
				{ "size": 0, "id": null },
				{ "size": 0, "id": null },
				{ "size": 0, "id": null },
				{ "size": 0, "id": null },
				{ "size": 0, "id": null },
				{ "size": 0, "id": null }
			]
		},
		"decks": {
			"0": {
				"char_id": "mage",
				"label": "MAGE",
				"cards": {
					"light_ball": {
						"damage": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"max_projectiles": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"bounces": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"absolute_chaos": {
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"attack_speed": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"move_speed": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					},
					"dash": {
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"move_speed": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"duplicator": {

					},
					"ice_ball": {
						"base_damage_factor": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"area": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"max_projectiles": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"accurate": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"boots_of_speed": {

					},
					"shield": {
						"damage_block": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					},
					"ring_of_regeneration": {

					},
					"ring_of_attack_speed": {

					},
					"experience": {

					},
					"platemail_of_health": {

					}
				}
			},
			"1": {
				"char_id": "knight",
				"label": "KNIGHT",
				"cards": {
					"spin_attack": {
						"damage": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"area": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					},
					"earthshock": {
						"damage": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"area": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					},
					"mace": {
						"damage": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					},
					"absolute_chaos": {
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"attack_speed": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"move_speed": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					},
					"dash": {
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"move_speed": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"experience": {

					},
					"bracer_of_damage": {

					},
					"ring_of_regeneration": {

					},
					"ring_of_area": {

					},
					"magnet": {

					},
					"boots_of_speed": {

					},
					"fateful_strike": {

					},
					"critical_strike": {

					}
				}
			},
			"2": {
				"char_id": "rogue",
				"label": "ROGUE",
				"cards": {
					"dagger": {
						"base_damage_factor": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"max_projectiles": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					},
					"absolute_chaos": {
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"attack_speed": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"move_speed": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					},
					"dash": {
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"move_speed": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"duplicator": {

					},
					"observer_ward": {

					},
					"critical_strike": {

					},
					"fateful_strike": {

					},
					"ring_of_attack_speed": {

					},
					"bracer_of_damage": {

					},
					"experience": {

					}
				}
			},
			"3": {
				"char_id": "archer",
				"label": "ARCHER",
				"cards": {
					"arrow": {
						"max_projectiles": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"base_damage_factor": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"damage_knockback": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"spread": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"absolute_chaos": {
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"attack_speed": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"move_speed": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					},
					"dash": {
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"move_speed": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"critical_strike": {

					},
					"fateful_strike": {

					},
					"boots_of_speed": {

					},
					"experience": {

					},
					"ring_of_regeneration": {

					},
					"ring_of_attack_speed": {

					},
					"bracer_of_damage": {

					},
					"duplicator": {

					}
				}
			},
			"4": {
				"char_id": "mage",
				"label": "deck #5",
				"cards": {
					"time_dilation": {
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"move_speed": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"proximity_mines": {
						"base_damage_factor": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"projectile_speed": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"area": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					},
					"helmet_of_armor": {

					}
				}
			},
			"5": {
				"char_id": "knight",
				"label": "deck #6",
				"cards": {
					"time_dilation": {
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"move_speed": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"dash": {
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"move_speed": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"magnet": {

					}
				}
			},
			"6": {
				"char_id": "rogue",
				"label": "deck #7",
				"cards": {
					"ring_of_attack_speed": {

					},
					"dash": {
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"move_speed": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"dagger": {
						"base_damage_factor": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"max_projectiles": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					}
				}
			},
			"7": {
				"char_id": "archer",
				"label": "deck #8",
				"cards": {
					"ring_of_evasion": {

					},
					"ring_of_area": {

					}
				}
			},
			"8": {
				"char_id": "archer",
				"label": "deck #9",
				"cards": {
					"time_dilation": {
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"move_speed": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"proximity_mines": {
						"base_damage_factor": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"projectile_speed": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"area": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					},
					"fateful_strike": {

					},
					"frost_attack": {

					}
				}
			},
			"9": {
				"char_id": "archer",
				"label": "deck #10",
				"cards": {
					"proximity_mines": {
						"base_damage_factor": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"projectile_speed": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"area": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					},
					"dash": {
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"move_speed": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"ring_of_evasion": {

					},
					"boots_of_speed": {

					}
				}
			},
			"10": {
				"char_id": "archer",
				"label": "deck #11",
				"cards": {
					"ring_of_evasion": {

					},
					"boots_of_speed": {

					},
					"magnet": {

					},
					"time_dilation": {
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"move_speed": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					}
				}
			},
			"11": {
				"char_id": "knight",
				"label": "deck #12",
				"cards": {
					"boots_of_speed": {

					},
					"earthshock": {
						"damage": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"area": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					},
					"mace": {
						"damage": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					}
				}
			},
			"12": {
				"char_id": "mage",
				"label": "deck #13",
				"cards": {
					"boots_of_speed": {

					},
					"absolute_chaos": {
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"attack_speed": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"move_speed": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					},
					"spiral_ball": {
						"base_damage_factor": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"max_projectiles": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"projectile_speed": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"area": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"duplicator": {

					},
					"knockback": {

					},
					"spell_duration": {

					},
					"ring_of_regeneration": {

					},
					"frost_attack": {

					},
					"shield": {
						"damage_block": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					}
				}
			}
		},
		"cards": [

		]
	}
}

