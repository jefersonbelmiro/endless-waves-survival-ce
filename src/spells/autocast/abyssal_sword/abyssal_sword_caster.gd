extends BaseCaster

const scene = preload("res://src/spells/autocast/abyssal_sword/abyssal_sword.tscn")
var aspd_ellapsed: float = 0
var target
var backwards = false
var final_scale: Vector2
var hit_box_position: Vector2
var area_range: float

func _process(delta: float):
	if !can_cast():
		return

	if aspd_ellapsed >= get_attack_speed_time(): 
		_calcule_attack_area()
		_get_target()
		if _cast():
			aspd_ellapsed = 0
	aspd_ellapsed += delta


func _cast():
	if Global.map.safe_zone:
		return false
	if !is_instance_valid(target):
		return
	var node = scene.instance()
	var direction = _get_aim_direction()
	node.caster = self
	node.final_scale = final_scale
	node.rotation = direction.angle()
	node.direction = direction
	node.backwards = backwards
	backwards = !backwards
	Global.add_entity(node)
	SFX.add_fast_sword()
	return true


func _calcule_attack_area():
	var area = data.get_area() 
	var initial_factor = 0.75
	var initial_area = 20
	final_scale = FP.calculate_scale_from_area(area, initial_area, initial_factor) 
	var target_position: Vector2
	if !is_instance_valid(target):
		target_position = invoker.global_position + invoker.direction * data.get_area() / 2.0
	else:
		target_position = target.global_position
	var direction: Vector2
	if Settings.get_aim_mode() == 'auto':
		direction = invoker.global_position.direction_to(target_position)
	else:
		direction = invoker.input_controller.aim_direction
	hit_box_position = invoker.global_position + direction * final_scale.x * 10
	area_range = data.get_area() + (direction * final_scale.x * 10).length() * 2


func _get_target():
	if _target_in_area_range():
		return
	if Settings.get_aim_mode() == 'auto':
		target = invoker.get_closest_target_area(area_range, [], invoker.global_position)
	else:
		target = invoker.get_closest_target_area(data.get_area(), [], hit_box_position)


func _target_in_area_range():
	if !is_instance_valid(target):
		return false
	if Settings.get_aim_mode() == 'auto':
		return Targets.in_area(target, invoker.global_position, area_range)
	else:
		return Targets.in_area(target, hit_box_position, data.get_area())


func _get_aim_direction():
	if Settings.get_aim_mode() == 'auto':
		return invoker.global_position.direction_to(target.global_position)
	return invoker.input_controller.aim_direction

