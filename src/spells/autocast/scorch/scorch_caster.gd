extends BaseCaster

var casting = false
var cooldown_elapsed: float = 0
var target

var scene = preload("res://src/spells/autocast/scorch/scorch.tscn")

onready var find_target_timer = $find_target_timer


func _process(delta: float):
	if !can_cast():
		return
	
	var cooldown = get_cooldown()

	if casting:
		update_cooldown(cooldown)
		return

	if cooldown_elapsed >= cooldown:
		if _cast():
			_reset()
	else:
		cooldown_elapsed += delta
		update_cooldown(cooldown - cooldown_elapsed)


func _reset():
	cooldown_elapsed = 0
	reset_cooldown()


func _cast():
	if Global.map.safe_zone:
		return false
	if !is_instance_valid(target):
		target = invoker.get_closest_target()
		if !is_instance_valid(target):
			return false
	var node = scene.instance()
	node.caster = self
	if Settings.get_aim_mode() != 'crosshair':
		node.use_lerp = true
	node.get_aim_direction = funcref(self, '_get_aim_direction')
	node.connect("timeout", self, "_on_timeout")
	invoker.add_child(node)
	find_target_timer.start()
	casting = true
	return true


func _on_timeout():
	casting = false
	find_target_timer.stop()


func _get_aim_direction():
	if Settings.get_aim_mode() == 'auto':
		if !is_instance_valid(target):
			return null
		return invoker.global_position.direction_to(target.global_position)
	return invoker.input_controller.aim_direction


func _on_find_target_timer_timeout():
	if !is_instance_valid(target):
		target = invoker.get_closest_target()
