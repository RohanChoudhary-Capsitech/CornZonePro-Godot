extends Node

@export var canvas_layers:Array[CanvasLayer]=[]
@onready var timer_button: Button = $HomeScreen/Panel/RightPanel/RightPanelBG/TimerButton
@onready var loading_bar: TextureProgressBar = $LoadingScreen/LoadPanel/TextureProgressBar
@onready var home_screen: CanvasLayer = $HomeScreen

func toggle_canvas(layer:CanvasLayer)->void:
	layer.visible=!layer.visible

func disable_canvas(layer:CanvasLayer):
	layer.visible = false

func disable_all_canvaslayers():
	print("working")
	for item in canvas_layers:
		item.visible = false

func enable_canvas(layer:CanvasLayer):
	disable_all_canvaslayers()
	layer.visible = true

func single_player()->void:
	GameSession.selected_mode="Single"
	GameSession.selected_map_path="res://Scenes/street.tscn"
	print(GameSession.selected_mode)
	get_tree().change_scene_to_file(GameSession.selected_map_path)

func pass_play()->void:
	GameSession.selected_mode="PassPlay"
	print(GameSession.selected_mode)

func local_multiplayer()->void:
	GameSession.selected_mode="Local"
	print(GameSession.selected_mode)

func _on_timer_button_pressed() -> void:
	single_player()

func _on_lan_button_pressed() -> void:
	local_multiplayer()

func _on_submit_button_pressed() -> void:
	enable_canvas($"../HomeScreen") 
	Prefs.set_int("user",1)

func _on_pass_n_play_button_pressed() -> void:
	pass_play() 

func _on_setting_button_pressed() -> void:
	toggle_canvas($"../SettingScreen")

func _on_cross_button_pressed() -> void:
	toggle_canvas($"../SettingScreen")
