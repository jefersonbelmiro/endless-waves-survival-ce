extends Behaviour
class_name TeleportBehaviour

var target_position: Vector2
var auto_execute = false
var once = false
var executing = false

var _tween_duration = 0.5
var _initial_scale: Vector2
var _initial_alpha: float


func _init():
	group_id = "move"


func _ready():
	if auto_execute:
		execute()


func execute():
	if executing: 
		return
	executing = true
	host.collision.set_deferred("disabled", true)
	host.hurt_box_collision.set_deferred("disabled", true)
	disable_others_in_group()
	container.disable_group("attack")

	_initial_scale = host.scale
	_initial_alpha = host.modulate.a

	host.velocity = Vector2.ZERO

	Global.delay_func(self, '_create_teleport_effect', 0.1)

	var tween = host.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel(true)
	tween.tween_property(host, 'scale', host.scale + Vector2(-0.5, 1.0), _tween_duration)
	tween.tween_property(host, 'modulate:a', 0.0, _tween_duration)
	tween.connect("finished", self, "_on_start_tween_finished")
	SFX.add_teleport_start({ ref_node = host })


func _create_teleport_effect():
	var effect = Global.teleport_effect_scene.instance()
	effect.global_position = host.global_position
	effect.modulate = host.base_color + Color(0.1, 0.1, 0.1, -0.3)
	Global.game.add_child(effect)


func _on_start_tween_finished():
	host.global_position = target_position
	var tween = host.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel(true)
	tween.tween_property(host, 'scale', _initial_scale, _tween_duration)
	tween.tween_property(host, 'modulate:a', _initial_alpha, _tween_duration)
	tween.connect("finished", self, "_on_finished")
	SFX.add_teleport_end({ ref_node = host })


func _on_finished():
	executing = false
	enable_others_in_group()
	container.enable_group("attack")
	if once:
		container.remove(id)
	host.collision.set_deferred("disabled", false)
	host.hurt_box_collision.set_deferred("disabled", false)



