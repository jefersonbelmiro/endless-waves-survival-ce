extends Behaviour
class_name AxeAttackBehaviour

var cooldown: float = 8.0
var proc_chance: float = 0.8
var duration: float = 3.0
var move_speed: float = 10.0
var axe_speed: float = 1200.0
var damage_knockback: float
var damage: float
var target
var collision_layer = 0
var collision_mask = 0

var _timer: float = 0
var _attacking = false


func _init():
	group_id = "attack"


func _ready():
	if !damage:
		damage = host.stats.base_damage * 0.5

	host.axe_hit_box.connect("area_entered", self, "_on_axe_hit_box_area_entered")


func _process(delta):
	target = host.get_target()
	if disabled || !is_instance_valid(target) || !target.is_alive() || host.is_disabled():
		_timer = 0
		return

	if _attacking:
		var target_distance = target.global_position - host.global_position
		var attack_direction = target_distance.normalized()
		if target_distance.length() > 20:
			host.velocity = attack_direction * host.stats.move_speed
			host.direction = attack_direction
		else:
			host.velocity = Vector2.ZERO
		var axe_rotation_velocity = axe_speed 
		if attack_direction.x < 0:
			axe_rotation_velocity *= -1 
		host.state = host.STATES.WALK
		host.axe_pivot.rotation_degrees += (delta * axe_rotation_velocity)
		return

	_timer += delta
	if _timer > cooldown:
		_timer = 0
		if proc_chance >= 1 || rand_range(0, 1) <= proc_chance:
			_attack()


func _attack():
	if host.state == host.STATES.HITTED:
		return

	var initial_collision_layer = host.collision_layer
	var initial_collision_mask = host.collision_mask
	Global.node_set_collision_layer(host, collision_layer)
	Global.node_set_collision_mask(host, collision_mask)
	# host.hurt_box_collision.set_deferred("disabled", true)

	_attacking = true
	host.axe_hit_box_collision.set_deferred("disabled", false)
	
	host.stats.add_modifier({ 'id': 'buff_axe_attack', "move_speed": move_speed, "evasion": 0.7 })
	host.state_animations[host.STATES.WALK] = "axe_attack"
	host.state_animations[host.STATES.HITTED] = "axe_attack"
	disable_others_in_group()
	host.get_tree().create_timer(duration, false).connect('timeout', self, "_on_attack_timeout", [initial_collision_layer, initial_collision_mask])


func _on_attack_timeout(initial_collision_layer, initial_collision_mask):
	if !is_instance_valid(host):
		return
	_attacking = false
	# host.hurt_box_collision.set_deferred("disabled", false)
	enable_others_in_group()
	host.axe_hit_box_collision.set_deferred("disabled", true)
	host.state_animations[host.STATES.WALK] = "walk"
	host.state_animations[host.STATES.HITTED] = "walk"
	host.stats.remove_modifier("buff_axe_attack")
	host.collision_layer = initial_collision_layer
	host.collision_mask = initial_collision_mask


func _on_axe_hit_box_area_entered(area_obj):
	if area_obj.parent == host:
		return
	var hit_data = {
		source_id = 'melee_attack',
		target_node = area_obj.get_parent(),
		damage_type = Global.DAMAGE_TYPE.PHYSICAL,
		attack_type = Global.ATTACK_TYPE.MELEE,
		damage = damage,
		damage_knockback = damage_knockback,
		position = host.axe_hit_box.global_position,
	}
	#if area_obj.parent != target:
	#	print("just knockback?")
	#	# just knockback
	#	hit_data.damage = 0
	#	hit_data.damage_knockback = damage_knockback * 2
	hit_data = host.stats.hit(hit_data)
	area_obj.hitted(hit_data)
	
