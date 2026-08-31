extends Behaviour
class_name AbsorbAndThrowBehaviour

var target_id: String
var size = 5
var cooldown: float = 5.0
var proc_chance: float = 0.8
var move_speed: float = 150

var _launch_attack
var _timer: float = 0
var _targets = []


func _init():
	group_id = "attack"


func _ready():
	_launch_attack = container.get('launch_attack')
	if !_launch_attack:
		return push_error("host dont have launch_attack behaviour")
	_launch_attack.auto_attack = false


func _process(delta):
	if disabled || !Global.player.is_alive():
		return

	_timer += delta
	if _timer > cooldown:
		_timer = 0
		if proc_chance >= 1 || rand_range(0, 1) <= proc_chance:
			_execute()


func _execute():
	var nodes = host.get_tree().get_nodes_in_group("enemies")

	_targets = []
	for index in nodes.size():
		var node = nodes[index]
		if !is_instance_valid(node) || node == host || !node.is_alive() || node.is_disabled():
			continue
		if target_id && node.id != target_id:
			continue
		if node.stats.modifiers.has("buff_absorb_and_throw"):
			continue

		node.collision.set_deferred('disabled', true)
		# add buff and set max move_speed ignore others buffs and update walk speed
		var buff_move_speed = node.stats.move_speed + move_speed - node.stats.move_speed  
		node.stats.add_modifier({ 'id': 'buff_absorb_and_throw', move_speed = buff_move_speed })

		node.behaviour_container.disable_group("move")
		var behavior = node.behaviour_container.add("move_to_position", { target = host, threshold = 20, disabled = false  })
		behavior.connect("moved", self, "_node_moved")
		behavior.connect("moved", node, "queue_free")

		_targets.append(node)
		if _targets.size() >= size:
			break

	# dont have enouth jellies, throw remain
	for _index in range(_targets.size(), size):
		_node_moved()


func _node_moved():
	_launch_attack.attack(Global.map.get_random_position_bounds())
	SFX.add_jump({ ref_node = host })


func _exit_tree():
	for index in _targets.size():
		var node = _targets[index]
		if !is_instance_valid(node) || !node.is_alive():
			continue
		node.behaviour_container.remove("move_to_position")
