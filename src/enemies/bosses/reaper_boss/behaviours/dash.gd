extends Behaviour

var proc_chance := 0.7
var health_lost := 200

var _handler: Behaviour
var _current_health := 0
var _health_losted := 0
var _direction: Vector2

func _init():
	group_id = "move"

func _ready():
	randomize()
	_handler = container.get('dash')
	_current_health = host.stats.current_health
	host.stats.connect("health_changed", self, "_on_health_changed")


func _process(_delta):
	if disabled || host.is_disabled() || !host.is_alive():
		return
	var target = host.get_target()
	if !is_instance_valid(target) || !target.is_alive():
		host.state = host.STATES.IDLE
		host.velocity = Vector2.ZERO
		return

	if !_handler.executing:
		return

	host.direction = _direction
	host.velocity = _direction * host.stats.move_speed


func _on_health_changed():
	var diff = _current_health - host.stats.current_health
	_health_losted += diff
	_current_health = host.stats.current_health 
	if _handler.executing || disabled || host.is_disabled():
		return
	if _health_losted >= health_lost:
		_execute()
		_health_losted = 0


func _execute():
	if proc_chance < 1 && rand_range(0, 1) > proc_chance:
		return

	var target = host.get_target()
	var target_direction = (target.global_position - host.global_position)
	_direction = target_direction.rotated(deg2rad(-90 if randf() >= 0.5 else 90)).normalized()
	container.disable_group("attack")
	container.disable_group("move", [id, "dash"])
	_handler.execute()
	Global.delay_func(self, '_on_finished', _handler.duration)


func _on_finished():
	container.enable_group("attack")
	container.enable_group("move", [id, "dash"])


