extends "res://test/framework/test.gd"


func title():
	return "Migrate v0.8.1 to v0.9.0"


func test_decks_id():
	var result = Version.migrate(persisted_data_v0_8_1.duplicate(true), "v0.9.0")
	var expected = expected_v0_8_1.duplicate(true)
	var result_decks_keys = result.meta.decks.keys()
	var expected_decks_keys = ["0", "1", "2", "4", "5", "6", "7", "8", "10", "11", "12", "13", "mage_0", "mage_1", "mage_2", "knight_0", "knight_1", "rogue_0", "rogue_1", "archer_0", "archer_1"]

	assert_contains(result_decks_keys, expected_decks_keys)
	assert_contains(result, expected)


const persisted_data_v0_8_1 = {
	"version": "v0.8.1",
	"selected_char_id": "archer",
	"selected_map_id": "dota",
	"selected_deck": {
		"mage": "0",
		"knight": "1",
		"rogue": "2",
		"archer": "12"
	},
	"last_deck_id": 13,
	"meta": {
		"coins": 60,
		"maps": {
			"dota": {
				"level": 1,
				"unlock_level": 1,
				"hight_score": 0,
				"mode": 0
			}
		},
		"backpack": {
			"size": 8,
			"data": [
				{
					"size": 1,
					"id": "consumable_potion_of_move_speed"
				}
			]
		},
		"decks": {
			"0": {
				"id": "0",
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
						},
						"passing_through": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"explosion": {
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
						},
						"explosion": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
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
				"id": "1",
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
						},
						"passing_through": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"explosion": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
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
				"id": "2",
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
					}
				}
			},
			"4": {
				"id": "4",
				"char_id": "mage",
				"label": "mage #1",
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
					}
				}
			},
			"5": {
				"id": "5",
				"char_id": "mage",
				"label": "mage #2",
				"cards": {
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
						},
						"explosion": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					}
				}
			},
			"6": {
				"id": "6",
				"char_id": "knight",
				"label": "knight #1",
				"cards": {
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
					}
				}
			},
			"7": {
				"id": "7",
				"char_id": "knight",
				"label": "knight #2",
				"cards": {
					"arc_lightning": {
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
						"bounces": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					}
				}
			},
			"8": {
				"id": "8",
				"char_id": "knight",
				"label": "knight #3",
				"cards": {
					"rusted_shield": {

					}
				}
			},
			"10": {
				"id": "10",
				"char_id": "archer",
				"label": "deck #0",
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
					}
				}
			},
			"11": {
				"id": "11",
				"char_id": "archer",
				"label": "archer #1",
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
					}
				}
			},
			"12": {
				"id": "12",
				"char_id": "archer",
				"label": "archer #2",
				"cards": {
					"boots_of_speed": {

					}
				}
			},
			"13": {
				"id": "13",
				"char_id": "archer",
				"label": "archer #3",
				"cards": {
					"ring_of_area": {

					}
				}
			}
		}
	}
}

