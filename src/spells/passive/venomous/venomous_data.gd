extends PassiveCardData
class_name VenomousData


func _init(data_apply: Dictionary).(data_apply):
	pass


# no property to apply modifier
func apply_modifiers():
	pass


func apply_damage(hit_data): 
	if !'modifiers' in hit_data:
		hit_data.modifiers = {}
	var modifier = PoisionDebuffModifier.new({ proc_chance = data.proc_chance, })
	hit_data.modifiers[modifier.id] = modifier
	
