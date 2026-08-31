extends Area2D


func _on_abysm_area_area_shape_entered(_area_rid, area, _area_shape_index, local_shape_index):
	var collision_shape = shape_owner_get_owner(local_shape_index)
	var area_parent = area.get_parent()

	if area_parent.is_in_group("bosses") || area_parent.is_in_group("flyers"):
		return

	if !'behaviour_container' in area_parent:
		return push_error("invalid area entered: "+ area_parent.get_path())

	var data = { falling_direction = Vector2.DOWN.rotated(collision_shape.rotation), falling_force = 250 }
	area_parent.behaviour_container.add("falling", data)
