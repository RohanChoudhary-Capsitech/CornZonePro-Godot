extends CanvasLayer

var map_time:float

#----Scenes---------------------------------
const lawn:="res://Scenes/Maps/lawn.tscn"
const street:="res://Scenes/Maps/street.tscn"
const rooftop:="res://Scenes/Maps/rooftop.tscn"
const backyard:="res://Scenes/Maps/backyard.tscn"
const metro:="res://Scenes/Maps/metro.tscn"
const stadium:="res://Scenes/Maps/stadium.tscn"

#----Map Configs-----------------------------
const lawn_config:=preload("res://Resources/Maps/lawn.tres")
# const street_config:=preload()
# const rooftop_config:=preload()
# const backyard_config:=preload()
# const metro_config:=preload()
# const stadium_config:=preload()


func _on_cross_button_pressed() -> void:
	UIManager.toggle_canvas($".")


func _on_lawn_map_pressed() -> void:
	GameSession.selected_map_path=lawn
	map_time=lawn_config.time_limit
	game_setup()


func game_setup()->void:
	UIManager._begin_match(GameSession.selected_mode,GameSession.selected_map_path,GameSession.required_ui,map_time)
