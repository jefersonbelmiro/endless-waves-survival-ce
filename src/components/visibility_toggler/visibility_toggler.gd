extends Node2D

var viewport_size: Vector2

func _ready():
	get_tree().get_root().connect("size_changed", self, "_on_size_changed")
	viewport_size = get_viewport_rect().size + Vector2(50, 50)


func _process(_delta):
	var bounds = Rect2(Global.player.global_position - viewport_size/2.0, viewport_size)
	for index in Global.entity_container.get_child_count():
		var node = Global.entity_container.get_child(index)
		if !is_instance_valid(node) || node == Global.player:
			continue
		node.visible = bounds.has_point(node.global_position)

func _on_size_changed():
	viewport_size = get_viewport_rect().size + Vector2(20, 20)



