extends Behaviour
class_name FollowPathBehaviour

var targets
var path: Path2D

var _path_follow: PathFollow2D


func _init():
	group_id = "move"
	

func _ready():
	if targets:
		for group in targets.keys():
			host.add_target(group, targets[group])

	_path_follow = PathFollow2D.new()
	path.add_child(_path_follow)


func _process(delta):
	if disabled || !host.is_alive():
		return

	if host.is_disabled():
		return

	if host.global_position.distance_to(_path_follow.global_position) < 80:
		_path_follow.set_offset(_path_follow.get_offset() + host.stats.move_speed * delta)

	#var target = host.get_target()
	#if !is_instance_valid(target) || !target.is_alive():
	#	host.state = host.STATES.IDLE
	#	host.velocity = Vector2.ZERO
	#	return

	var direction = Vector2.ZERO
	var distance = _path_follow.global_position - host.global_position
	if distance.length() > 5:
		direction = distance.normalized()

	host.direction = direction
	host.velocity = direction * host.stats.move_speed
