extends BaseCaster

const scene = preload("res://src/spells/ultimate/sun_strike/sun_strike.tscn")

var cooldown_elapsed: float = 0
var allow_cast = false

func _input(event: InputEvent) -> void:
	if allow_cast && event.is_action_pressed(icon_node.action_name):
		cast()


func _process(delta: float):
	if !can_cast():
		return

	var cooldown = get_cooldown()
	cooldown_elapsed += delta
	if !allow_cast && cooldown_elapsed >= cooldown + data.cast_time:
		allow_cast = true
		SFX.add_ultimate_on()

	update_cooldown(cooldown - cooldown_elapsed)


func cast():
	if !allow_cast || !caster.is_alive() || caster.is_disabled():
		return
	if cooldown_elapsed < get_cooldown() + data.cast_time:
		return
	if caster.is_channeling():
		caster.state = caster.STATES.IDLE
							
	# var targets = Targets.get_random_targets(invoker.global_position, [], get_max_projectiles())  
	var targets = Targets.get_closest_targets(invoker.global_position, get_max_projectiles())  
	for index in targets.size():
		_hit(targets[index])

	allow_cast = false
	cooldown_elapsed = 0
	reset_cooldown()


func _hit(target: Node):
	if !Targets.is_valid(target):
		return false
	var node = scene.instance()
	node.caster = self
	node.target = target
	node.global_position = target.global_position
	Global.add_entity(node)
	return true
