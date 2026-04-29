extends Node

func on_ball_entered(body: Node3D) -> void:
	GameSession.add_score(GameSession.current_turn, 1)
	on_score()

func on_score() -> void:
	GameSession.next_turn()

func on_match_end() -> void:
	_save_scores()
	# no coins for local multiplayer

func _save_scores() -> void:
	Prefs.set_int("last_score_p1", GameSession.score_p1)
	Prefs.set_int("last_score_p2", GameSession.score_p2)
	
	# track wins
	if GameSession.score_p1 > GameSession.score_p2:
		var wins = Prefs.get_int("p1_wins", 0)
		Prefs.set_int("p1_wins", wins + 1)
	elif GameSession.score_p2 > GameSession.score_p1:
		var wins = Prefs.get_int("p2_wins", 0)
		Prefs.set_int("p2_wins", wins + 1)
