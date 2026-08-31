extends Behaviour
class_name SeekBehaviour

var target
var steer_force = 5.0

var _acceleration: Vector2

func _init():
	group_id = "move"


func _process(delta):
	target = host.get_target()
	if disabled || !is_instance_valid(target) || !target.is_alive() || host.is_disabled():
		return

	var distance = (target.global_position - host.global_position).normalized()
	var direction = distance.normalized()

	var desired = direction * host.stats.move_speed
	var steer =  (desired - host.velocity).normalized() * steer_force

	_acceleration += steer * delta
	host.velocity += _acceleration
	host.velocity = host.velocity.limit_length(host.stats.move_speed)
	host.direction = direction
	
