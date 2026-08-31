extends Popup

onready var grid_container = $container/grid_container/grid
onready var selected_description = $container/selected/description

var size: int
var data = []

var backpack: Backpack
var grid_item_size = 20
var grid_item_font_size = 12
var _opened = false

func _ready():
	if Global.is_mobile():
		grid_item_size = 40
		grid_item_font_size = 18
	grid_container.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	_on_language_changed()
	Global.connect("player_spawned", self, "_on_player_spawned")
	Settings.connect("language_changed", self, "_on_language_changed")


func open():
	Global.opened_popups_add(self, { popup_tween = false })
	popup()
	for index in backpack.data.size():
		var node = grid_container.get_child(index)
		_update_node(node, index)
	_opened = false
	grid_container.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	grid_container.rect_pivot_offset = grid_container.rect_size/2.0
	grid_container.rect_scale = Vector2(0.7, 0.7)
	var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(grid_container, 'rect_scale', Vector2(1, 1), 0.2)
	get_tree().create_timer(0.1).connect('timeout', self, "_on_opened")


func _on_player_spawned():
	backpack = Global.player.backpack
	for index in backpack.data.size():
		var node = grid_container.get_child(index)
		node.rect_min_size = Vector2(grid_item_size, grid_item_size)
		node.font_size = grid_item_font_size
		node.connect("pressed", self, "_on_button_pressed", [index])
		node.connect("focus_entered", self, "_on_button_focus_entered", [index])


func _on_opened():
	SFX.add_popup()
	_opened = true


func _on_button_pressed(index: int):
	var node = grid_container.get_child(index)
	backpack.use(index)
	_update_node(node, index)
	_on_button_focus_entered(index)


func _on_button_focus_entered(index: int):
	var item = backpack.data[index]
	if !item.id || item.size <= 0:
		selected_description.hide()
		return
	var item_data = backpack.get_data(item.id)
	selected_description.show()
	selected_description.bbcode_text = "[center]%s\n%s[/center]" % [tr(item_data.label), item_data.format_description()]


func _update_node(node, index):
	var item = backpack.data[index]
	if item.size == 0:
		node.name = 'empty_%s' % [index]
		node.size = 0
		node.icon_texture = null
		return
	node.name = item.id
	node.size = item.size
	node.hint_tooltip = backpack.get_data(item.id).label
	node.icon_texture = backpack.get_data(item.id).icon
	

func _on_bg_gui_input(event):
	if !visible || !_opened:
		return
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT || event.button_index == BUTTON_RIGHT:
			hide()
	elif event is InputEventScreenTouch and event.pressed:
		hide()


func _on_backpack_popup_hide():
	Global.opened_popups_remove(self)
	Global.remove_toasts(Toast.TYPE_WARN)


func _on_language_changed():
	selected_description.set('custom_fonts/normal_font', Global.get_font(8)) 
