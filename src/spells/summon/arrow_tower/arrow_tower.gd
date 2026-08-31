extends TowerSummonBase

var scene = preload("res://src/spells/autocast/arrow/arrow.tscn")
var cooldown_elapsed: float = 0
var aspd_ellapsed: float = 0
var projectiles = 0
var target

func _process(delta: float):
	if !can_cast():
		return
	var cooldown = get_cooldown()
	var max_projectiles = get_max_projectiles()
	if cooldown_elapsed >= cooldown:
		if !target || !is_instance_valid(target):
			target = get_closest_target()
		if aspd_ellapsed >= get_attack_speed_time() && projectiles < max_projectiles: 
			if _cast():
				aspd_ellapsed = 0
				projectiles += 1
				
		aspd_ellapsed += delta
		if projectiles >= max_projectiles:
			_reset()
	else:
		cooldown_elapsed += delta


func _reset():
	target = null
	projectiles = 0
	aspd_ellapsed = 0
	cooldown_elapsed = 0


func _cast():
	if !target || !is_instance_valid(target):
		return false
	var node = scene.instance()
	var start_position = global_position + Vector2(0, 5)
	var direction = (target.global_position - start_position).normalized()
	node.caster = self
	node.rotation = direction.angle()
	node.global_position = start_position
	node.velocity = direction * get_projectile_speed()
	node.trail_particles_ammount = 30
	add_modifiers_to_node(data, node)
	Global.add_entity(node)
	SFX.add_throw()
	return true

