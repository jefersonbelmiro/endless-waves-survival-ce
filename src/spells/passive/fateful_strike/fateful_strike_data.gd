extends PassiveCardData
class_name FatefulStrikeData


func _init(data_apply: Dictionary).(data_apply):
	pass


# no property to apply modifier
func apply_modifiers():
	pass


func apply_damage(hit_data): 
	var target_stats = hit_data.target_node.stats
	if target_stats.current_health == target_stats.max_health:
		hit_data.critical_proc_chance += data.critical_proc_chance
