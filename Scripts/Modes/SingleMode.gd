extends Node



func on_ball_entered(body: Node3D) -> void:
	GameSession.add_score(1, 1)
	on_score()

func on_score() -> void:
	DataManager.add_coins(2)

func on_match_end() -> void:
	# DataManager.add_coins(GameSession.score_p1 * 2)
	_save_scores()

func _save_scores() -> void:
	var pot: int = GameSession.score_p1
	# Get existing total
	var total_pots: int = Prefs.get_int("total_pots", 0)
	# Add current score
	total_pots += pot
	# Save updated total
	Prefs.set_int("total_pots", total_pots)
	GameSession.pots_update.emit()
	
	# Check best score
	var best: int = Prefs.get_int("max_pots", 0)
	if pot > best:
		Prefs.set_int("max_pots", pot)
		print("New best pots:", pot)
	# Save to disk (if your Prefs requires it)
	Prefs.save()
