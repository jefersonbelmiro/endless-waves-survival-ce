extends Area2D

export(NodePath) var sprite_path

var _size: int = 0
var _sprite


func _ready():
	_sprite = get_node(sprite_path)


func _update_transparency():
	if _size > 0:
		_sprite.modulate.a = 0.75
	else:
		_sprite.modulate.a = 1.0


func _on_overlap_transparency_body_entered(_body):
	_size += 1
	_update_transparency()


func _on_overlap_transparency_body_exited(_body):
	_size -= 1
	_update_transparency()
