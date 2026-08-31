extends Area2D

var velocity = Vector2()
var caster
var spell_data
var trail_particles_ammount = 50

var start_position
# var attack_range: float
# var attack_distance: float

onready var trail_particles = $trail_particles

func _ready():
	# start_position = global_position
	# attack_range = caster.invoker.stats.attack_range
	if Settings.get_particle_effect() && trail_particles_ammount:
		trail_particles.amount = trail_particles_ammount
		trail_particles.emitting = true
	spell_data = caster.get_data()


func _physics_process(delta):
	position += velocity * delta
	# var distance = velocity * delta
	# attack_distance += distance.length()
	# global_position += distance
	# if attack_distance >= attack_range:
	# 	queue_free()


func _on_dagger_area_entered(area_obj):
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
	if is_instance_valid(caster):
		hit_data = caster.invoker.stats.hit(hit_data)
	area_obj.hitted(hit_data)
	queue_free()


func _on_dagger_body_entered(_body):
	queue_free()
