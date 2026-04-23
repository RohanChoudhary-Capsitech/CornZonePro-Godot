extends Node
class_name UI_Controller


# Called when the node enters the scene tree for the first time.
static func disable_canvas(layer:CanvasLayer):
	layer.visible = false

static func disable_all_canvaslayers(canvas_layers:Array[CanvasLayer]):
	for item in canvas_layers:
		item.visible = false

static func enable_canvas(layer:CanvasLayer,canvas_layers:Array[CanvasLayer]):
	disable_all_canvaslayers(canvas_layers)
	layer.visible = true

static func play_btn_tap(audio:AudioStreamPlayer)-> void:
	if audio and audio.stream:
		audio.play()
