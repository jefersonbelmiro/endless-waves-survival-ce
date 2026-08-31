extends TraitData
class_name BloodBargainTraitData

func _init(data_apply: Dictionary = {}).(data_apply):
	data = FP.patch_dictionary({
		uid = 'trait_blood_bargain',
		label = 'BLOOD_BARGAIN_LABEL',
		icon = preload("res://src/traits/blood_bargain/texture/blood_bargain_icon.png"),
		description = 'BLOOD_BARGAIN_DESC',
		description_rows = ['BLOOD_BARGAIN_ROW_1', 'BLOOD_BARGAIN_ROW_2'],
		cost = 100,
		stack_max = 10,
		player_stats = {
			lifesteal_proc_chance = 0.05,
		},
		enemy_stats = {
			base_damage = '15%',
		},
	}, data_apply)

