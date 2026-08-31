extends Behaviour
class_name FallingBehaviour

var falling_force = 0
var falling_direction = Vector2.ZERO

func _init():
	group_id = "debuff"


func _ready():
	container.disable_group("move")
	host.state = host.STATES.DEAD


func _process(_delta):
	if disabled:
		return

	host.velocity = falling_direction * falling_force
	host.sprite.scale = host.sprite.scale.linear_interpolate(Vector2(0, 0), 0.01)

	falling_force = lerp(falling_force, 0, 0.1)
	if falling_force < 1:
		host.queue_free()

