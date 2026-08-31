extends Area2D

var velocity = Vector2()
var caster: BaseCaster

var direction: Vector2
var attack_range: float

enum { FLY, STICK, RETURNED }
var throw_speed = 2 * 60
var state: int = FLY
var spin_speed: float = 4 * 360

var attack_distance: float

var angle: float = 15.0
var curve_factor: float = 0.8

var duration = 1.0
var elapsed = 0.0
var start_position: Vector2
var end_position: Vector2
var high_position: Vector2
var low_position: Vector2
var velocity_normal: Vector2


func _ready() -> void:
	attack_range = caster.invoker.stats.attack_range

	start_position = global_position
	end_position = start_position + direction * attack_range
	high_position = start_position + direction.rotated(deg2rad(angle)) * curve_factor * attack_range
	low_position = start_position + direction.rotated(deg2rad(-angle)) * curve_factor * attack_range
	duration = start_position.distance_to(end_position) / throw_speed 


func _physics_process(delta):
	match state:
		FLY:
			fly(delta)
		STICK:
			stick(delta) 


func fly_2(delta: float) -> void:
	var distance = velocity * delta
	attack_distance += distance.length()
	global_position += distance 

	#spin
	rotation_degrees += spin_speed * delta

	if attack_distance >= attack_range:
		velocity *= -1
		state = STICK


func stick_2(delta: float) -> void:
	var target = caster.invoker.global_position
	var dist = global_position.distance_to(target)
	if dist < 20:
		queue_free()
	else:
		global_position = global_position.linear_interpolate(target, (throw_speed * delta)/dist)
	#spin
	rotation_degrees += spin_speed * delta


func fly(delta: float) -> void:
	elapsed += delta
	
	var weight = elapsed / duration
	_update_position(start_position, high_position, end_position, weight)
	
	#spin
	rotation_degrees += spin_speed * delta

	if elapsed >= duration:
		state = STICK
		elapsed = 0.0


func stick(delta: float) -> void:
	elapsed += delta
	
	var target_position = caster.invoker.global_position
	var weight = elapsed / duration
	_update_position(end_position, low_position, target_position, weight)

	#spin
	rotation_degrees += spin_speed * delta

	if elapsed >= duration:
		queue_free()


# use quadratic bezier
# https://docs.godotengine.org/en/3.6/tutorials/math/beziers_and_curves.html
func _update_position(start, high, end, weight: float):
	var q0 = start.linear_interpolate(high, weight)
	var q1 = high.linear_interpolate(end, weight)
	var position = q0.linear_interpolate(q1, weight)

	velocity_normal = (position - global_position).normalized()
	global_position = position


func _on_dagger_area_entered(area_obj):
	var spell_data = caster.get_data()
	var hit_data = caster.invoker.stats.hit({
		source_id = spell_data.id,
		target_node = area_obj.get_parent(), 
		damage_type = spell_data.damage_type,
		base_damage_factor = spell_data.base_damage_factor,
		damage_knockback = spell_data.damage_knockback,
		position = global_position,
		position_normal = velocity_normal,
	})
	area_obj.hitted(hit_data)

