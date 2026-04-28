extends Node

var canvas_layers: Array[CanvasLayer] = []
var loading_screen: CanvasLayer
var home_screen: CanvasLayer
var login_screen: CanvasLayer
var setting_screen: CanvasLayer

var ingame_screen:CanvasLayer
var pause_screen:CanvasLayer
var result_screen:CanvasLayer

func home_setup(loading, home, login, setting):
	loading_screen = loading
	home_screen = home
	login_screen = login
	setting_screen = setting
	canvas_layers = [loading, home, login, setting]

func single_setup(ingame, pause, result):
	#loading_screen = loading
	ingame_screen = ingame
	pause_screen = pause
	result_screen = result
	canvas_layers = [ingame, pause, result]

func disable_all_canvaslayers():
	for item in canvas_layers:
		if is_instance_valid(item):
			item.visible = false

func enable_canvas(layer: CanvasLayer):
	disable_all_canvaslayers()
	layer.visible = true

func toggle_canvas(layer: CanvasLayer):
	layer.visible = !layer.visible

func single_player()->void:
	GameSession.selected_mode="Single"
	GameSession.selected_map_path="res://Scenes/street.tscn"
	print(GameSession.selected_mode)
	get_tree().change_scene_to_file(GameSession.selected_map_path)

func home()->void:
	GameSession.reset_match()
	var scene = load("res://Scenes/home.tscn") as PackedScene
	get_tree().change_scene_to_packed(scene)

func pass_play()->void:
	GameSession.selected_mode="PassPlay"
	print(GameSession.selected_mode)

func local_multiplayer()->void:
	GameSession.selected_mode="Local"
	print(GameSession.selected_mode)
