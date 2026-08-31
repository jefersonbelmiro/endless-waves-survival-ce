extends Behaviour

var cooldown := 1.0
var cooldown_range := 3.0
var attack_range := 300.0
var proc_chance := 1.0
var suck_duration := 1.0
var health_lost = 500

var _timer: float = 0
var _cooldown_raw: float
var _executing:= false

var _current_health := 0
var _health_losted := 0
var _allow_execute := false


func _init():
	group_id = "attack"


func _ready():
	randomize()
	_cooldown_raw = cooldown
	_current_health = host.stats.current_health
	host.stats.connect("health_changed", self, "_on_health_changed")


func _process(delta):
	if disabled || host.is_disabled() || !host.is_alive() || _executing:
		return

	if _allow_execute && _health_losted >= health_lost:
		_execute()
		_health_losted = 0
	
	elif !_allow_execute:
		_timer += delta
		if _timer > cooldown:
			_timer = 0
			_update_cooldown()
			if proc_chance >= 1 || rand_range(0, 1) <= proc_chance:
				_allow_execute = true


func _update_cooldown():
	if cooldown_range:
		cooldown = rand_range(_cooldown_raw - cooldown_range, _cooldown_raw + cooldown_range)


func _execute():
	_allow_execute = false
	var nodes = Targets.get_closest_targets(host.global_position, 50, [self], attack_range)
	if !nodes.size():
		return

	var targets = []
	for index in nodes.size():
		var node = nodes[index]
		if !Targets.is_valid(node) || node == host || !node.is_alive() || node.is_disabled():
			continue
		# @FIXME handle centipede enemies
		if node.is_in_group("body_parts"):
			continue
		if node.is_in_group("bosses"):
			continue
		targets.append(node)

	if !targets.size():
		return

	_executing = true
	disable_others_in_group()

	host.state_animations[host.STATES.WALK] = "cast"
	host.state_animations[host.STATES.HITTED] = "cast"
	host.velocity = Vector2.ZERO
	container.disable_group("move")
	Global.delay_func(self, "_attack", host.stats.attack_speed_time, { binds = [targets] })

	
func _attack(targets):
	if !is_instance_valid(host):
		return


	var life_sucked = 0
	for index in targets.size():
		var node = targets[index]
		if !Targets.is_valid(node) || node == host || !node.is_alive() || node.is_disabled():
			continue

		life_sucked += node.stats.current_health
		Global.add_enemy_dead_effect(node.global_position, host.base_color)
		node.queue_free()
		var suck_effect = Global.life_suck_effect_scene.instance()
		suck_effect.global_position = node.global_position
		suck_effect.target = host
		suck_effect.duration = suck_duration
		Global.game.add_child(suck_effect)
		SFX.add_hit({ ref_node = host })

	if life_sucked > 0:
		Global.delay_func(self, '_on_healing', suck_duration, { 
			pause_mode_process = false, 
			binds = [life_sucked]
		})
	_on_attack_ended()


func _on_healing(life_sucked):
	SFX.add_healing({ ref_node = host })
	host.stats.current_health += life_sucked
	host.stats.emit_signal("health_changed") 


func _on_attack_ended():
	_executing = false
	if !is_instance_valid(host):
		return
	container.enable_group("move")
	enable_others_in_group()
	host.state_animations[host.STATES.WALK] = "walk"
	host.state_animations[host.STATES.HITTED] = "walk"


func _on_health_changed():
	var diff = _current_health - host.stats.current_health
	_health_losted += diff
	_current_health = host.stats.current_health 
