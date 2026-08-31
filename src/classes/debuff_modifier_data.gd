extends ModifierData
class_name DebuffModifierData

var timer: float = -1


func _init(data_apply: Dictionary).(data_apply):
	pass


func _process(delta):
	if timer == -1:
		return
	timer -= delta
	if timer <= 0:
		host.remove_modifier(data.id)


func added(): 
	timer = _get_modifier_duration()
	if timer > 0:
		# emit signal
		.added()


func update(source_data):
	.update(source_data)
	timer = _get_modifier_duration()


func _get_modifier_duration():
	var modifier_duration = float(data.modifier_duration)
	if host.status_resistance:
		modifier_duration -= float(data.modifier_duration) * host.status_resistance
	if modifier_duration < 0:
		modifier_duration = 0
	return modifier_duration
