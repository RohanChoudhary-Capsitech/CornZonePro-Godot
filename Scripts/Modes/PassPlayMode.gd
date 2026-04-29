extends Node

func on_ball_entered(body: Node3D) -> void:
	GameSession.add_score(GameSession.current_turn, 1)
	on_score()

func on_score() -> void:
	GameSession.next_turn()  # switch turn after each score

func on_match_end() -> void:
	_give_coins()
	_save_scores()

func _give_coins() -> void:
	if GameSession.score_p1 > GameSession.score_p2:
		DataManager.add_coins(GameSession.score_p1 * 2)
		print("Player 1 wins!")
	elif GameSession.score_p2 > GameSession.score_p1:
		DataManager.add_coins(GameSession.score_p2 * 2)
		print("Player 2 wins!")
	else:
		DataManager.add_coins(GameSession.score_p1)  # draw, half coins
		print("Draw!")

func _save_scores() -> void:
	Prefs.set_int("last_score_p1", GameSession.score_p1)
	Prefs.set_int("last_score_p2", GameSession.score_p2)
