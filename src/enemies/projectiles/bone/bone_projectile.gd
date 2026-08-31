extends Area2D

var damage: float = 10
var damage_knockback: float = 80
var projectile_speed: float = 20
var projectile_rotation_speed: float = 5

var velocity = Vector2()
var caster

onready var trail_particles = $trail_particles
onready var sprite = $sprite
onready var glow = $glow

func _ready():
	if Settings.get_particle_effect():
		trail_particles.emitting = true
	if Settings.get_glow_effect():
		glow.show()


func _physics_process(delta):
	global_position += velocity * delta

	var rotation_speed = projectile_rotation_speed if velocity.x > 0 else -projectile_rotation_speed
	sprite.rotation += rotation_speed * delta


func _on_projectile_area_entered(area_obj):
	var host = caster.host
	var hit_data = {
		damage_type = Global.DAMAGE_TYPE.MAGIC,
		attack_type = Global.ATTACK_TYPE.RANGE,
		damage = damage,
		damage_knockback = damage_knockback,
		position = global_position,
		position_normal = velocity.normalized(),
	}
	if is_instance_valid(host):
		hit_data = host.stats.hit(hit_data)
	area_obj.hitted(hit_data)
	queue_free()


func _on_projectile_body_entered(_body):
	queue_free()
