extends BaseCaster

var cooldown_elapsed: float = 0
var aspd_ellapsed: float = 0
var projectiles = 0

var scene = preload("res://src/spells/autocast/crystal_rain/crystal_rain.tscn")
var targets = {}

	
func _ready():
	randomize()


func _process(delta: float):
	if !can_cast():
		return
	
	var cooldown = get_cooldown()
	var max_projectiles = get_max_projectiles()
	if cooldown_elapsed >= cooldown:
		# if aspd_ellapsed >= get_attack_speed_time() + data.cast_time: 
		if aspd_ellapsed >= get_attack_speed_time() + data.cast_time  && projectiles < max_projectiles: 
			if _cast():
				# aspd_ellapsed = 0
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
	targets = {}
	reset_cooldown()


func _cast():
	if Global.map.safe_zone:
		return false
	var target = caster.get_random_target()
	var position: Vector2
	if !is_instance_valid(target) || targets.has(target):
		position = Global.map.get_random_position_bounds()
	else:
		position = target.global_position
		targets[target] = true
	# if !Global.map.spawn_bounds_has_point(position):
	# 	position = Global.map.get_random_position_bounds()
	var node = scene.instance()
	node.velocity = Vector2.DOWN * get_projectile_speed()
	node.caster = self
	node.global_position = position + Vector2(0, -150)
	node.target_position = position
	Global.add_entity(node)
	return true
	
