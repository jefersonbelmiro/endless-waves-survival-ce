extends Popup

signal changed(data)

onready var size_container = $container/content/settings/size_row/content
onready var image_container = $container/content/settings/image_row/content
onready var color_container = $container/content/settings/color_row/content
onready var preview_sprite = $container/content/preview/sprite
onready var outline_border_control = $"%outline_border_control"
onready var outline_border_inside_control = $"%outline_border_inside_control"
onready var outline_border_size_control = $"%outline_boder_size_control"
onready var done_button = $container/actions/done_button

var sizes = [12, 16, 20, 24, 28, 32]
var colors = ['#000000', '#ffffff', '#c118ea', '#184dea', '#18ea4d', '#e8ea18', '#ea3618']

var image_size = 11.0

var selected_size_index = 0
var selected_color_index = 0
var selected_image_index = 0
var outline = true
var outline_inside = false
var outline_size = 0.247


func _ready():
	Global.theme_bg($bg)
	

func open():
	popup()

	var data = Settings.get_crosshair()

	var last_size_diff = 999
	for index in sizes.size():
		var size = sizes[index]
		var scale = float(size) / image_size
		var diff = abs(scale - data.scale)
		if diff < last_size_diff:
			last_size_diff = diff 
			selected_size_index = index

	selected_color_index = colors.find(data.color)
	selected_image_index = data.image_index
	outline = data.outline
	outline_inside = data.outline_inside
	outline_size = data.outline_size

	Global.node_remove_children(size_container)
	for index in sizes.size():
		var node = Global.book_button_scene.instance()
		node.text_label = str(sizes[index])
		node.pressed_color = Color('#581358')
		node.toggle_mode = true
		node.bg_texture = null
		node.connect("pressed", self, "_on_size_button_pressed", [index])
		if index == selected_size_index:
			node.pressed = true
		size_container.add_child(node)


	Global.node_remove_children(color_container)
	for index in colors.size():
		var node = Global.book_button_scene.instance()
		node.pressed_color = Color('#581358')
		node.toggle_mode = true
		node.bg_texture = null
		node.connect("pressed", self, "_on_color_button_pressed", [index])
		if index == selected_color_index:
			node.pressed = true

		var image = ColorRect.new()
		image.color = colors[index]
		image.rect_min_size = Vector2(16, 16)
		image.rect_position = Vector2(2, 2)
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.add_child(image)
									  
		color_container.add_child(node)


	Global.node_remove_children(image_container)
	for index in range(1, 55):
		var node = Global.book_button_scene.instance()
		node.toggle_mode = true
		node.bg_texture = null
		node.pressed_color = Color('#581358')
		node.connect("pressed", self, "_on_image_button_pressed", [index])
		if index == selected_image_index:
			node.pressed = true

		var image = Sprite.new()
		image.texture = load("res://assets/input/crosshair/crosshair%s.png" % [index])
		image.scale = Vector2(1.6, 1.6)
		image.position = Vector2(10, 10)
		image.modulate = Color('#acaaaa')
		node.add_child(image)

		image_container.add_child(node)

	outline_border_control.pressed = outline
	outline_border_inside_control.pressed = outline_inside
	outline_border_size_control.value = outline_size
	_update_preview()

	done_button.grab_focus()


func _on_size_button_pressed(index):
	selected_size_index = index
	for child_index in size_container.get_child_count():
		var node = size_container.get_child(child_index)
		node.pressed = child_index == index
	_update_preview()


func _on_color_button_pressed(index):
	selected_color_index = index
	for child_index in color_container.get_child_count():
		var node = color_container.get_child(child_index)
		node.pressed = child_index == index
	_update_preview()


func _on_image_button_pressed(index):
	selected_image_index = index
	for child_index in image_container.get_child_count():
		var node = image_container.get_child(child_index)
		node.pressed = child_index + 1 == index
	_update_preview()
	

func _update_preview():
	var scale = float(sizes[selected_size_index]) / image_size
	var color = colors[selected_color_index]
	preview_sprite.texture = load("res://assets/input/crosshair/crosshair%s.png" % [selected_image_index])
	preview_sprite.scale = Vector2(scale, scale)
	preview_sprite.modulate = color
	preview_sprite.material.set_shader_param('add_border', outline)
	preview_sprite.material.set_shader_param('border_inside', outline_inside)
	preview_sprite.material.set_shader_param('border_width', outline_size)


func _on_done_button_pressed():
	var data = {
		image_index = selected_image_index,
		color = colors[selected_color_index],
		scale = sizes[selected_size_index] / image_size,
		outline = outline,
		outline_inside = outline_inside,
		outline_size = outline_size,
	}
	emit_signal("changed", data)
	hide()


func _on_outline_control_toggled(button_pressed):
	outline = button_pressed
	_update_preview()


func _on_outline_border_control_toggled(button_pressed):
	outline = button_pressed
	_update_preview()


func _on_outline_border_inside_control_toggled(button_pressed):
	outline_inside = button_pressed
	_update_preview()


func _on_outline_boder_size_control_value_changed(value):
	outline_size = value
	_update_preview()
