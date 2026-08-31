extends Node2D

var caster: BaseCaster
var area: float = 64
var initial_area: float = 64
var initial_factor: float = 0.2

onready var sprite = $sprite


func _ready():
	var scale = FP.calculate_scale_from_area(area, initial_area, initial_factor)
	sprite.scale = scale + Vector2(0, -scale.y * 0.4)
	sprite.play("attack")
	Global.add_floor_hit_effect(caster.invoker.global_position, area, Color("#6a9f552d"))
	Global.add_hit_box_area_from_source(self)


func _on_sprite_animation_finished():
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT )
	tween.tween_property(sprite, 'modulate:a', 0.0, 0.50).set_delay(1.0)
	tween.connect("finished", self, "queue_free")
	
