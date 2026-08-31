extends TraitData
class_name SlowTimeBubbleTraitData

func _init(data_apply: Dictionary = {}).(data_apply):
	data = FP.patch_dictionary({
		uid = 'trait_slow_time_bubble',
		label = 'SLOW_TIME_BUBBLE_LABEL',
		icon = preload("res://src/traits/slow_time_bubble/texture/slow_time_bubble_icon.png"),
		description = 'SLOW_TIME_BUBBLE_DESC',
		description_rows = ['SLOW_TIME_BUBBLE_ROW_1', 'SLOW_TIME_BUBBLE_ROW_2'],
		cost = 100,
		stack_max = 10,
		player_stats = {
			cooldown_reduction = 0.05,
		},
		enemy_stats = {
			status_resistance = '20%',
		},
	}, data_apply)

