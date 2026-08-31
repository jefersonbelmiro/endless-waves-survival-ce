extends Node2D

var process_handler: FuncRef
var draw_handler: FuncRef
var args: Array

func _process(delta):
	if process_handler:
		process_handler.call_func(self, delta)
		
	if draw_handler:
		update()
		
		
func _draw():
	if draw_handler:
		draw_handler.call_func(self)
