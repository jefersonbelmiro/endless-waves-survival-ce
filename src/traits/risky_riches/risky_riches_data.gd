extends TraitData
class_name RiskyRichesTraitData

func _init(data_apply: Dictionary = {}).(data_apply):
	data = FP.patch_dictionary({
		uid = 'trait_risky_riches',
		label = 'RISKY_RICHES_LABEL',
		icon = preload("res://src/traits/risky_riches/texture/risky_riches_icon.png"),
		description = 'RISKY_RICHES_DESC',
		description_rows = ['RISKY_RICHES_ROW_1', 'RISKY_RICHES_ROW_2'],
		cost = 100,
		stack_max = 10,
		player_stats = {
			collect_coin_factor = 0.3,
		},
		enemy_stats = {
			critical_proc_chance = 0.05,
		},
	}, data_apply)

