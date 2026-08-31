extends BaseCaster

const scene = preload("res://src/spells/autocast/club/club.tscn")
var aspd_ellapsed: float = 0
var target


func _process(delta: float):
	if !can_cast():
		return

	if aspd_ellapsed >= get_attack_speed_time(): 
		if Settings.get_aim_mode() == 'auto' && !invoker.target_in_attack_range(target):
			target = invoker.get_closest_target()
		if _cast():
			aspd_ellapsed = 0
	aspd_ellapsed += delta


func _cast():
	if Global.map.safe_zone:
		return false
	var node = scene.instance()
	var direction = _get_aim_direction()
	if !direction:
		return false
	node.caster = self
	node.rotation = direction.angle()
	node.direction = direction
	Global.add_entity(node)
	SFX.add_fast_sword()
	return true


func _get_aim_direction():
	if Settings.get_aim_mode() == 'auto':
		if !invoker.target_in_attack_range(target):
			return null
		return invoker.global_position.direction_to(target.global_position)
	return invoker.input_controller.aim_direction

