extends Control
class_name Toast

enum { TYPE_INFO, TYPE_ERROR, TYPE_WARN }

export var text: String setget set_text
export var timeout = 2
export var type = TYPE_INFO

onready var label = $container/label
onready var label_font = label.get_font("font")
onready var min_width = rect_size.x
onready var min_height = rect_size.y

var mark_for_destroy = false
var position_anim_duration = 0.3 
var phade_anim_duration = 0.5 
var tween

func _ready():
	label.bbcode_text = text
	
	if type == TYPE_ERROR:
		$container/color_rect.color = Color('#b4cc7171')
	elif type == TYPE_WARN:
		$container/color_rect.color = Color('#b44e4f35')
	
	_update_size()

	modulate.a = 0
	$container.rect_position = Vector2(-rect_size.x - 10, 0)

	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_parallel()
	tween.tween_property($container, "rect_position", Vector2.ZERO, position_anim_duration)
	tween.tween_property(self, "modulate:a", 1.0, phade_anim_duration)

	$timeout_timer.start(timeout)


func destroy():
	mark_for_destroy = true
	if tween && tween.is_running():
		tween.kill()

	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_parallel()
	tween.tween_property($container, "rect_position", Vector2(-rect_size.x - 10, 0), position_anim_duration)
	tween.tween_property(self, "modulate:a", 0.5, phade_anim_duration)
	tween.connect("finished", self, "queue_free")


func set_text(value: String):
	text = value
	if label:
		label.text = text
		_update_size()
	

# @TODO add wrap option using label.get_line_count() * label.get_line_height()
func _update_size():
	var size = label_font.get_string_size(label.text)
	var width = size.x + 10
	var height = size.y
	rect_min_size = Vector2(max(min_width, width), max(min_height, height))


func _on_timeout_timer_timeout():
	if !mark_for_destroy && is_instance_valid(self):
		destroy()
