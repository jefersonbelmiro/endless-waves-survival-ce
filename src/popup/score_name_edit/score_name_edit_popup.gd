extends Popup

signal edited(name)

export var label_text: String
export var container_size: Vector2

onready var container = $container
onready var label = $container/content/label
onready var line_edit = $container/content/control/line_edit
onready var confirm_button = $container/content/actions/confirm_button


func _ready():
	if label_text:
		label.text = label_text
	if container_size:
		container.rect_min_size = container_size
		container.set_anchors_and_margins_preset(Control.PRESET_CENTER)
		container.rect_position = container.rect_size / 2

	var score_data = Persistent.get_score_data()
	if 'user_name' in score_data && score_data.user_name:
		line_edit.text = score_data.user_name 

	_on_language_changed()
	Settings.connect("language_changed", self, "_on_language_changed")

	Global.theme_bg_overlay($bg)
	Global.theme_bg($container/bg_color)
	Global.theme_panel_border($container/bg_border)
	

func open():
	Global.opened_popups_add(self)
	popup()


func _on_confirm_button_pressed():
	var text_sanitize = line_edit.text.strip_edges()
	if text_sanitize.length():
		emit_signal("edited", text_sanitize)
	hide()


func _on_cancel_button_pressed():
	hide()


func _on_confirm_popup_hide():
	Global.opened_popups_remove(self)
	queue_free()


func _on_language_changed():
	# update translation
	if label_text:
		label.text = label_text
	label.set('custom_fonts/font', Global.get_font(16))


func _on_line_edit_text_changed(new_text):
	confirm_button.disabled = !new_text.strip_edges().length()

