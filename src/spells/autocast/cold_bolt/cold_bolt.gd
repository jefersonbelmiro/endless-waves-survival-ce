extends Node2D

var target: Node2D
var target_position: Vector2
var modifiers

var velocity = Vector2.DOWN
var projectile_speed: float
var caster: BaseCaster
var spell_data

func _ready():
	spell_data = caster.get_data()


func _physics_process(delta):
	if is_instance_valid(target):
		target_position = target.global_position
	var direction = target_position - global_position
	rotation = direction.angle()
	velocity = direction.normalized() * projectile_speed
	global_position += velocity * delta

	if global_position.distance_to(target_position) < 10:
		_hit()
	

func _hit():
	if !is_instance_valid(target):
		queue_free()
		return
	var data = {
		source_id = caster.data.id,
		target_node = target,
		damage_type = caster.data.damage_type,
		base_damage_factor = caster.data.base_damage_factor,
		damage_knockback = spell_data.damage_knockback,
		position = global_position,
	}
	if modifiers:
		data.modifiers = modifiers
	var hit_data = caster.invoker.stats.hit(data)
	var area_obj = target.get_node('hurt_box')
	area_obj.hitted(hit_data)
	queue_free()


