#extends Node
#class_name UI_Controller
#
#
#static func disable_canvas(layer:CanvasLayer):
	#layer.visible = false
#
#static func disable_all_canvaslayers(canvas_layers:Array[CanvasLayer]):
	#for item in canvas_layers:
		#item.visible = false
#
#static func enable_canvas(layer:CanvasLayer,canvas_layers:Array[CanvasLayer]):
	#disable_all_canvaslayers(canvas_layers)
	#layer.visible = true
#
#static func play_btn_tap(audio:AudioStreamPlayer)-> void:
	#if audio and audio.stream:
		#audio.play()
#
#static func toggle_canvas(layer:CanvasLayer)->void:
	#layer.visible=!layer.visible
#
#static func open_scene(path:String)->void:
	#Engine.get_main_loop().change_scene_to_file(path)
#
#static func reload_scene()->void:
	#Engine.get_main_loop().reload_current_scene()
#
#static func quit_game()->void:
	#Engine.get_main_loop().quit()
