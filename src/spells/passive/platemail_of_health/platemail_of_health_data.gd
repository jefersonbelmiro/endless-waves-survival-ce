extends PassiveCardData
class_name PlatemailOfHealthData

var emit_health_changed = false

func _init(data_apply: Dictionary).(data_apply):
	pass


func upgrade(next_level = null):
	.upgrade(next_level)
	emit_health_changed = true


func added(): 
	.added()
	Global.emit_signal("player_health_changed")


func apply_modifiers():
	.apply_modifiers()
	if emit_health_changed:
		Global.emit_signal("player_health_changed")
		emit_health_changed = false


func removed(): 
	.removed()
	Global.emit_signal("player_health_changed")

