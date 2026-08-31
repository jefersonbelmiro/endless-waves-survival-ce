extends Behaviour
class_name ChaseBehaviour

var targets

func _init():
	group_id = "move"
	

func _ready():
	if targets:
		for group in targets.keys():
			host.add_target(group, targets[group])


func _process(_delta):
	if disabled || !host.is_alive():
		return
	var target = host.get_target()
	if !is_instance_valid(target) || !target.is_alive():
		host.state = host.STATES.IDLE
		host.velocity = Vector2.ZERO
		return

	var direction = Vector2.ZERO
	var distance = target.global_position - host.global_position
	if distance.length() >  5:
		direction = distance.normalized()

	host.direction = direction
	host.velocity = direction * host.stats.move_speed
