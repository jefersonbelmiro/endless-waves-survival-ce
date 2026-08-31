extends ModifierData
class_name BurnAttackModifier

func _init(data_apply: Dictionary = {}).(data_apply):
	 data = FP.patch_dictionary({
		id = 'burn_attack_modifier',
		proc_chance = 1.0,
		modifier_duration = 5,
		type = "debuff",
		damage = 1.0,
	}, data_apply)


func apply_damage(hit_data) -> void:
	if !'modifiers' in hit_data:
		hit_data.modifiers = {}
	var modifier = BurnDebuffModifier.new()
	hit_data.modifiers[modifier.id] = modifier
