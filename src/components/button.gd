extends Button

export var label: String
export var label_color = Color('#ffffff')
export var selected_color = Color('#ffffff')
export var background: Color = Color('#640083')
	
func _ready():
	if label:
		$label.text = label
	if text:
		$text_label.text = text
	if icon:
		$texture_rect.texture = icon
	
	$selected.modulate = selected_color
	$bg.color = background
	$label.set('custom_colors/font_color', label_color)
	$text_label.set('custom_colors/font_color', label_color)
		
		
func _draw():
	if disabled:
		$text_label.modulate = Color(1, 1, 1, 0.2)
	else:
		$text_label.modulate = Color(1, 1, 1, 1)
	$text_label.text = text


func _on_button_focus_entered():
	$selected.show()


func _on_button_focus_exited():
	$selected.hide()

