extends BaseCaster

var aspd_ellapsed: float = 0

var scene = preload("res://src/spells/autocast/arrow/arrow.tscn")


func _process(delta: float):
	if !can_cast():
		return

	if aspd_ellapsed >= get_attack_speed_time(): 
		if _cast():
			aspd_ellapsed = 0
	aspd_ellapsed += delta


func get_attack_speed_time():
	if data.spread > 1:
		return caster.stats.attack_speed_time + 0.01 * data.spread
	else:
		return caster.stats.attack_speed_time 


func _cast():
	var target = caster.get_closest_target()
	if !target || !is_instance_valid(target):
		return false
	var direction = (target.global_position - caster.global_position).normalized()
	# var direction = caster.direction

	if data.spread > 0:
		var size = data.spread + 1
		var angle_gap = deg2rad(15)
		# var angle_step = (size - 1) * angle_gap/2
		var angle_step = floor((size/2)) * angle_gap
		var angle = -angle_step
		for index in size:
			var spread_direction = direction.rotated(angle + (angle_gap * index))
			var node = scene.instance()
			node.caster = self
			node.velocity = spread_direction * get_projectile_speed()
			node.rotation = spread_direction.angle()
			node.global_position = caster.global_position + spread_direction.normalized() * 5
			node.trail_particles_ammount = 0
			Global.add_entity(node)
	else:
		var node = scene.instance()
		node.caster = self
		node.velocity = direction * get_projectile_speed()
		node.rotation = direction.angle()
		node.global_position = caster.global_position + direction.normalized() * 5
		node.trail_particles_ammount = 0
		Global.add_entity(node)
	SFX.add_throw()
	return true


