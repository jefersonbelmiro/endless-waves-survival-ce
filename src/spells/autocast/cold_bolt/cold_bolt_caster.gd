extends BaseCaster

var cooldown_elapsed: float = 0
var aspd_ellapsed: float = 0
var projectiles = 0
var target: Node2D

var scene = preload("res://src/spells/autocast/cold_bolt/cold_bolt.tscn")


func _process(delta: float):
	if !can_cast():
		return
	
	var cooldown = get_cooldown()
	var max_projectiles = get_max_projectiles()
	if cooldown_elapsed >= cooldown:
		if !invoker.target_in_attack_range(target):
			target = caster.get_closest_target()
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
	if !is_instance_valid(target) || !target.is_alive():
		return false
	var node = scene.instance()
	var viewport_size = caster.get_viewport_rect().size * 0.5
	var x = target.global_position.x + 50
	var y = caster.global_position.y + viewport_size.y * -1
	if target.global_position.x > caster.global_position.x:
		x = target.global_position.x -50
		
	var start_position = Vector2(x, y)
	var direction = target.global_position - start_position
	node.caster = self
	node.target = target
	node.rotation = direction.angle()
	node.velocity = direction.normalized() * get_projectile_speed()
	node.projectile_speed = get_projectile_speed()
	node.global_position = start_position
	add_modifiers_to_node(data, node)
	Global.add_entity(node)
	return true
