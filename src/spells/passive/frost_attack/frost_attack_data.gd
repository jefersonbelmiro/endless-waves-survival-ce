extends PassiveCardData
class_name FrostAttackData


func _init(data_apply: Dictionary).(data_apply):
	pass


# no property to apply modifier
func apply_modifiers():
	pass


func apply_damage(hit_data): 
	if !'modifiers' in hit_data:
		hit_data.modifiers = {}

	var data_apply = {
		proc_chance = data.proc_chance,
		modifier_duration = data.modifier_duration,
	}
	if 'debuff_frozen' in hit_data.modifiers:
		data_apply.proc_chance = max(data_apply.proc_chance, hit_data.modifiers.debuff_frozen.proc_chance)
		data_apply.modifier_duration = max(data_apply.modifier_duration, hit_data.modifiers.debuff_frozen.modifier_duration)

	var modifier = FrozenDebuffModifier.new(data_apply)
	hit_data.modifiers[modifier.id] = modifier
	
