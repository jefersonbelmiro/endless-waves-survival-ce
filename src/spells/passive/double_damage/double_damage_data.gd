extends PassiveCardData
class_name DoubleDamageData

var _color = Color('#458cd6')


func _init(data_apply: Dictionary).(data_apply):
	pass


# no property to apply modifier
func apply_modifiers():
	pass


func apply_damage(hit_data): 
	if data.proc_chance >= 1 || rand_range(0, 1) <= data.proc_chance:
		hit_data.damage *= 2
	
