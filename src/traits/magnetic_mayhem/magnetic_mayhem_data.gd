extends TraitData
class_name MagneticMayhemTraitData

func _init(data_apply: Dictionary = {}).(data_apply):
	data = FP.patch_dictionary({
		uid = 'trait_magnetic_mayhem',
		label = 'MAGNETIC_MAYHEM_LABEL',
		icon = preload("res://src/traits/magnetic_mayhem/texture/magnetic_mayhem_icon.png"),
		description = 'MAGNETIC_MAYHEM_DESC',
		description_rows = ['MAGNETIC_MAYHEM_ROW_1', 'MAGNETIC_MAYHEM_ROW_2'],
		cost = 100,
		stack_max = 10,
		player_stats = {
			pick_area = '50%',
		},
		spawn_factor = 0.2,
	}, data_apply)

