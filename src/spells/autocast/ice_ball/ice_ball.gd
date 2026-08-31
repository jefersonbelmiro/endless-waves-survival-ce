extends Area2D

export var hit_effect_color = Color('#1425d6')

var modifiers

var velocity = Vector2()
var projectile_speed: float
var target: Node
var caster
var spell_data

var find_target = false
var find_duration: float

var _steer_velocity = Vector2()
var _steer_force = 0.05

onready var trail_particles = $trail_particles
onready var glow = $glow


func _ready():
	randomize()
	_steer_force = rand_range(0.03, 0.10)
	if Settings.get_particle_effect():
		trail_particles.emitting = true
	if Settings.get_glow_effect():
		glow.show()
	spell_data = caster.get_data()

	if find_duration > 0:
		get_tree().create_timer(find_duration, false).connect("timeout", self, "queue_free")


func _physics_process(delta):
	if find_target && get_tree().get_frame() % 5:
		if !is_instance_valid(target) && is_instance_valid(caster):
			target = caster.invoker.get_random_target()
			if is_instance_valid(target):
				var direction = (target.global_position - global_position)
				_steer_velocity = direction.normalized() * projectile_speed 

	if _steer_velocity:
		if is_instance_valid(target):
			var direction = (target.global_position - global_position)
			_steer_velocity = direction.normalized() * projectile_speed 
		velocity = velocity.linear_interpolate(_steer_velocity, _steer_force)

	position += velocity * delta


func _on_ice_ball_area_entered(area_obj):
	if spell_data.area > 0:
		Global.add_hit_box_area_from_source(self)
		Global.add_floor_hit_effect(global_position, spell_data.get_area(), hit_effect_color)
	else:
		var hit_data = {
			source_id = spell_data.id,
			target_node = area_obj.get_parent(),
			damage_type = spell_data.damage_type,
			damage_knockback = spell_data.damage_knockback,
			position = global_position,
			position_normal = velocity.normalized(),
		}
		if 'base_damage_factor' in spell_data:
			hit_data.base_damage_factor = spell_data.base_damage_factor
		if 'damage' in spell_data:
			hit_data.damage = spell_data.damage
		if modifiers:
			hit_data.modifiers = modifiers
		if is_instance_valid(caster):
			hit_data = caster.invoker.stats.hit(hit_data)
		area_obj.hitted(hit_data)

	queue_free()


func _on_ice_ball_body_entered(_body):
	queue_free()
