extends Area3D

const SCORED_META := "pointer_scored"

func _ready() -> void:
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if not (body is RigidBody3D):
		return
	if bool(body.get_meta(SCORED_META, false)):
		return
	if GameSession.mode_logic == null:
		return
	if not GameSession.mode_logic.has_method("on_ball_entered"):
		push_warning("[Pointer] Active mode cannot score bodies: " + GameSession.selected_mode)
		return

	var scoring_player := int(body.get_meta("throw_player", GameSession.current_turn))
	var score_before := GameSession.score_p1 + GameSession.score_p2
	body.set_meta(SCORED_META, true)
	GameSession.mode_logic.on_ball_entered(body)
	if GameSession.selected_mode == "PassPlay" and body.has_meta("bag_result_index"):
		GameSession.update_bag_result(scoring_player, int(body.get_meta("bag_result_index")), int(body.get_meta("awarded_points", 0)))

	var score_after := GameSession.score_p1 + GameSession.score_p2
	if score_after != score_before:
		GameSession.pots_update.emit()

func _on_body_exited(body: Node3D) -> void:
	pass
