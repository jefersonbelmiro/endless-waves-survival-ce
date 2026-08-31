extends Popup

onready var tabs = $tabs_container/tabs

func _ready():
	Global.theme_bg($bg)


func open():
	Global.opened_popups_add(self, { popup_tween_finished_func_ref = funcref(self, "_on_popup_tween_finished") })
	popup()


func _on_back_button_pressed():
	hide()


func _on_help_popup_hide():
	Global.opened_popups_remove(self)


func _on_popup_tween_finished():
	tabs._fix_input_icon_positions()
