extends Node

const BAGS_PER_PLAYER := 4

var p1_bags_thrown: int = 0
var p2_bags_thrown: int = 0
var results_saved: bool = false

func on_ball_entered(body: Node3D) -> void:
	var scoring_player := GameSession.current_turn
	if body.has_meta("throw_player"):
		scoring_player = int(body.get_meta("throw_player"))
	var awarded_points := int(body.get_meta("awarded_points", 0))
	var delta: int = maxi(0, 3 - awarded_points)
	body.set_meta("awarded_points", 3)
	GameSession.add_score(scoring_player, delta)

func on_bag_thrown()->void:
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
	if GameSession.match_over and not results_saved:
		_save_scores()
	_reset_round()
	AnalyticsManager.log_event("Pass & Play end")

func _reset_round()->void:
	p1_bags_thrown = 0
	p2_bags_thrown = 0
	results_saved = false

func _save_scores() -> void:
	if results_saved:
		return

	Prefs.set_int("passplay_last_score_p1", GameSession.score_p1)
	Prefs.set_int("passplay_last_score_p2", GameSession.score_p2)

	var total_score_p1: int = int(Prefs.get_int("passplay_total_score_p1", 0))
	var total_score_p2: int = int(Prefs.get_int("passplay_total_score_p2", 0))
	Prefs.set_int("passplay_total_score_p1", total_score_p1 + GameSession.score_p1)
	Prefs.set_int("passplay_total_score_p2", total_score_p2 + GameSession.score_p2)

	if GameSession.score_p1 > GameSession.score_p2:
		var p1_wins: int = int(Prefs.get_int("passplay_p1_wins", 0))
		Prefs.set_int("passplay_p1_wins", p1_wins + 1)
	elif GameSession.score_p2 > GameSession.score_p1:
		var p2_wins: int = int(Prefs.get_int("passplay_p2_wins", 0))
		Prefs.set_int("passplay_p2_wins", p2_wins + 1)

	Prefs.save()
	results_saved = true
