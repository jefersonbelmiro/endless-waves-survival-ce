extends Behaviour
class_name ContextSteeringBehaviour

# experimental code
# i have no idea what i'm doing

var steer_force = 5.0
var look_ahead = 40
var visible_angle = 120
var num_rays = 6
var tick_rate = 15 
var target
var use_acceleration = false
var collision_mask_exclude_host = true
var keep_distance = 0
var keep_looking_at_target = false

# context array
var ray_directions = []
var interest = []
var danger = []

var chosen_dir = Vector2.ZERO
var collision_mask = null
var adjust_angle: float
var angle_step: float

var velocity: Vector2
var direction: Vector2

var show_debug = false

var _collision_mask: int
var _acceleration: Vector2
var _random_interest = -1
var _random_interest_tick = 0
var _random_interest_ticks = 60

func _init():
	group_id = "move"


func _ready():
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)

	# cast: sometimes json parse can convert int to float
	tick_rate = int(tick_rate)
	num_rays = int(num_rays)

	var visible_radians = deg2rad(visible_angle)
	angle_step = visible_radians/num_rays
	adjust_angle = -(visible_radians * 0.5 - angle_step/2)

	for index in num_rays:
		ray_directions[index] = Vector2.RIGHT.rotated(index * angle_step + adjust_angle)

	if collision_mask != null:
		_collision_mask = Global.get_collision_layer_bits(collision_mask) 
	else:
		_collision_mask = host.collision_mask

	# debug ray casts
	if show_debug:
		creat_debug_draw()


func _process(delta):
	target = host.get_target()
	if disabled || !is_instance_valid(target) || !target.is_alive() || host.is_disabled():
		return

	if host.get_tree().get_frame() % tick_rate == 0:
		var chosen_rotation = velocity.angle()
		for index in num_rays:
			ray_directions[index] = Vector2.RIGHT.rotated(index * angle_step + adjust_angle).rotated(chosen_rotation)
		set_interest()
		set_danger()
		choose_direction()

	if use_acceleration:
		var desired = chosen_dir * host.stats.move_speed
		var steer =  (desired - velocity).normalized() * steer_force

		_acceleration += steer * delta
		velocity += _acceleration
		velocity = velocity.limit_length(host.stats.move_speed)
	else:
		var desired_velocity = chosen_dir * host.stats.move_speed
		velocity = velocity.linear_interpolate(desired_velocity, steer_force * delta)

	host.velocity = velocity
	if keep_looking_at_target:
		host.direction = (target.global_position - host.global_position).normalized()
	else:
		host.direction = velocity.normalized() 


func set_interest():
	var target_distance = target.global_position - host.global_position
	var target_distance_normal = target_distance.normalized()
	if keep_distance && target_distance.length() <= keep_distance:
		target_distance_normal *= -1
	for index in num_rays:
		var d = ray_directions[index].dot(target_distance_normal)
		interest[index] = max(0, d)

	# dot product zero, chose random interest direction
	if interest.max() == 0:
		if _random_interest == -1 || _random_interest_tick >= _random_interest_ticks:
			_random_interest_tick = 0
			_random_interest = randi() % num_rays
		interest[_random_interest] = 0.1
		_random_interest_tick += 1
		# for index in num_rays:
		# 	interest[index] = 0.1


func set_danger():
	# Cast rays to find danger directions
	var space_state = host.get_world_2d().direct_space_state
	for index in num_rays:
		var exclude = [host] if collision_mask_exclude_host else []
		var result = space_state.intersect_ray(
			host.global_position,
			host.global_position + ray_directions[index] * look_ahead,
			exclude,
			_collision_mask
		)
		danger[index] = 0
		if result:
			var weight = 1.0
			if result.collider ==  host:
				weight = 1.0
			elif result.collider.is_in_group("walls"):
				weight = 2.0
			elif result.collider.is_in_group("enemies"):
				weight = 1.0
			danger[index] = weight - (host.global_position - result.position).length() / look_ahead  


func choose_direction():
	var _chosen_dir = Vector2.ZERO
	for index in num_rays:
		if danger[index] > 0:
			_chosen_dir -= ray_directions[index] * danger[index]
		if interest[index] > 0:
			_chosen_dir += ray_directions[index] * interest[index]
	chosen_dir = _chosen_dir.normalized()


func _draw(node: Node2D):
	var position = node.to_local(host.global_position)
	var font = Global.get_font(8)
	node.draw_line(position, position + chosen_dir * look_ahead, Color(0,0,255), 1)

	for index in num_rays:
		if danger[index] && danger[index] > 0.0:
			node.draw_line(position, (position + ray_directions[index] * look_ahead * interest[index]), Color(255, 0, 0), 1)
			node.draw_string(font, (position + ray_directions[index] * look_ahead), "%.2f" % [danger[index]], Color(255, 0, 0))
			continue
		if interest[index] && interest[index] > 0.0:
			node.draw_line(position, (position + ray_directions[index] * look_ahead * interest[index]), Color(0, 255, 0), 1)
			node.draw_string(font, (position + ray_directions[index] * look_ahead), "%.2f" % [interest[index]], Color(0, 255, 0))
			continue
		node.draw_line(position, position + ray_directions[index] * look_ahead, Color(255, 255, 255), 1)


func creat_debug_draw():
	var command_handler_scene = load("res://src/debug/popup/debug_console/command_handler/console_command_handler.tscn")
	var node = command_handler_scene.instance()
	node.draw_handler = funcref(self, '_draw')
	host.add_child(node)
	

