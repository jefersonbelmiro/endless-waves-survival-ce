extends TraitData
class_name BattleScholarTraitData

func _init(data_apply: Dictionary = {}).(data_apply):
	data = FP.patch_dictionary({
		uid = 'trait_battle_scholar',
		label = 'BATTLE_SCHOLAR_LABEL',
		icon = preload("res://src/traits/battle_scholar/texture/battle_scholar_icon.png"),
		description = 'BATTLE_SCHOLAR_DESC',
		description_rows = ['BATTLE_SCHOLAR_ROW_1', 'BATTLE_SCHOLAR_ROW_2'],
		cost = 100,
		stack_max = 10,
		player_stats = {
			experience_factor = 0.2,
			move_speed = '-5%',
		},
	}, data_apply)

