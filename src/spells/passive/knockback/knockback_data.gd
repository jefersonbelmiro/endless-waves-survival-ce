extends PassiveCardData
class_name KnockbackData


func _init(data_apply: Dictionary).(data_apply):
	pass


# no property to apply modifier
func apply_modifiers():
	pass


func apply_damage(hit_data): 
	if !'damage_knockback' in hit_data:
		hit_data.damage_knockback = 0
	hit_data.damage_knockback += data.damage_knockback


