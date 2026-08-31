extends BaseCaster

var cooldown_elapsed: float = 0
var aspd_ellapsed: float = 0
var projectiles = 0

var scene = preload("res://src/spells/autocast/arc_lightning/arc_lightning.tscn")


func _process(delta: float):
	if !can_cast():
		return
	
	var cooldown = get_cooldown()
	var max_projectiles = get_max_projectiles()
	if cooldown_elapsed >= cooldown:
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
	projectiles = 0
	aspd_ellapsed = 0
	cooldown_elapsed = 0
	reset_cooldown()


func _cast():
	var target = caster.get_closest_target()
	if !is_instance_valid(target):
		return false
	cast_to_target(target, caster)
	return true


func cast_to_target(target, source):
	var node = scene.instance()
	node.caster = self
	node.target = target
	node.source = source
	node.global_position = source.global_position
	Global.add_entity(node)
	return node

