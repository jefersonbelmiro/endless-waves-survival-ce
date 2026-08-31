extends Reference
class_name ShallowGraveData

signal activated()

var data
var host
var caster
var invoker

var icon_node
var timer: float = -1

func _init(data_apply):
	data = data_apply


func _process(delta):
	if timer == -1:
		return
	timer -= delta
	if is_instance_valid(icon_node):
		icon_node.set_progress(timer, get_duration())
	if timer <= 0:
		_stop()


func _get(property):
	if !property in data:
		return null
	return data[property]


func _set(property: String, value):
	data[property] = value
	return true


# execute after apply modifiers for the first time
func added():
	host.emit_signal('modifier_added', self)


# execute when modifier are added and already exists
func update(_source_data):
	pass


func _start(): 
	timer = get_duration()
	icon_node = Global.hud_consumable_slots.add(data)
	icon_node.self_modulate = Color("#4ebf82")
	icon_node.set_progress(timer, timer)


func _stop(): 
	timer = -1
	if is_instance_valid(icon_node):
		Global.hud_consumable_slots.release_slot(data)


# no property to apply modifier
func apply_modifiers():
	pass


# exute on modifier removed
func removed():
	host.emit_signal('modifier_removed', self)


func take_damage(result): 
	if caster.allow_cast && !caster.casting && result.damage >= host.current_health:
		host.current_health = 0
		host.emit_signal('health_changed')
		emit_signal("activated")
		_start()

	if caster.casting:
		result.undying = true


func get_duration():
	var duration = data.duration
	if invoker.stats.spell_duration:
		duration += data.duration * invoker.stats.spell_duration
	return duration


func duplicate(_deep = false):
	return get_script().new(data)
