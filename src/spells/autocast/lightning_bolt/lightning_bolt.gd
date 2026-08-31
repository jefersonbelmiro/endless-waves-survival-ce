extends Node2D

const sfx_stream = preload("res://src/spells/autocast/lightning_bolt/sfx/sfx_lightning_bolt.wav")

var target: Node2D
var caster: BaseCaster

onready var animated_sprite = $animated_sprite
onready var glow = $glow

func _ready():
	randomize()
	animated_sprite.flip_h = randi() % 101 >= 50
	animated_sprite.play()

	get_tree().create_timer(0.2, false).connect("timeout", self, "_strike")

	if Settings.get_glow_effect():
		glow.show()

func _process(_delta):
	if is_instance_valid(target):
		global_position = target.global_position


func _strike():
	SFX.add({ id = "lightning_bolt", stream = sfx_stream, size = 3, random_pitch = true, ref_node = self })
	
	var data = caster.get_data()
	if 'area' in data && data.area:
		Global.add_hit_box_area_from_source(self)
	elif is_instance_valid(target):
		var area_obj = target.hurt_box
		var hit_data = {
			source_id = data.id,
			source_node = caster.invoker,
			target_node = area_obj.get_parent(),
			damage_type = data.damage_type,
			base_damage_factor = data.base_damage_factor,
			position = global_position,
		}
		hit_data = caster.invoker.stats.hit(hit_data)
		area_obj.hitted(hit_data)


func _on_animated_sprite_animation_finished():
	queue_free()
