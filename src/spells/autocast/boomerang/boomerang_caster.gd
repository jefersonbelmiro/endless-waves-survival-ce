extends BaseCaster

const scene = preload("res://src/spells/autocast/boomerang/boomerang.tscn")
var aspd_ellapsed: float = 0


func _process(delta: float):
	if !can_cast():
		return

	if aspd_ellapsed >= get_attack_speed_time(): 
		if _cast():
			aspd_ellapsed = 0
	aspd_ellapsed += delta


func _cast():
	var target = caster.get_random_target()
	if !is_instance_valid(target):
		return false
	var direction = (target.global_position - caster.global_position).normalized()
	var node = scene.instance()
	node.caster = self
	node.direction = direction
	node.velocity = direction * get_projectile_speed()
	node.throw_speed = get_projectile_speed()
	node.rotation = direction.angle()
	node.global_position = caster.global_position + direction.normalized() * 5
	Global.add_entity(node)
	SFX.add_throw()
	return true


