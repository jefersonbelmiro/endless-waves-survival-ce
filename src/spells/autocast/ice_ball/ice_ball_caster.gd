extends BaseCaster

var cooldown_elapsed: float = 0
var aspd_ellapsed: float = 0
var projectiles = 0
var target

var scene = preload("res://src/spells/autocast/ice_ball/ice_ball.tscn")


func _process(delta: float):
	if !can_cast():
		return
	
	var cooldown = get_cooldown()
	var max_projectiles = get_max_projectiles()
	if cooldown_elapsed >= cooldown:
		if !target || !is_instance_valid(target):
			target = caster.get_random_target()
		if aspd_ellapsed >= get_attack_speed_time() && projectiles < max_projectiles: 
			if _cast():
				aspd_ellapsed = 0
				projectiles += 1
				
		aspd_ellapsed += delta
		if projectiles >= max_projectiles:
			_reset()
	else:
		cooldown_elapsed += delta
		update_cooldown(cooldown - cooldown_elapsed)


func _reset():
	target = null
	projectiles = 0
	aspd_ellapsed = 0
	cooldown_elapsed = 0
	reset_cooldown()
	

func _cast():
	if !target || !is_instance_valid(target):
		return false
	var node = scene.instance()
	var direction = (target.global_position - caster.global_position)
	node.caster = self
	if 'find_target' in data:
		node.find_target = data.find_target
		node.find_duration = data.find_duration
	node.target = target
	node.projectile_speed = get_projectile_speed()
	node.rotation = direction.angle()
	node.velocity = direction.normalized() * node.projectile_speed
	node.global_position = caster.global_position + direction.normalized()
	add_modifiers_to_node(data, node)
	Global.add_entity(node)
	SFX.add_spell_throw()
	return true


