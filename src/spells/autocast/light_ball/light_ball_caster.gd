extends BaseCaster

const scene = preload("res://src/spells/autocast/light_ball/light_ball.tscn")
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
	if !invoker.target_in_attack_range(target):
		return false
	var node = scene.instance()
	var direction = (target.global_position - invoker.global_position)
	node.caster = self
	node.bounces = data.bounces
	node.rotation = direction.angle()
	node.projectile_speed = get_projectile_speed()
	node.velocity = direction.normalized() * get_projectile_speed()
	node.global_position = invoker.global_position + Vector2(0, 5)
	Global.add_entity(node)
	SFX.add_spell_throw()
	return true


