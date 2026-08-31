extends Node2D

var caster: BaseCaster
var direction: Vector2
var area: float = 64
var initial_area: float = 64
var initial_factor: float = 2

onready var sprite = $sprite


func _ready():
	sprite.flip_h = randf() > 0.5
	sprite.flip_v = randf() > 0.5
	sprite.rotation_degrees = rand_range(0, 380)

	sprite.scale = FP.calculate_scale_from_area(area, initial_area, initial_factor) 

	sprite.play("attack")
	Global.add_hit_box_area_from_source(self)


func _on_sprite_animation_finished():
	queue_free()
