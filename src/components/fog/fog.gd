extends Node2D

const LightTexture = preload("res://src/components/fog/texture/fog_light.png")
const GRID_SIZE = 16


var display_width = ProjectSettings.get("display/window/size/width")
var display_height = ProjectSettings.get("display/window/size/height")

var fogImage = Image.new()
var fogTexture = ImageTexture.new()
var lightImage = LightTexture.get_data()
var light_offset = Vector2(LightTexture.get_width()/2.0, LightTexture.get_height()/2.0)

onready var sprite = $sprite

func _ready():
	var viewport_size = get_viewport().get_size()
	display_width = viewport_size.x
	display_height = viewport_size.y

	var padding = Vector2(50, 30)
	var size = Vector2(18, 14)
	var center = size / 2
	var margin = center/2
	
	display_width = (size.x + padding.x) * 16 
	display_height = (size.y + padding.y) * 16 

	
	var fog_image_width = display_width/GRID_SIZE
	var fog_image_height = display_height/GRID_SIZE
	fogImage.create(fog_image_width, fog_image_height, false, Image.FORMAT_RGBAH)
	fogImage.fill(Color.black)
	lightImage.convert(Image.FORMAT_RGBAH)
	sprite.scale *= GRID_SIZE
	
	for x in center.x + 4:
		for y in center.y + 3:
			var position = padding/2 + margin + Vector2(x - 1, y - 1)
			update_fog(position)

	# top
#	update_fog(padding / 2 + margin + Vector2(-2, -2))
#	# right
#	update_fog(padding / 2 + margin + Vector2(center.x + 4, -2))
#	# bottom
#	update_fog(padding / 2 + margin + Vector2(center.x + 4, center.y + 2))
#	# left
#	update_fog(padding / 2 + margin + Vector2(-2, center.y + 2))
			
	
	# position = Vector2(-48, -44)
	position = (padding/2 - Vector2(0, 0.5)) * -16

	z_index += 1
#	global_position =  Vector2(display_width/2, display_height/2)

	
#
#func _input(event):
#	update_fog(get_local_mouse_position()/GRID_SIZE)
	

func update_fog(new_grid_position):
	
#	global_position = Global.player.global_position - Vector2(display_width/2, display_height/2)
	
	fogImage.lock()
	lightImage.lock()
	
	var light_rect = Rect2(Vector2.ZERO, Vector2(lightImage.get_width(), lightImage.get_height()))
	fogImage.blend_rect(lightImage, light_rect, new_grid_position - light_offset)
	
	fogImage.unlock()
	lightImage.unlock()
	update_fog_image_texture()

func update_fog_image_texture():
	fogTexture.create_from_image(fogImage)
	sprite.texture = fogTexture

