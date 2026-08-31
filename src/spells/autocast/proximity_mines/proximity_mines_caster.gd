extends BaseCaster

var scene =  preload("res://src/spells/autocast/proximity_mines/proximity_mine.tscn")

var cooldown_elapsed: float = 0
var aspd_ellapsed: float = 0
var projectiles = 0

var max_alives = 5


func _ready():
	randomize()
	# @FIXME move to json data?
	if !'max_projectiles' in data:
		data.max_projectiles = 1


func _process(delta: float):
	if !can_cast():
		return

	var cooldown = get_cooldown()
	var max_projectiles = get_max_projectiles()
	if cooldown_elapsed >= cooldown:
		if aspd_ellapsed >= get_attack_speed_time() + data.cast_time && projectiles < max_projectiles: 
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
	if Global.map.safe_zone:
		return false
	var node = scene.instance()
	var target_position = caster.global_position + caster.direction * 50
	var direction = target_position.normalized()
	node.caster = self
	node.target_position = target_position
	node.projectile_speed = get_projectile_speed()
	node.velocity = direction * node.projectile_speed
	node.global_position = caster.global_position + direction
	node.add_to_group(id)
	Global.add_entity(node)
	SFX.add_throw()

	var alives = get_tree().get_nodes_in_group(id)
	var index = 0
	var safe_it = 100
	while alives.size() > max_alives && safe_it > 0:
		safe_it -= 1
		if !is_instance_valid(alives[index]):
			index += 1
			continue
		alives[index].explode()
		break

	return true

