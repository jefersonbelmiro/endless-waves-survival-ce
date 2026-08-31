extends Area2D

var scale_factor = 0
var velocity = Vector2()
var spell_data
var caster: BaseCaster
var modifiers

onready var trail_particles = $trail_particles
onready var glow = $glow


func _ready():
	spell_data = caster.get_data()
	if scale_factor:
		scale += scale * scale_factor
		$trail.width += $trail.width * scale_factor
	if Settings.get_particle_effect():
		trail_particles.emitting = true
	if Settings.get_glow_effect():
		glow.show()


func _physics_process(delta): 
	position += velocity * delta


func _on_fire_ball_area_entered(area_obj):
	var data = {
		source_id = spell_data.id,
		target_node = area_obj.get_parent(),
		damage_type = spell_data.damage_type,
		base_damage_factor = spell_data.base_damage_factor,
		damage_knockback = spell_data.damage_knockback,
		position = global_position,
		position_normal = velocity.normalized(),
	}
	if modifiers:
		data.modifiers = modifiers
	var hit_data = caster.invoker.stats.hit(data)
	area_obj.hitted(hit_data)


func _on_fire_ball_body_entered(_body):
	queue_free()
