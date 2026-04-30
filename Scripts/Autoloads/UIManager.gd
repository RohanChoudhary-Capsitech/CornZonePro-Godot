extends Node

const DEFAULT_MAP_SCENE_PATH := "res://Scenes/Maps/street.tscn"
const DEFAULT_MAP_CONFIG := preload("res://Resources/Maps/street.tres")

var canvas_layers: Array[CanvasLayer] = []
var loading_screen: CanvasLayer
var home_screen: CanvasLayer
var login_screen: CanvasLayer
var setting_screen: CanvasLayer
var map_select_screen: CanvasLayer
var profile_screen:CanvasLayer
var info_screen:CanvasLayer
var daily_rewards_screen:CanvasLayer
var reward_screen:CanvasLayer
var local_multiplayer_screen:CanvasLayer
var leaderboard_screen: CanvasLayer

var ingame_screen:CanvasLayer
var pause_screen:CanvasLayer
var result_screen:CanvasLayer

func home_setup(loading, home, login, setting, map,profile,info,rewards_list,reward,local_multilplayer, leaderboard):
	loading_screen = loading
	home_screen = home
	login_screen = login
	setting_screen = setting
	map_select_screen = map
	profile_screen=profile
	info_screen=info
	daily_rewards_screen=rewards_list
	reward_screen=reward
	local_multiplayer_screen=local_multilplayer
	leaderboard_screen = leaderboard
	canvas_layers = [loading, home, login, setting, map,profile,info,rewards_list,reward,local_multilplayer, leaderboard]

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

func _start_match(mode: String) -> void:
	GameSession.start_match(
		mode,
		DEFAULT_MAP_SCENE_PATH,
		mode,
		DEFAULT_MAP_CONFIG.time_limit
	)
	get_tree().change_scene_to_file(GameSession.selected_map_path)

func single_player()->void:
	_start_match("Single")

func home()->void:
	GameSession.reset_match()
	var scene = load("res://Scenes/home.tscn") as PackedScene
	get_tree().change_scene_to_packed(scene)

func pass_play()->void:
	_start_match("PassPlay")

func local_multiplayer()->void:
	toggle_canvas(local_multiplayer_screen)
	#_start_match("Local")
