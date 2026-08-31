extends Behaviour
class_name MoveToPositionBehaviour

signal moved()

var target
var position: Vector2
var move_speed: float
var threshold: float = 5


func _init():
	group_id = "move"


func _process(_delta):
	if disabled || (!target && !position) || host.is_disabled():
		return

	if is_instance_valid(target):
		position = target.global_position
	var distance = position - host.global_position

	if distance.length() < threshold:
		host.velocity = Vector2.ZERO
		emit_signal("moved")
		container.remove(id)
	else:
		host.direction = distance.normalized() 
		if move_speed:
			host.velocity = host.direction * move_speed  
		else:
			host.velocity = host.direction * host.stats.move_speed  

	
