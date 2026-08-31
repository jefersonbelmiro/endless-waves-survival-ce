extends ConsumableData
class_name PotionOfHealingData


func _init(data_apply: Dictionary).(data_apply):
	pass


# overwrite to not emit signals
func added(): pass
func update(_source_data): pass
func removed(): pass

func can_use(host_ = host):
	# full hp
	if host_.current_health == host_.max_health:
		return false
	return true


func apply_modifiers():
	host.current_health += self.current_health
	if host.healing_effectiveness > 0:
		host.current_health += self.current_health * host.healing_effectiveness
	host.remove_modifier(data.id)
	host.emit_signal("health_changed")


func format_toast_used():
	var interpolate_data = {
		current_health = data.current_health + (data.current_health * host.healing_effectiveness) 
	}
	return tr(data.toast_used).format(DataFormatter.it_data(interpolate_data)) 

