extends ConsumableData
class_name BatWingData


func _init(data_apply: Dictionary).(data_apply):
	pass


func added(): 
	.added()
	_lose_hp()


func update(source_data):
	.update(source_data)
	_lose_hp()


func removed(): 
	.removed()
	host.emit_signal("health_changed")


func _lose_hp():
	var hp_lost = host.current_health * 0.5
	host.current_health = max(host.current_health - hp_lost, 1)
	host.emit_signal("health_changed")
