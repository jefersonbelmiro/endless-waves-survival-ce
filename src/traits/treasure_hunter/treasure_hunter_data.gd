extends TraitData
class_name TreasureHunterTraitData


func _init(data_apply: Dictionary = {}).(data_apply):
	 data = FP.patch_dictionary({
		uid = 'trait_treasure_hunter',
		label = 'TREASURE_HUNTER_LABEL',
		icon = preload("res://src/traits/treasure_hunter/texture/treasure_hunter_icon.png"),
		description = 'TREASURE_HUNTER_DESC',
		description_rows = ['TREASURE_HUNTER_ROW_1', 'TREASURE_HUNTER_ROW_2'],
		cost = 100,
		stack_max = 10,
		enemy_stats = {
			move_speed = '10%',
		},
		chest_factor = 0.5,
	}, data_apply)
