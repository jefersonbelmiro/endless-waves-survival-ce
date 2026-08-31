extends Behaviour
class_name RushAttackBehaviour

var cooldown: float = 4.0
var cooldown_range: float = 3.0
var proc_chance: float = 0.8
var attack_range: float = 100.0
var move_speed: float = 60.0
var duration: float = 1.5
var effect_color = '#40ff0c00'
var collision_layer = 0
var collision_mask = 0
var target

var _timer: float = 0
var _cooldown_raw: float
var _attacking = false
var _attack_direction: Vector2


func _init():
	group_id = "attack"


func _ready():
	_cooldown_raw = cooldown
	_update_cooldown()
	randomize()


func _process(delta):
	target = host.get_target()
	if disabled || !is_instance_valid(target) || !target.is_alive() || host.is_disabled():
		_timer = 0
		return

	if _attacking:
		host.state = host.STATES.WALK
		host.velocity = _attack_direction * host.stats.move_speed
		host.direction = _attack_direction
		return

	_timer += delta
	if _timer > cooldown:
		var dist = target.global_position - host.global_position
		if dist.length() < attack_range:
			_timer = 0
			_update_cooldown()
			if proc_chance >= 1 || rand_range(0, 1) <= proc_chance:
				_attack(dist.normalized())


func _update_cooldown():
	if cooldown_range:
		cooldown = rand_range(_cooldown_raw - cooldown_range, _cooldown_raw + cooldown_range)


func _attack(direction):
	if host.state == host.STATES.HITTED:
		return
	if host.is_disabled():
		return

	_attacking = true
	_attack_direction = direction

	var initial_collision_layer = host.collision_layer
	var initial_collision_mask = host.collision_mask
	Global.node_set_collision_layer(host, collision_layer)
	Global.node_set_collision_mask(host, collision_mask)

	container.disable_group("move")
	container.disable_group("attack", [id, "melee_attack"])
	host.state = host.STATES.WALK

	host.stats.add_modifier({ 'id': 'buff_rush_attack', "move_speed": move_speed })

	if effect_color:
		host.sprite.material.set_shader_param('border_color', Color(effect_color))
		host.sprite.material.set_shader_param('add_border', true)

	host.get_tree().create_timer(duration, false).connect('timeout', self, "_on_attack_timeout", [initial_collision_layer, initial_collision_mask])


func _on_attack_timeout(initial_collision_layer, initial_collision_mask):
	if !is_instance_valid(host):
		return
	_attacking = false
	host.collision_layer = initial_collision_layer
	host.collision_mask = initial_collision_mask
	host.stats.remove_modifier("buff_rush_attack")
	container.enable_group("move")
	container.enable_group("attack", [id, "melee_attack"])
	if effect_color:
		host.sprite.material.set_shader_param('add_border', false)


