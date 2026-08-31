extends Behaviour
class_name JumpBehaviour

signal landed()

var target_position: Vector2
var force: float = 5.0
var land_delay: float = 0.6

var _launch_gravity: float
var _move_z = 0
var _landed = false
var _velocity: Vector2
var _shadow_velocity: Vector2
var _shadow_start_poition: Vector2


func _init():
	group_id = "move"


func _ready():
	var direction = target_position - host.global_position

	_velocity = direction.normalized() * direction.length()  

	_move_z = force * 100
	_launch_gravity = _move_z
	_velocity.y -= _move_z / 2

	host.collision.set_deferred("disabled", true)
	host.hurt_box_collision.set_deferred("disabled", true)
	disable_others_in_group()
	container.disable_group("attack")

	SFX.add_jump({ ref_node = host })

	_shadow_velocity = direction.normalized() * direction.length()
	_shadow_start_poition = host.shadow.position
	host.shadow.set_as_toplevel(true)
	host.shadow.global_position = host.global_position + _shadow_start_poition


func _process(delta):
	if disabled || _landed:
		return

	_move_z -= _launch_gravity * delta
	_velocity.y += _launch_gravity * delta 
	host.shadow.global_position += _shadow_velocity * delta
	host.velocity = Vector2.ZERO
	host.global_position += _velocity * delta
	host.direction = _velocity.normalized()

	if _move_z <= 0:
		_landed = true
		host.global_position = target_position
		host.shadow.set_as_toplevel(false)
		host.shadow.position = _shadow_start_poition
		host.state = host.STATES.IDLE
		
		host.collision.set_deferred("disabled", false)
		host.hurt_box_collision.set_deferred("disabled", false)
		host.get_tree().create_timer(land_delay).connect("timeout", self, "_on_landed")
		emit_signal("landed")


func _on_landed():
	enable_others_in_group()
	container.enable_group("attack")
	container.remove(id)


