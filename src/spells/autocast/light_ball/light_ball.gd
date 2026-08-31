extends Area2D

var bounces = 0

var velocity = Vector2()
var projectile_speed: float
var caster: BaseCaster
var spell_data

onready var trail_particles = $trail_particles
onready var collision_shape = $collision_shape_2d.shape
onready var glow = $glow


func _ready():
	randomize()
	if Settings.get_particle_effect():
		trail_particles.emitting = true
	if Settings.get_glow_effect():
		glow.show()
	spell_data = caster.get_data()


func _physics_process(delta):
	global_position += velocity * delta


func _on_light_ball_area_entered(area_obj):
	var hit_data = caster.invoker.stats.hit({
		source_id = spell_data.id,
		target_node = area_obj.get_parent(), 
		damage_type = spell_data.damage_type,
		base_damage_factor = spell_data.base_damage_factor,
		damage_knockback = spell_data.damage_knockback,
		position = global_position,
		position_normal = velocity.normalized(),
	})
	area_obj.hitted(hit_data)

	if bounces <= 0:
		queue_free()
	else:
		bounce()


func bounce():
	# improve: work better with walls, but not bounce sometimes, just refrect
	# var collision_pos = global_position + velocity.normalized() * 20
	# var collision_normal = (collision_pos - global_position).normalized()
	# velocity = velocity.bounce(collision_normal)

	bounces -= 1
	var angle = deg2rad(rand_range(40, 110))
	if randf() >= 0.5: 
		angle *= -1
	velocity = velocity.rotated(angle).normalized() * projectile_speed


func _on_light_ball_body_entered(_body):
	queue_free()
