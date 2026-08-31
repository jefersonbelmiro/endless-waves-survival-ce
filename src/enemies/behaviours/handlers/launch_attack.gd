extends Behaviour
class_name LauchAttackBehaviour

var auto_attack = true
var cooldown: float = 2.0
var attack_range: float = 50.0
var damage_knockback: float = 0
var proc_chance: float = 1.0
var color = '#000000'
var target
var max_projectiles = 1
var force: float = 8.0

var _cooldown_elapsed: float = 0
var _aspd_ellapsed: float = 0
var _projectiles = 0
var _target_positions = []
var _attacking = false


func _init():
	group_id = "attack"


func _process(delta):
	target = host.get_target()
	if disabled || !is_instance_valid(target) || !target.is_alive() || host.is_disabled():
		_cooldown_elapsed = 0
		return

	if auto_attack && !_attacking:
		_cooldown_elapsed += delta
		if _cooldown_elapsed > cooldown:
			_reset()
			if proc_chance < 1.0 && rand_range(0, 1) > proc_chance:
				return
			var dist = target.global_position - host.global_position
			if dist.length() > attack_range:
				return
			_attacking = true

	if _attacking:
		if _aspd_ellapsed >= host.stats.attack_speed_time && _projectiles < max_projectiles:
			_attack()
		_aspd_ellapsed += delta
		if _projectiles >= max_projectiles:
			_attacking = false
			_reset()


func attack(position: Vector2):
	_target_positions.append(position)
	max_projectiles = _target_positions.size()
	_attacking = true


func _reset():
	_projectiles = 0
	_aspd_ellapsed = 0
	_cooldown_elapsed = 0
	_target_positions = []


func _attack():
	if host.state == host.STATES.HITTED:
		return null

	var target_position
	if !auto_attack:
		if _target_positions.size() == 0:
			return null
		target_position = _target_positions[_projectiles]
	else:
		target_position = target.global_position

	_aspd_ellapsed = 0
	_projectiles += 1

	var node = Global.launch_ball_projectile_scene.instance()
	node.caster = self
	node.color = Color(color)
	node.force = force
	node.damage = host.stats.base_damage
	node.damage_knockback = damage_knockback
	node.target_position = target_position + Vector2(0, 10)
	node.global_position = host.global_position + Vector2(0, -30)
	Global.add_entity(node)
	return node


