extends Node

const BAGS_PER_PLAYER := 4

var p1_bags_thrown: int = 0
var p2_bags_thrown: int = 0

func on_ball_entered(body: Node3D) -> void:
	var scoring_player := GameSession.current_turn
	if body.has_meta("throw_player"):
		scoring_player = int(body.get_meta("throw_player"))
	var awarded_points := int(body.get_meta("awarded_points", 0))
	var delta :int= max(0, 3 - awarded_points)
	body.set_meta("awarded_points", 3)
	GameSession.add_score(scoring_player, delta)

func on_bag_thrown()->void:
	if GameSession.current_turn == 1:
		p1_bags_thrown += 1
	else:
		p2_bags_thrown += 1

	if p1_bags_thrown >= BAGS_PER_PLAYER and p2_bags_thrown >= BAGS_PER_PLAYER:
		GameSession.end_match()
		GameSession.turns_exhausted.emit()
		return

	GameSession.current_turn = 2 if GameSession.current_turn == 1 else 1
	GameSession.turn_changed.emit(GameSession.current_turn)

func on_match_end() -> void:
	_reset_round()

func _reset_round()->void:
	p1_bags_thrown = 0
	p2_bags_thrown = 0
