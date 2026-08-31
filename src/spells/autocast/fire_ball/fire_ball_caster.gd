extends BaseCaster

var cooldown_elapsed: float = 0
var aspd_ellapsed: float = 0
var projectiles = 0

var scene = preload("res://src/spells/autocast/fire_ball/fire_ball.tscn")


func _ready():
	randomize()


func _process(delta: float):
	if !can_cast():
		return
	
	var cooldown = get_cooldown()
	if cooldown_elapsed >= cooldown:
		if aspd_ellapsed >= data.cast_time: 
			if _cast():
				_reset()
		aspd_ellapsed += delta
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
	var max_projectiles = get_max_projectiles()
	var step = 2 * PI / max(max_projectiles, 8)
	var start_pos = Vector2.RIGHT.rotated(deg2rad(randi() % 360))
	for index in max_projectiles:
		var direction = start_pos.rotated(step * index)
		var node = scene.instance()
		node.caster = self
		if 'scale_factor' in data:
			node.scale_factor = data.scale_factor
		node.rotation = direction.angle()
		node.velocity = direction.normalized() * get_projectile_speed()
		node.global_position = caster.global_position + direction.normalized()
		add_modifiers_to_node(data, node)
		Global.add_entity(node)
	SFX.add_spell_throw()
	return true

