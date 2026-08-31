extends Area2D

onready var collision_shape_2d = get_node('collision_shape_2d')

var push_vector = Vector2.ZERO

func get_push_vector():
	if collision_shape_2d.disabled:
		push_vector = lerp(push_vector, Vector2.ZERO, 0.1)
		return push_vector
	var areas = get_overlapping_areas()
	if areas.size() > 0:
		push_vector = Vector2.ZERO
		for index in range(0, areas.size()):
			var area = areas[index]
			push_vector += (global_position - area.global_position).normalized()
		collision_shape_2d.set_deferred('disabled', true)
		$cooldown_timer.start(300 / areas.size() / 1000)
	return push_vector


# @FIXME unused
func get_avoidance():
	var avoidance = Vector2.ZERO
	var areas = get_overlapping_areas()
	var count = 0
	for area in areas:
		avoidance += (global_position - area.global_position).normalized()
		count += 1
	if count > 0:
		avoidance = (avoidance / count).normalized()
	return avoidance


func _on_cooldown_timer_timeout():
	push_vector = Vector2.ZERO
	collision_shape_2d.set_deferred('disabled', false)
