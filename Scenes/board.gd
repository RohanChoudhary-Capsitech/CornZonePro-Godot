extends StaticBody3D

# Board.gd or Game.gd
func _ready() -> void:
	load_ui()

func load_ui() -> void:
	#GameSession.selected_mode="Single"
	print("Mode is: '", GameSession.selected_mode, "'")
	print("Available keys: ", GameSession.UI_SCENES.keys())
	var ui_scene = GameSession.UI_SCENES[GameSession.selected_mode]
	var ui_instance = ui_scene.instantiate()
	add_child(ui_instance)
