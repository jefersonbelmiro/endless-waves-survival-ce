extends BaseCaster

var cooldown_elapsed: float = 0
var aspd_ellapsed: float = 0
var projectiles = 0
var targets = []

const scene = preload("res://src/spells/autocast/lightning_bolt/lightning_bolt.tscn")


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
			else:
				targets = caster.get_random_targets(max_projectiles) 

		aspd_ellapsed += delta
		if projectiles >= max_projectiles:
			projectiles = 0
			aspd_ellapsed = 0
			cooldown_elapsed = 0
			reset_cooldown()
	else:
		cooldown_elapsed += delta
		update_cooldown(cooldown - cooldown_elapsed)


func _cast():
	var target = targets.pop_back()
	if !is_instance_valid(target):
		return false
	var node = scene.instance()
	node.caster = self
	node.target = target
	node.global_position = target.global_position
	Global.add_entity(node)
	return true
