extends TraitData
class_name NaturesPactTraitData

func _init(data_apply: Dictionary = {}).(data_apply):
	data = FP.patch_dictionary({
		uid = 'trait_natures_pact',
		label = 'NATURES_PACT_LABEL',
		icon = preload("res://src/traits/natures_pact/texture/natures_pact_icon.png"),
		description = 'NATURES_PACT_DESC',
		description_rows = ['NATURES_PACT_ROW_1', 'NATURES_PACT_ROW_2'],
		cost = 100,
		stack_max = 10,
		player_stats = {
			health_regen = 1.0,
		},
		enemy_stats = {
			max_health = '10%',
		},
	}, data_apply)

