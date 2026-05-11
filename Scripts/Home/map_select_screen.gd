extends CanvasLayer

var map_time:float


#region Map_constants
#----Scenes---------------------------------
const lawn:="res://Scenes/Maps/lawn.tscn"
const street:="res://Scenes/Maps/street.tscn"
const rooftop:="res://Scenes/Maps/rooftop.tscn"
const backyard:="res://Scenes/Maps/backyard.tscn"
const metro:="res://Scenes/Maps/metro.tscn"
const stadium:="res://Scenes/Maps/stadium.tscn"
#-----------------------------------------------

#----Map Configs-----------------------------
const lawn_config:=preload("res://Resources/Maps/lawn.tres")
const street_config:=preload("res://Resources/Maps/street.tres")
const rooftop_config:=preload("res://Resources/Maps/rooftop.tres")
const backyard_config:=preload("res://Resources/Maps/backyard.tres")
const metro_config:=preload("res://Resources/Maps/metro.tres")
const stadium_config:=preload("res://Resources/Maps/stadium.tres")
#-----------------------------------------------

#endregion

func game_setup()->void:
	UIManager._begin_match(GameSession.selected_mode,
	GameSession.selected_map_path,GameSession.required_ui,map_time)

func _on_cross_button_pressed() -> void:
	UIManager.toggle_canvas($".")


#region Map_Button_Functions

func _on_lawn_map_pressed() -> void:
	GameSession.selected_map_path=lawn
	map_time=lawn_config.time_limit
	game_setup()

func _on_street_map_pressed() -> void:
	GameSession.selected_map_path=street
	map_time=street_config.time_limit
	game_setup()

func _on_stadium_map_pressed() -> void:
	GameSession.selected_map_path=stadium
	map_time=stadium_config.time_limit
	game_setup()

func _on_backyard_map_pressed() -> void:
	GameSession.selected_map_path=backyard
	map_time=backyard_config.time_limit
	game_setup()

func _on_rooftop_map_pressed() -> void:
	GameSession.selected_map_path=rooftop
	map_time=rooftop_config.time_limit
	game_setup()

func _on_metro_map_pressed() -> void:
	GameSession.selected_map_path=metro
	map_time=metro_config.time_limit
	game_setup()
#endregion
