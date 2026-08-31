extends TraitData
class_name GlassCannonTraitData

func _init(data_apply: Dictionary = {}).(data_apply):
	data = FP.patch_dictionary({
		uid = 'trait_glass_cannon',
		label = 'GLASS_CANNON_LABEL',
		icon = preload("res://src/traits/glass_cannon/texture/glass_cannon_icon.png"),
		description = 'GLASS_CANNON_DESC',
		description_rows = ['GLASS_CANNON_ROW_1', 'GLASS_CANNON_ROW_2'],
		cost = 100,
		stack_max = 10,
		player_stats = {
			base_damage = '10%',
			attack_speed = '10%',
			max_health = '-5%'
		},
	}, data_apply)

