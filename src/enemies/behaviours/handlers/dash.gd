extends Behaviour
class_name DashBehaviour

var duration := 0.2
var move_speed := 450.0
var executing := false

var _elapsed := 0.0
var _ghost_timer: Timer

func _init():
	group_id = "move"


func _ready():
	_ghost_timer = Global.create_timer({
		parent = host,
		wait_time = 0.05,
		on_timeout = [self, "_on_ghost_timer_timeout"]
	})


func _process(delta: float):
	if disabled || host.is_disabled():
		return

	if executing:
		if _elapsed > duration:
			_elapsed = 0.0
			_on_finished()
		_elapsed += delta


func execute():
	if disabled || host.is_disabled():
		return
	executing = true
	host.stats.add_modifier({ id = id, move_speed = move_speed })
	host.sprite.modulate = Color(0, 0, 0, 0.5)
	SFX.add_dash({ ref_node = host })
	_ghost_timer.start()


func _on_ghost_timer_timeout():
	_create_ghost()


func _create_ghost():
	var node = AnimatedSprite.new()
	node.scale = host.sprite.scale
	node.modulate = Color.black #host.base_color + Color(-0.2, -0.2, -0.2) #Color('#261232')
	node.global_position = host.global_position
	node.frames = host.sprite.frames
	node.animation = host.sprite.animation
	node.frame = host.sprite.frame
	node.flip_h = host.sprite.flip_h
	node.flip_v = host.sprite.flip_v
	Global.game.add_child(node)
	var tween = node.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property(node, 'modulate:a', 0.0, 0.5)
	tween.connect("finished", node, 'queue_free')


func _on_finished():
	executing = false
	host.stats.remove_modifier(id)
	host.sprite.modulate = Color(1, 1, 1)
	_ghost_timer.stop()


