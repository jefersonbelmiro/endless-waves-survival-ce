extends Behaviour
class_name RangeAttackBehaviour

var cooldown: float = 4.0
var cooldown_range: float = 3.0
var attack_range: float = 50.0
var damage_knockback: float = 0
var proc_chance: float = 0.8
var projectile = 'ball'
var projectile_speed = 100
var color = '#000000'
var target

var _timer: float = 0
var _cooldown_raw: float
var _projectiles_scenes = {
	ball = Global.ball_projectile_scene,
	bone = Global.bone_projectile_scene,
}


func _init():
	group_id = "attack"
	randomize()


func _ready():
	_cooldown_raw = cooldown


func _process(delta):
	target = host.get_target()
	if disabled || !is_instance_valid(target) || !target.is_alive() || host.is_disabled():
		_timer = 0
		return

	_timer += delta
	if _timer > cooldown:
		var dist = target.global_position - host.global_position
		if dist.length() < attack_range:
			_timer = 0
			_update_cooldown()
			if proc_chance >= 1 || rand_range(0, 1) <= proc_chance:
				_attack(dist)


func _update_cooldown():
	if cooldown_range:
		cooldown = rand_range(_cooldown_raw - cooldown_range, _cooldown_raw + cooldown_range)


func _attack(direction):
	if host.state == host.STATES.HITTED:
		return
	if host.is_disabled():
		return
	var node = _projectiles_scenes[projectile].instance()
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


