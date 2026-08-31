extends Behaviour
class_name ShieldFormationBehaviour

var target: Node2D
var target_position: Vector2
var target_distance: Vector2
var move_speed: float = 150
var threshold: float = 5
var keep_formation = true

var _in_formation = false

func _init():
	group_id = "move"


func _ready():
	execute()


func _process(_delta):
	if disabled || (!target && !target_position) || host.is_disabled():
		return

	if is_instance_valid(target):
		target_position = target.global_position + target_distance

	var distance = target_position - host.global_position

	if distance.length() < threshold:
		host.velocity = Vector2.ZERO
		if keep_formation && !_in_formation:
			_in_formation = true
			host.collision.set_deferred('disabled', false)
			host.stats.remove_modifier("buff_shield_formation")
		elif !keep_formation:
			container.remove(id)
	else:
		host.direction = distance.normalized() 
		host.velocity = host.direction * host.stats.move_speed  
	

func execute():
	host.collision.set_deferred('disabled', true)
	disable_others_in_group()

	# add buff and set max move_speed ignore others buffs and update walk speed
	var buff_move_speed = host.stats.move_speed + move_speed - host.stats.move_speed  
	host.stats.add_modifier({ 'id': 'buff_shield_formation', move_speed = buff_move_speed })


func _exit_tree():
	host.stats.remove_modifier("buff_shield_formation")
	host.collision.set_deferred('disabled', false)
	container.enable_group("move")

