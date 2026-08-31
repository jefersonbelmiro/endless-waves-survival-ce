extends BaseCaster

const scene = preload("res://src/spells/autocast/dagger/dagger.tscn")
var aspd_ellapsed: float = 0
var target


func _process(delta: float):
	if !can_cast():
		return

	if aspd_ellapsed >= get_attack_speed_time(): 
		if !invoker.target_in_attack_range(target):
			target = invoker.get_closest_target()
		if _cast():
			aspd_ellapsed = 0
	aspd_ellapsed += delta


func _cast():
	if !is_instance_valid(target):
		return false
	var direction = (target.global_position - invoker.global_position).normalized()
	var node = scene.instance()
	node.caster = self
	node.velocity = direction * get_projectile_speed()
	node.rotation = direction.angle()
	node.global_position = invoker.global_position + direction.normalized() * 5
	if 'pass_through' in data:
		node.pass_through = true
	Global.add_entity(node)
	SFX.add_throw()
	return true


