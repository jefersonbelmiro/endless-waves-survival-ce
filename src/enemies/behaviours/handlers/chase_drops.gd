extends Behaviour
class_name ChaseDropsBehaviour

var find_diretion_cooldown: float = 1.2
var find_diretion_timer: float = 0
var drop_target

func _init():
	group_id = "move"


func _process(delta):
	if disabled || !host.is_alive():
		return

	find_diretion_timer += delta
	if find_diretion_timer > find_diretion_cooldown:
		find_diretion_timer = 0

		if host.state == host.STATES.IDLE:
			# find target
			if !is_instance_valid(drop_target):
				drop_target = _get_closest_target()
			# get random direction
			if !drop_target:
				host.direction = _get_random_direction()

		# walk state with invalid drop
		elif !is_instance_valid(drop_target):
			drop_target = null
			host.direction = Vector2.ZERO

	if is_instance_valid(drop_target):
		var dist = drop_target.global_position - host.global_position
		# @FIXME maybe use stats.pick_area 
		if dist.length() < 10:
			host.pick(drop_target)
			drop_target.queue_free()
			drop_target = null
			host.direction = Vector2.ZERO
		else:
			host.direction = dist.normalized()

	if host.direction:
		host.state = host.STATES.WALK
		host.velocity = host.direction * host.stats.move_speed
	else:
		host.state = host.STATES.IDLE
		host.velocity = Vector2.ZERO


func _get_random_direction():
	return Vector2(180, 0).rotated(deg2rad(randi() % 360)).normalized()
	

func _get_closest_target():
	var current_target = null
	var current_dist = 9999
	var drop_nodes = host.get_tree().get_nodes_in_group("drops")
	for index in drop_nodes.size():
		var node = drop_nodes[index]
		if !is_instance_valid(node):
			continue
		if node.id == 'chest':
			continue
		var dist = host.global_position.distance_to(node.global_position)
		if current_dist > dist:
			current_dist = dist
			current_target = node
	return current_target

