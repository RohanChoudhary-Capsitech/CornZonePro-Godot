extends StaticBody3D

const AWARDED_POINTS_META := "awarded_points"

# Board.gd or Game.gd
func _ready() -> void:
	load_ui()

func load_ui() -> void:
	#GameSession.selected_mode="Single"
	print("Mode is: '", GameSession.selected_mode, "'")
	print("Available keys: ", GameSession.UI_SCENES.keys())
	var ui_scene: PackedScene = GameSession.UI_SCENES[GameSession.selected_mode]
	var ui_instance: Node = ui_scene.instantiate()
	add_child(ui_instance)

func on_bag_landed(body: Node3D) -> void:
	if not (body is RigidBody3D):
		return

	var awarded_points: int = int(body.get_meta(AWARDED_POINTS_META, 0))
	if awarded_points >= 1:
		return

	var scoring_player: int = int(body.get_meta("throw_player", GameSession.current_turn))
	body.set_meta(AWARDED_POINTS_META, 1)
	GameSession.add_score(scoring_player, 1)

	var uses_bag_result_slots: bool = GameSession.selected_mode == "PassPlay" or GameSession.selected_mode == "Local"
	if uses_bag_result_slots and body.has_meta("bag_result_index"):
		GameSession.update_bag_result(scoring_player, int(body.get_meta("bag_result_index")), 1)

	GameSession.pots_update.emit()
