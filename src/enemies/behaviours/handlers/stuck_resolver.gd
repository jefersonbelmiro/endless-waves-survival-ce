extends Behaviour
class_name StuckResolverBehaviour

var move_check_elapsed := 0.0
var move_check_delay := 2.0
var move_min_distance := 100.0
var move_distance := 0.0
var last_position: Vector2


func _ready():
	host.stats.connect("modifier_added", self, "_sync_stats_update")
	host.stats.connect("modifier_removed", self, "_sync_stats_update")
	_sync_stats_update(null)


func _process(delta):
	if disabled || !host.is_alive() || host.is_disabled():
		return

	if host.velocity:
		if host.current_move_method != 'move_increase' && move_check_elapsed > move_check_delay:
			if move_distance < move_min_distance:
				host.current_move_method = 'move_increase'
			move_check_elapsed = 0
			move_distance = 0
		elif host.current_move_method == 'move_increase' && move_check_elapsed > move_check_delay:
			host.current_move_method = host.move_method
			move_check_elapsed = 0
			move_distance = 0

		if host.current_move_method == "move_and_slide":
			move_distance += (host.velocity * delta).length()
		elif host.current_move_method == 'move_and_collide':
			move_distance += host.global_position.distance_to(last_position)

		last_position = host.global_position
		move_check_elapsed += delta
	else:
		move_distance = 0.0
		move_check_elapsed = 0.0
		host.current_move_method = host.move_method


func _sync_stats_update(_modifier_data):
	move_min_distance = host.stats.move_speed * move_check_delay
