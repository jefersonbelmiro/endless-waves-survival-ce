extends TraitData
class_name ExtendedHarvestTraitData


func _init(data_apply: Dictionary = {}).(data_apply):
	 data = FP.patch_dictionary({
		uid = 'trait_extended_harvest',
		label = 'EXTENDED_HARVEST_LABEL',
		icon = preload("res://src/traits/extended_harvest/texture/extended_harvest_icon.png"),
		description = 'EXTENDED_HARVEST_DESC',
		description_rows = ['EXTENDED_HARVEST_ROW_1', 'EXTENDED_HARVEST_ROW_2'],
		cost = 100,
		stack_max = 10,
		player_stats = {
			pick_area = '50%',
		},
		enemy_stats = {
			move_speed = '5%',
		},
	}, data_apply)
