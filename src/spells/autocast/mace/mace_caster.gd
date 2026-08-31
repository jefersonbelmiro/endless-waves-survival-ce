extends BaseCaster

var cooldown_elapsed: float = 0
var projectiles = 0
var projectiles_live = 0
var max_projectiles = 0

var scene = preload("res://src/spells/autocast/mace/mace.tscn")


func _process(delta: float):
	if !can_cast():
		return

	# workaround to prevent cast after upgrade
	# whitout this, after upgrade will cast more projectiles in wrong positions
	if !max_projectiles:
		max_projectiles = get_max_projectiles()

	var cooldown = get_cooldown()
	if cooldown_elapsed >= cooldown:
		if projectiles < max_projectiles: 
			_cast()
				
		if projectiles >= max_projectiles && projectiles_live == 0:
			_reset()
	else:
		cooldown_elapsed += delta
		update_cooldown(cooldown - cooldown_elapsed)


func get_max_projectiles():
	return data.get_max_projectiles()


func get_projectile_speed():
	return data.projectile_speed + caster.stats.projectile_speed * 0.5


func _reset():
	projectiles = 0
	cooldown_elapsed = 0
	max_projectiles = get_max_projectiles()
	reset_cooldown()


func _cast():
	if Global.map.safe_zone:
		return false
	var step = 2 * PI / max_projectiles
	var start_pos = Vector2.RIGHT.rotated(deg2rad(randi() % 360))
	for index in max_projectiles:
		var direction = start_pos.rotated(step * index)      
		var node = scene.instance()
		node.caster = self
		node.rotation = direction.angle()
		node.projectile_speed = get_projectile_speed()

		projectiles += 1
		projectiles_live += 1
		node.connect('timeout', self, '_on_projectile_timeout')
		caster.add_child(node)
	return true
	

func _on_projectile_timeout():
	projectiles_live -= 1
