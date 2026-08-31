extends Behaviour

var cooldown: float = 4.0
var cooldown_range: float = 3.0
var attack_range: float = 300.0
var damage_knockback: float = 0
var proc_chance: float = 0.7
var projectile: String
var projectile_speed = 100
var color = "#81007f"
var attacks = 5
var projectiles = 8
var target

var _timer: float = 0
var _cooldown_raw: float
var _attacking := false
var _projectiles_scenes = {
	ball = Global.ball_projectile_scene,
	bone = Global.bone_projectile_scene,
}
var _current_projectile = 'bone'


func _init():
	group_id = "attack"
	randomize()


func _ready():
	_cooldown_raw = cooldown


func _process(delta):
	target = host.get_target()
	if disabled || !is_instance_valid(target) || !target.is_alive() || host.is_disabled():
		return

	if _attacking:
		host.direction = (target.global_position - host.global_position).normalized()
		_timer = 0
		return

	_timer += delta
	if _timer > cooldown:
		var dist = target.global_position - host.global_position
		if dist.length() < attack_range && !_attacking:
			_timer = 0
			_update_cooldown()
			if proc_chance >= 1 || rand_range(0, 1) <= proc_chance:
				_cast(dist)


func _update_cooldown():
	if cooldown_range:
		cooldown = rand_range(_cooldown_raw - cooldown_range, _cooldown_raw + cooldown_range)


func _cast(direction):
	if host.is_disabled():
		return
	if !Global.map.spawn_bounds_has_point(host.global_position):
		return

	_attacking = true
	if projectile: 
		_current_projectile = projectile
	else:
		_current_projectile = _projectiles_scenes.keys()[randi() % _projectiles_scenes.size()]
	disable_others_in_group()

	host.state_animations[host.STATES.WALK] = "cast"
	host.state_animations[host.STATES.HITTED] = "cast"
	host.velocity = Vector2.ZERO
	container.disable_group("move")
	for index in attacks:
		Global.delay_func(self, "_attack", (index + 1) * host.stats.attack_speed_time, { binds = [direction] })
	Global.delay_func(self, '_on_attack_ended', (attacks + 1) * host.stats.attack_speed_time)

	
func _attack(direction):
	if !is_instance_valid(host):
		return
	if projectiles == 1:
		var node = _projectiles_scenes[_current_projectile].instance()
		node.caster = self
		node.projectile_speed = projectile_speed
		if 'color' in node:
			node.color = Color(color)
		node.damage = host.stats.base_damage
		node.damage_knockback = damage_knockback
		node.rotation = direction.angle()
		node.velocity = direction.normalized() * node.projectile_speed
		node.global_position = host.global_position + direction.normalized()
		Global.add_entity(node)
		SFX.add_spell_throw({ ref_node = host })
	elif projectiles > 1:
		var step = 2 * PI / max(projectiles, 8)
		var start_pos = Vector2.RIGHT.rotated(deg2rad(randi() % 360))
		if projectiles < 8:
			start_pos = direction.normalized()
		for index in projectiles:
			var step_direction = start_pos.rotated(step * index)
			var node = _projectiles_scenes[_current_projectile].instance()
			node.caster = self
			node.projectile_speed = projectile_speed
			if 'color' in node:
				node.color = Color(color)
			node.damage = host.stats.base_damage
			node.damage_knockback = damage_knockback
			node.rotation = step_direction.angle()
			node.velocity = step_direction * node.projectile_speed
			node.global_position = host.global_position + step_direction * 20
			Global.add_entity(node)
		SFX.add_spell_throw({ ref_node = host })


func _on_attack_ended():
	_attacking = false
	if !is_instance_valid(host):
		return
	container.enable_group("move")
	enable_others_in_group()
	host.state_animations[host.STATES.WALK] = "walk"
	host.state_animations[host.STATES.HITTED] = "walk"

