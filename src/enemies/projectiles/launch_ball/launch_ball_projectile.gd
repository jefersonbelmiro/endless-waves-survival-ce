extends Area2D

export var color = Color('#000000')

var damage: float = 10
var damage_knockback: float = 80
var target_position: Vector2
var force: float = 8.0
var area = 50

var caster

var _launch_gravity: float
var _move_z = 0
var _exploding = false
var _velocity = Vector2()
var _target_marker

onready var trail_particles = $trail_particles
onready var trail = $trail
onready var collision = $collision_shape_2d
onready var glow = $glow


func _ready():
	if Settings.get_particle_effect():
		trail_particles.emitting = true
		trail_particles.modulate = color
	if Settings.get_glow_effect():
		glow.show()

	modulate = color

	collision.shape.radius = area * 0.5
	collision.scale = Vector2(1, 0.7)

	var direction = target_position - global_position
	var speed = direction.length() 

	_velocity = direction.normalized() * speed

	_move_z = force * 100
	_launch_gravity = _move_z
	_velocity.y -= _move_z / 2

	_target_marker = Global.add_danger_target_marker(target_position, area)
	SFX.add_launch({ ref_node = self })


func _exit_tree():
	if is_instance_valid(_target_marker):
		_target_marker.queue_free()


func _physics_process(delta):
	if _exploding:
		queue_free()
		return

	_move_z -= _launch_gravity * delta
	_velocity.y += _launch_gravity * delta 
	global_position += _velocity * delta

	if _move_z <= 0:
		_exploding = true
		global_position = target_position
		collision.set_deferred('disabled', false)
		_target_marker.hide()
		hide()
		Global.add_floor_hit_effect(global_position, area, color)
		Global.add_dead_effect(global_position, color)
		SFX.add_explosion_short_soft({ ref_node = self })
	

func _on_projectile_area_entered(area_obj):
	var host = caster.host
	var hit_data = {
		damage_type = Global.DAMAGE_TYPE.MAGIC,
		attack_type = Global.ATTACK_TYPE.RANGE,
		damage = damage,
		damage_knockback = damage_knockback,
		position = global_position,
	}
	if is_instance_valid(host):
		hit_data = host.stats.hit(hit_data)
	area_obj.hitted(hit_data)
	queue_free()


func _on_projectile_body_entered(_body):
	queue_free()
