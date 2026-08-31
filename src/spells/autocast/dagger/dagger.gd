extends Area2D

var velocity = Vector2()
var caster: BaseCaster

# var start_position
# var attack_range: float
var attack_distance: float
var pass_through = false

onready var trail_particles = $trail_particles

func _ready():
	# start_position = global_position
	# attack_range = caster.invoker.stats.attack_range
	if Settings.get_particle_effect():
		trail_particles.emitting = true


func _physics_process(delta):
	position += velocity * delta
	# var distance = velocity * delta
	# attack_distance += distance.length()
	# global_position += distance
	# if attack_distance >= attack_range:
	# 	queue_free()


func _on_dagger_area_entered(area_obj):
	var spell_data = caster.get_data()
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
	if !pass_through:
		queue_free()


func _on_dagger_body_entered(_body):
	queue_free()
