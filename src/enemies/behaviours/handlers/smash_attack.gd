extends Behaviour
class_name SmashAttackBehaviour

var proc_chance: float = 0.8
var jump_force: float = 8.0
var jump_distance: float = 100.0
var cooldown: float = 4.0
var cooldown_range: float = 3.0
var attack_range: float = 200.0
var damage_area: float = 40
var damage_knockback: float
var damage: float
var knockback_area: float = 100
var target

var _timer: float = 0
var _cooldown_raw: float

func _init():
	group_id = "attack"
	randomize()


func _ready():
	_cooldown_raw = cooldown
	if !damage:
		damage = host.stats.base_damage
	

func _process(delta):
	target = host.get_target()
	if disabled || !is_instance_valid(target) || !target.is_alive() || host.is_disabled():
		_timer = 0
		return

	_timer += delta
	if _timer > cooldown:
		var distance = target.collision.global_position - host.global_position
		if distance.length() < attack_range && _timer > cooldown:
			_timer = 0
			_update_cooldown()
			if proc_chance >= 1 || rand_range(0, 1) <= proc_chance:
				_attack(distance)


func _update_cooldown():
	if cooldown_range:
		cooldown = rand_range(_cooldown_raw - cooldown_range, _cooldown_raw + cooldown_range)


func _attack(distance):
	if host.state == host.STATES.HITTED:
		return
	if container.has("jump"):
		return
	
	var target_position = host.global_position + distance.normalized() * distance.length()
	if !Global.map.spawn_bounds_has_point(target_position):
		var host_size = host.hurt_box_collision.shape.radius
		target_position = host.global_position + distance.normalized() * (distance.length() - host_size)
	var target_marker = Global.add_danger_target_marker(target_position, damage_area) 
	var jump = container.add("jump", { target_position = target_position, force = jump_force })
	jump.connect("landed", self, '_jump_landed', [target_marker])


func _jump_landed(target_marker):
	target_marker.queue_free()
	var hit_data = {
		source_node = host,
		source_id = id,
		area = damage_area,
		damage = damage,
		damage_knockback = damage_knockback,
		damage_type = Global.DAMAGE_TYPE.PHYSICAL,
	}
	Global.add_hit_box_area(host.global_position, hit_data, ["player_hurtbox"])
	SFX.add_explosion_4({ ref_node = host })

	# knockback hit area
	var knockback_hit_data = {
		source_node = host,
		source_id = id,
		area = knockback_area,
		# damage = 0,
		damage_knockback = damage_knockback,
		damage_type = Global.DAMAGE_TYPE.PHYSICAL,
	}
	Global.add_floor_hit_effect(host.global_position, knockback_area, host.base_color)
	Global.add_hit_box_area(host.global_position, knockback_hit_data, ["player_hurtbox", "enemy_hurtbox"], [host])

