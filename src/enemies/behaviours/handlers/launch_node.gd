extends Behaviour
class_name LauchNodeBehaviour

var attack_cooldown: float = 2.0
var attack_timer: float = 0
var proc_chance: float = 0.8
var target_position: Vector2
var force: float = 5.0


func _init():
	group_id = "attack"


func _ready():
	host.collision.set_deferred('disabled', true)
	host.hurt_box_collision.set_deferred('disabled', true)
	host.behaviour_container.disable_group("move")
	host.behaviour_container.disable_group("attack")

	var trail = Global.trail_effect_scene.instance()
	trail.width = 16
	trail.modulate = host.base_color
	host.add_child(trail)
	host.move_child(trail, 0)

	var target_marker = Global.add_danger_target_marker(target_position, 24)

	host.state = host.STATES.SPAWNING
	host.sprite.stop()
	host.sprite.frame = 0
	host.shadow.hide()
	var jump_behavior = container.add("jump", { target_position = target_position, force = force })
	jump_behavior.connect("landed", self, "_on_jump_compled", [trail, target_marker])


func _on_jump_compled(trail, target_marker):
	trail.queue_free()
	target_marker.queue_free()

	host.state = host.STATES.IDLE
	host.shadow.show()
	host.collision.set_deferred('disabled', false)
	host.hurt_box_collision.set_deferred('disabled', false)
	host.behaviour_container.enable_group("move")
	host.behaviour_container.enable_group("attack")
