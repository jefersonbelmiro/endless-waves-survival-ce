extends Node2D

const impact_sfx = preload("res://src/spells/ultimate/sun_strike/sfx/impact_sfx.wav")
const cast_sfx = preload("res://src/spells/ultimate/sun_strike/sfx/cast_sfx.wav")

var target: Node2D
var caster: BaseCaster

onready var sprite = $animated_sprite


func _ready():
	sprite.play()
	SFX.add({ id = "sun_strike_cast", stream = cast_sfx, size = 1, volume = -10, ref_node = self})
	
	
func _process(_delta):
	if is_instance_valid(target):
		global_position = target.global_position
	
	
func _on_animated_sprite_animation_finished():
	Global.add_hit_box_area_from_source(self)
	Global.add_floor_hit_effect(global_position, caster.get_data().get_area(), Color("#b33831"))
	sprite.hide()
	SFX.add({ 
		id = "sun_strike_inpact", 
		stream = impact_sfx, 
		size = 3,
		random_pitch = true,
		ref_node = self,
	})
	queue_free()
