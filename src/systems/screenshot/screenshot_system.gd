extends Node

export var interval = 5
export var save_path = 'res://build/screenshot'
export var take_shot_on_pause = true 

func _ready():
	if save_path && !save_path.ends_with('/'):
		save_path += '/'
	
	if save_path:
		$timer.start(interval)


func _on_timer_timeout():
	if !take_shot_on_pause && get_tree().paused:
		return
	var date = OS.get_datetime()
	var dir = Directory.new()
	var filename = "screenshot_{width}x{height}_%02d-%02d-%02d_%02d:%02d:%02d.png" % [date.year, date.month, date.day, date.hour, date.minute, date.second]
	
	var size = get_viewport().get_size()
	var path = save_path + filename.format({width = size.x, height = size.y})
	if !dir.dir_exists(path.get_base_dir()):
		dir.make_dir(path.get_base_dir())
		
	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	image.save_png(path)
