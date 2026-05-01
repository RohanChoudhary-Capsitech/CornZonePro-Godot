extends Node

const BAGS_PER_PLAYER := 4

var p1_bags_thrown: int = 0
var p2_bags_thrown: int = 0
var results_saved: bool = false

func on_ball_entered(body: Node3D) -> void:
	var scoring_player: int = GameSession.current_turn
	if body.has_meta("throw_player"):
		scoring_player = int(body.get_meta("throw_player"))
	var awarded_points: int = int(body.get_meta("awarded_points", 0))
	var delta: int = maxi(0, 3 - awarded_points)
	body.set_meta("awarded_points", 3)
	GameSession.add_score(scoring_player, delta)

func on_bag_thrown() -> void:
	if GameSession.current_turn == 1:
		p1_bags_thrown += 1
	else:
		p2_bags_thrown += 1

	if p1_bags_thrown >= BAGS_PER_PLAYER and p2_bags_thrown >= BAGS_PER_PLAYER:
		_save_scores()
		GameSession.end_match()
		GameSession.turns_exhausted.emit()
		return

	GameSession.current_turn = 2 if GameSession.current_turn == 1 else 1
	GameSession.turn_changed.emit(GameSession.current_turn)

func on_match_end() -> void:
	if not results_saved and (GameSession.score_p1 > 0 or GameSession.score_p2 > 0):
		_save_scores()
	_reset_round()
	# no coins for local multiplayer

func _reset_round() -> void:
	p1_bags_thrown = 0
	p2_bags_thrown = 0
	results_saved = false

func _save_scores() -> void:
	if results_saved:
		return

	Prefs.set_int("last_score_p1", GameSession.score_p1)
	Prefs.set_int("last_score_p2", GameSession.score_p2)
	
	# track wins
	if GameSession.score_p1 > GameSession.score_p2:
		var wins: int = int(Prefs.get_int("p1_wins", 0))
		Prefs.set_int("p1_wins", wins + 1)
	elif GameSession.score_p2 > GameSession.score_p1:
		var wins: int = int(Prefs.get_int("p2_wins", 0))
		Prefs.set_int("p2_wins", wins + 1)

	Prefs.save()
	results_saved = true
