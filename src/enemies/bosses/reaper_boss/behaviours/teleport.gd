extends Behaviour

var cooldown: float = 3.0
var proc_chance: float = 0.9
var health_lost = 500
var min_distance = 300
var check_map_bounds = false

var _timer: float = 0
var _current_health := 0
var _health_losted := 0
var _allow_execute := false
var _handler: Behaviour


func _init():
	group_id = "move"


func _ready():
	randomize()
	_handler = container.get('teleport')
	_current_health = host.stats.current_health
	host.stats.connect("health_changed", self, "_on_health_changed")


func _process(delta):
	if disabled || host.is_disabled() || !host.is_alive():
		_timer = 0
		return

	if _allow_execute && _health_losted >= health_lost:
		_execute(100, 120)
		_health_losted = 0

	if _allow_execute:
		var distance = Global.player.global_position - host.global_position
		if distance.length() > min_distance:
			_execute(50, 80)

	if !_allow_execute:
		_timer += delta
		if _timer > cooldown:
			if proc_chance >= 1 || rand_range(0, 1) <= proc_chance:
				_allow_execute = true
			_timer = 0


func _execute(min_dist = 80, max_dist = 80):
	if _handler.executing:
		return
	_allow_execute = false
	var target_position: Vector2
	if check_map_bounds:
		target_position = Global.map.get_random_position_circle_bounds(
			Global.player.global_position,
			rand_range(min_dist, max_dist)
		)
	else:
		var positions = Global.map.get_positions_circle(
			Global.player.global_position,
			1,
			randi() % max_dist + min_dist,
			rand_range(0, 360),
			check_map_bounds
		)
		if positions.size():
			target_position = positions[0]
	if target_position:
		_handler.target_position = target_position
		_handler.execute()


func _on_health_changed():
	var diff = _current_health - host.stats.current_health
	_health_losted += diff
	_current_health = host.stats.current_health 


