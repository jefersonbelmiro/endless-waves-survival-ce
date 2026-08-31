extends TraitData
class_name PolitePerilTraitData


func _init(data_apply: Dictionary = {}).(data_apply):
	 data = FP.patch_dictionary({
		uid = 'trait_polite_peril',
		label = 'POLITE_PERIL_LABEL',
		icon = preload("res://src/traits/polite_peril/texture/polite_peril_icon.png"),
		description = 'POLITE_PERIL_DESC',
		description_rows = ['POLITE_PERIL_ROW_1', 'POLITE_PERIL_ROW_2'],
		cost = 100,
		stack_max = 10,
		player_stats = {
			experience_factor = 0.2,
		},
		enemy_stats = {
			base_damage = '10%',
		},
	}, data_apply)