const expected_v0_8_1 = {
	"version": "v0.9.0",
	"selected_char_id": "archer",
	"selected_map_id": "dota",
	"selected_deck": {
		"mage": "0",
		"knight": "1",
		"rogue": "2",
		"archer": "12"
	},
	"last_deck_id": 13,
	"meta": {
		"coins": 60,
		"maps": {
			"dota": {
				"level": 1,
				"unlock_level": 1,
				"hight_score": 0,
				"mode": 0
			}
		},
		"backpack": {
			"size": 8,
			"data": [
				{
					"size": 1,
					"id": "consumable_potion_of_move_speed"
				}
			]
		},
		"decks": {
			"0": {
				"id": "0",
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
						},
						"passing_through": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"explosion": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"duplicator": null,
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
					"boots_of_speed": null,
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
						},
						"explosion": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"ring_of_regeneration": null,
					"ring_of_attack_speed": null,
					"experience": null,
					"platemail_of_health": null
				}
			},
			"1": {
				"id": "1",
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
						},
						"passing_through": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"explosion": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"ring_of_regeneration": null,
					"ring_of_area": null,
					"magnet": null,
					"boots_of_speed": null,
					"fateful_strike": null,
					"critical_strike": null
				}
			},
			"2": {
				"id": "2",
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
					}
				}
			},
			"4": {
				"id": "4",
				"char_id": "mage",
				"label": "mage #1",
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
					}
				}
			},
			"5": {
				"id": "5",
				"char_id": "mage",
				"label": "mage #2",
				"cards": {
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
						},
						"explosion": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					}
				}
			},
			"6": {
				"id": "6",
				"char_id": "knight",
				"label": "knight #1",
				"cards": {
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
					}
				}
			},
			"7": {
				"id": "7",
				"char_id": "knight",
				"label": "knight #2",
				"cards": {
					"arc_lightning": {
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
						"bounces": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						}
					}
				}
			},
			"8": {
				"id": "8",
				"char_id": "knight",
				"label": "knight #3",
				"cards": {
					"rusted_shield": null
				}
			},
			"10": {
				"id": "10",
				"char_id": "archer",
				"label": "deck #0",
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
					}
				}
			},
			"11": {
				"id": "11",
				"char_id": "archer",
				"label": "archer #1",
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
					}
				}
			},
			"12": {
				"id": "12",
				"char_id": "archer",
				"label": "archer #2",
				"cards": {
					"boots_of_speed": null
				}
			},
			"13": {
				"id": "13",
				"char_id": "archer",
				"label": "archer #3",
				"cards": {
					"ring_of_area": null
				}
			},
			"mage_1": {
				"id": "mage_1",
				"char_id": "mage",
				"label": "UNTOUCHABLE",
				"cards": {
					"spiral_ball": {
						"base_damage_factor": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"max_projectiles": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"projectile_speed": {
							"active": false,
							"unlock_index": 2,
							"max_index": 2
						},
						"duration": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"area": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"explosion": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"fire_ball": {
						"base_damage_factor": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"max_projectiles": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"scale_factor": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"absolute_chaos": {
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"duration": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"attack_speed": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"move_speed": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"dash": {
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
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
						},
						"passing_through": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"explosion": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"shield": {
						"damage_block": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"damage_knockback": {
							"active": false,
							"unlock_index": 2,
							"max_index": 2
						},
						"explosion": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"duplicator": null,
					"double_damage": null,
					"knockback": null,
					"fateful_strike": null,
					"ring_of_area": null,
					"ring_of_regeneration": null,
					"boots_of_speed": null
				}
			},
			"mage_2": {
				"id": "mage_2",
				"char_id": "mage",
				"label": "SPELL_ICE_BLAST_LABEL",
				"cards": {
					"ice_ball": {
						"base_damage_factor": {
							"active": false,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"area": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"max_projectiles": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"accurate": {
							"active": true,
							"unlock_index": 0,
							"max_index": 0
						}
					},
					"light_ball": {
						"damage": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"max_projectiles": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"damage_knockback": {
							"active": false,
							"unlock_index": 2,
							"max_index": 2
						},
						"bounces": {
							"active": true,
							"unlock_index": 2,
							"max_index": 2
						},
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"absolute_chaos": {
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"duration": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"attack_speed": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"move_speed": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"dash": {
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
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
						},
						"passing_through": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"explosion": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"shield": {
						"damage_block": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"damage_knockback": {
							"active": false,
							"unlock_index": 2,
							"max_index": 2
						},
						"explosion": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"frost_attack": null,
					"ice_blast": null,
					"duplicator": null,
					"ring_of_area": null,
					"ring_of_regeneration": null,
					"boots_of_speed": null
				}
			},
			"knight_1": {
				"id": "knight_1",
				"char_id": "knight",
				"label": "UNSTOPPABLE",
				"cards": {
					"spin_attack": {
						"damage": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"damage_knockback": {
							"active": false,
							"unlock_index": 2,
							"max_index": 2
						},
						"area": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"bulldoze": {
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"duration": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"defense": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"base_damage_factor": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"damage_knockback": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"move_speed": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"dash": {
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"duration": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"move_speed": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"passing_through": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"explosion": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"earthshock": {
						"damage": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"area": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"damage_knockback": {
							"active": false,
							"unlock_index": 2,
							"max_index": 2
						}
					},
					"shield": {
						"damage_block": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"damage_knockback": {
							"active": false,
							"unlock_index": 2,
							"max_index": 2
						},
						"explosion": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"fateful_strike": null,
					"double_damage": null,
					"ring_of_regeneration": null,
					"boots_of_speed": null,
					"helmet_of_armor": null,
					"platemail_of_health": null,
					"rusted_shield": null
				}
			},
			"rogue_1": {
				"id": "rogue_1",
				"char_id": "rogue",
				"label": "UNTOUCHABLE",
				"cards": {
					"dagger": {
						"base_damage_factor": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"max_projectiles": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"pass_through": {
							"active": true,
							"unlock_index": 0,
							"max_index": 0
						}
					},
					"bulldoze": {
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"duration": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"defense": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"base_damage_factor": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"damage_knockback": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"move_speed": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"dash": {
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"duration": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"move_speed": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						},
						"passing_through": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"explosion": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"mace": {
						"damage": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"duration": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"ring_of_evasion": null,
					"duplicator": null,
					"double_damage": null,
					"critical_strike": null,
					"fateful_strike": null,
					"ring_of_attack_speed": null
				}
			},
			"archer_0": {
				"id": "archer_0",
				"char_id": "archer",
				"label": "ARCHER",
				"cards": {
					"arrow": {
						"max_projectiles": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"base_damage_factor": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"spread": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"absolute_chaos": {
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"duration": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"attack_speed": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"move_speed": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"dash": {
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
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
						},
						"passing_through": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"explosion": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"critical_strike": null,
					"fateful_strike": null,
					"boots_of_speed": null,
					"ring_of_regeneration": null,
					"ring_of_attack_speed": null,
					"duplicator": null,
					"double_damage": null
				}
			},
			"archer_1": {
				"id": "archer_1",
				"char_id": "archer",
				"label": "SPELL_ICE_BLAST_LABEL",
				"cards": {
					"arrow": {
						"max_projectiles": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"base_damage_factor": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"damage_knockback": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"spread": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"absolute_chaos": {
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"duration": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"attack_speed": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"move_speed": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						}
					},
					"dash": {
						"cooldown": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
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
						},
						"passing_through": {
							"active": true,
							"unlock_index": 4,
							"max_index": 4
						},
						"explosion": {
							"active": false,
							"unlock_index": -1,
							"max_index": -1
						}
					},
					"frost_attack": null,
					"ice_blast": null,
					"boots_of_speed": null,
					"ring_of_regeneration": null,
					"ring_of_attack_speed": null,
					"duplicator": null
				}
			}
		}
	}
}
