extends "res://test/framework/test.gd"


func title():
	return "Event system"


func test_min_max_size():
	# var event = {
	# 	type = "spawn", start = 3, interval = 3,
	# 	data = {
	# 		min_enemies_alive = 8,
	# 		max_enemies_alive = 10,
	# 		spawn_mode = "map_bounds",
	# 		spawns = [{ id = "jelly", size = 1 }],
	# 	}
	# }
	var result = _calculate_spawn_size(5, 8, 12, 2)

	assert_eq(result, 6)
	


func _calculate_spawn_size(spawn_size, event_min_enemies_alive, event_max_enemies_alive, current_enemies_alive):
	var min_size = event_min_enemies_alive - current_enemies_alive
	var max_size = event_max_enemies_alive - current_enemies_alive
	spawn_size = clamp(spawn_size, min_size, max_size)

	return spawn_size
