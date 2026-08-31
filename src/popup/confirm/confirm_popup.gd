extends Popup

signal confirmed()

export var label_text: String
export var container_size: Vector2

var paused = false

onready var container = $container
onready var label = $container/content/label


func _ready():
	label.bbcode_text = "[center]%s[/center]" % [tr(label_text)]
	if container_size:
		container.rect_min_size = container_size
		container.set_anchors_and_margins_preset(Control.PRESET_CENTER)
		container.rect_position = container.rect_size / 2

	_on_language_changed()
	Settings.connect("language_changed", self, "_on_language_changed")

	Global.theme_bg_overlay($bg)
	Global.theme_bg($container/bg_color)
	Global.theme_panel_border($container/bg_border)
	

func open():
	paused = get_tree().paused
	Global.set_paused(true)
	Global.opened_popups_add(self, { popup_tween = false })
	popup()


func _on_confirm_button_pressed():
	emit_signal("confirmed")
	hide()


func _on_cancel_button_pressed():
	hide()


func _on_confirm_popup_hide():
	Global.opened_popups_remove(self)
	if !paused:
		Global.set_paused(false)
	queue_free()

func _on_language_changed():
	# update translation
	label.bbcode_text = "[center]%s[/center]" % [tr(label_text)]
	label.set('custom_fonts/normal_font', Global.get_font(16)) 


