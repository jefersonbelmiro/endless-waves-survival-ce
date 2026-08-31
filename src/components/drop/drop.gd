extends Area2D

export var id: String

var data

var picker: Node2D
var max_speed = 300
var value = 1
var group_size = 1 setget set_group_size

var force = 1.0
var target_position: Vector2
var _launch_gravity: float
var _move_z = 0
var _landed = false
var _velocity = Vector2()
var _shadow_velocity: Vector2
var _shadow_start_poition: Vector2
var _spawn_ticks = 30

var _try_avoid_collision = false

onready var sprite = $sprite
onready var shadow = $shadow
onready var group_size_label = $group_size_label


func _ready():
	if _try_avoid_collision:
		var drops_nodes = get_tree().get_nodes_in_group("drops")
		for index in drops_nodes.size():
			var node =  drops_nodes[index]
			if node.picker || node == self:
				continue
			
			var distance = global_position.distance_to(node.global_position)
			if node.id == id:
				if distance < 50:
					if 'value' in data && 'value' in node:
						node.value += data.value
					node.group_size += 1
					queue_free()
					return
				continue
			
			if distance < 20:
				global_position += Vector2(rand_range(10, 30), rand_range(10, 30))
	else:
		var group_nodes = get_tree().get_nodes_in_group(id)
		for index in group_nodes.size():
			var node =  group_nodes[index]
			if node.picker || node == self:
				continue
			var distance = global_position.distance_to(node.global_position)
			if distance < 50:
				if 'value' in data && 'value' in node:
					node.value += data.value
				node.group_size += 1
				queue_free()
				return
				
	if 'texture' in data:
		sprite.texture = data.texture
	if 'value' in data:
		value = data.value
	if 'group' in data:
		add_to_group(data.group)
		add_to_group(data.id)

	set_physics_process(false)

	# @FIXME
	if id == 'coin' || id == 'experience':
		sprite.scale = Vector2(0.8, 0.8)
	elif id == 'chest':
		sprite.scale = Vector2(0.5, 0.5)
		shadow.position = Vector2(0, 4)
		shadow.scale = Vector2(0.391, 0.289)
		shadow.show()
	elif id.ends_with("_scroll"):
		sprite.scale = Vector2(0.35, 0.35)
		shadow.position = Vector2(-0.5, 3)
		shadow.scale = Vector2(0.7, 1)
		shadow.show()
	else:
		sprite.scale = Vector2(0.35, 0.35)
		shadow.position = Vector2(0, 4)
		shadow.scale = Vector2(0.7, 1)
		shadow.show()

	# if id == 'chest':
	# 	z_index = 3
	# elif id.begins_with('consumable'):
	# 	z_index = 2

	if target_position:
		var direction = target_position - global_position
		var speed = direction.length() 

		_velocity = direction.normalized() * speed

		_move_z = force * 100
		_launch_gravity = _move_z
		_velocity.y -= _move_z / 2
	
		_shadow_velocity = direction.normalized() * direction.length()
		_shadow_start_poition = shadow.position
		shadow.set_as_toplevel(true)
		shadow.global_position = global_position + _shadow_start_poition
	

func _physics_process(delta):
	if !target_position:
		if !is_instance_valid(picker) || !picker.is_alive():
			return
		var direction = (picker.global_position - global_position).normalized()
		global_position += direction * max_speed * delta

	elif !_landed:
		_move_z -= _launch_gravity * delta
		_velocity.y += _launch_gravity * delta 
		global_position += _velocity * delta
		shadow.global_position += _shadow_velocity * delta

		if _move_z <= 0:
			_landed = true
			global_position = target_position
			shadow.set_as_toplevel(false)
			shadow.position = _shadow_start_poition


func set_group_size(value_: int):
	group_size = value_
	if group_size > 1:
		group_size_label.text = str(group_size)
		group_size_label.show()
#		if id == 'coin':
#			sprite.texture = Global.coins_texture 
#		elif id == 'experience':
#			sprite.texture = Global.experiences_texture 
			

func set_picker(node: Node2D, move_speed_factor = 1.7):
	if id == 'chest':
		return
	picker = node
	max_speed = picker.stats.move_speed * move_speed_factor
	call_deferred('set_physics_process', true)


func set_target_position(position: Vector2):
	target_position = position
	call_deferred('set_physics_process', true)


func _on_drop_area_entered(area):
	if is_instance_valid(picker):
		return
	set_picker(area.get_parent())


func _on_drop_body_entered(body):
	if !body.is_alive():
		return
	if id == 'experience':
		var exp_value = value + (value * Global.player.stats.experience_factor)
		body.add_experience(exp_value)
		SFX.add_experience()
	elif id == 'coin':
		var coin_value = value + (value * Global.player.stats.collect_coin_factor)
		body.add_coins(coin_value * group_size)
		SFX.add_coin()
	elif id == 'chest':
		Global.emit_signal("chest_collected", value)
	elif id.begins_with('consumable'):
		for _i in group_size:
			Global.player.backpack.add(id)
		SFX.add_experience()
		# body.add_consumable(Entities.create_consumable_data(id))
		# Global.add_toast(tr(body.stats.modifiers.get(id).format_toast_used()))
		# SFX.add_consumable(id)
	else:
		push_error("Invalid drop id: " + id)
	queue_free()

