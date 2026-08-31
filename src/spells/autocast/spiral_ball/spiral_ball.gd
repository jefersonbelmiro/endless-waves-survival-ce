extends Position2D

signal timeout()

onready var pivot = $pivot

var caster: BaseCaster
var spell_data
var pivot_height = 0
var duration_end = false
var projectile_speed: float
var explosion = false
var velocity: Vector2

onready var trail_particles = $pivot/trail_particles
onready var glow = $pivot/glow
onready var hit_box = $pivot/hit_box

func _ready():
	spell_data = caster.get_data()
	var duration = caster.get_duration()
	if duration > 0:
		get_tree().create_timer(duration).connect("timeout", self, "_on_duration_timer_timeout")
	
	pivot_height = -spell_data.get_area()
	pivot.position.y = pivot_height * 0.2
	
	if Settings.get_particle_effect():
		trail_particles.emitting = true
	if Settings.get_glow_effect():
		glow.show()

	if explosion:
		hit_box.connect("body_entered", self, "_on_body_entered")


func _physics_process(delta):
	if caster.invoker.is_dead():
		queue_free()
		return

	if explosion && velocity:
		position += velocity * delta
	else:
		rotation_degrees += (delta * projectile_speed)
		if !duration_end && pivot.position.y > pivot_height:
			pivot.position.y -= (delta * projectile_speed)
		elif duration_end && pivot.position.y < pivot_height * 0.2:
			pivot.position.y += (delta * projectile_speed)
		elif pivot.position.y >= pivot_height * 0.2:
			emit_signal('timeout')
			queue_free()


func _on_hit_box_area_entered(area_obj):
	var data = {
			source_id = spell_data.id,
			target_node = area_obj.get_parent(),
			damage_type = spell_data.damage_type,
			damage_knockback = spell_data.damage_knockback,
			position = pivot.global_position,
		}
	if explosion:
		data.base_damage_factor = spell_data.explosion_base_damage_factor
	else:
		data.base_damage_factor = spell_data.base_damage_factor
	var hit_data = caster.invoker.stats.hit(data)
	area_obj.hitted(hit_data)


func _on_duration_timer_timeout():
	duration_end = true


func _on_body_entered(_body):
	queue_free()
