extends Node

@export var canvas_layers:Array[CanvasLayer]=[]

func disable_canvas(layer:CanvasLayer):
	layer.visible = false

func disable_all_canvaslayers():
	print("working")
	for item in canvas_layers:
		item.visible = false

func enable_canvas(layer:CanvasLayer):
	disable_all_canvaslayers()
	layer.visible = true
