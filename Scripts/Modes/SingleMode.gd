extends Node

func on_ball_entered(body: Node3D) -> void:
	if body.is_in_group("player1_ball"):
		GameSession.add_score(1, 1)

func on_score() -> void:
	pass  # no turn switching in single player

func on_match_end() -> void:
	DataManager.add_coins(GameSession.score_p1 * 2)
	_save_scores()

func _save_scores() -> void:
	Prefs.set_int("last_score_p1", GameSession.score_p1)
	var best = Prefs.get_int("best_score_single", 0)
	if GameSession.score_p1 > best:
		Prefs.set_int("best_score_single", GameSession.score_p1)
		print("New best score: ", GameSession.score_p1)
