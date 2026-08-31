extends Behaviour
class_name ChaseTargetDirectionBehaviour

var target: Node2D


func _init():
	group_id = "move"


func _process(_delta):
	if disabled || !host.is_alive() || host.is_disabled():
		return
	if !is_instance_valid(target):
		host.state = host.STATES.IDLE
		return

	host.direction = target.direction
	host.velocity = target.velocity
