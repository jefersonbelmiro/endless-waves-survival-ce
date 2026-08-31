extends Behaviour
class_name MeleeAttackBehaviour

var damage: float 
var damage_knockback: float
var collision_radius: int
var collision_position: Vector2

var _hit_box
var _timer: float = 0
var _attacking = false


func _init():
	group_id = "attack"


func _ready():
	if !collision_radius:
		collision_radius = host.get_node("hurt_box/collision_shape_2d").shape.radius
	if !collision_position:
		collision_position = host.get_node("hurt_box").position
	if !damage:
		damage = host.stats.base_damage
		
	_hit_box = Global.create_hit_box_melee({ disabled = disabled, collision_radius = collision_radius, collision_mask = "player_hurtbox" })
	_hit_box.position = collision_position
	_hit_box.connect("area_entered", self, "_on_hit_box_area_entered")
	host.add_child(_hit_box)
	connect("disabled_changed", self, "_on_disabled_changed")


func _process(delta):
	if disabled || !_attacking || host.is_disabled():
		_timer = 0
		return
	_timer += delta
	if _timer > host.stats.attack_speed_time:
		_timer = 0
		_attacking = false
		_update_collision()


func _attack(area_obj):
	_attacking = true
	var hit_data = {
		source_id = 'melee_attack',
		target_node = area_obj.get_parent(),
		damage_type = Global.DAMAGE_TYPE.PHYSICAL,
		attack_type = Global.ATTACK_TYPE.MELEE,
		damage = damage,
		damage_knockback = damage_knockback,
		position = host.global_position,
	}
	hit_data = host.stats.hit(hit_data)
	area_obj.hitted(hit_data)
	

func _update_collision():
	_hit_box.collision.set_deferred('disabled', _attacking || disabled)


func _on_hit_box_area_entered(area_obj):
	if disabled:
		return
	_attack(area_obj)
	_update_collision()


func _on_disabled_changed(_disabled: bool):
	_update_collision()

