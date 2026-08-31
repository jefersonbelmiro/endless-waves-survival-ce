extends "res://src/components/hud_slot/hud_slot.gd"

export var card_id: String
export var action_name: String setget set_action_name

var ult_default_texture = preload("res://assets/components/border_box_dark_bg.png")
var ult_avaliable_texture = preload("res://assets/components/hud_slot_green_bg.png")

onready var input_icon = $input_icon

func _ready():
	if Global.is_mobile():
		rect_min_size = Vector2(64, 64)
		$touch_screen_button.shape.extents = Vector2(32, 32)
		self.font_size = 32
		label.set_anchors_and_margins_preset(PRESET_WIDE)
		label.align = label.ALIGN_RIGHT
		label.margin_left = 40
		label.margin_top = 45
		input_icon.queue_free()
	else:
		input_icon.action_name = action_name


func set_action_name(value):
	action_name = value
	if input_icon && !Global.is_mobile(): 
		input_icon.action_name = action_name


func _on_cooldown_value_changed(value):
	if value <= 0:
		texture = ult_avaliable_texture
	else:
		texture = ult_default_texture


func _on_touch_screen_button_pressed():
	var caster = Global.player.spells[card_id]
	caster.cast()
