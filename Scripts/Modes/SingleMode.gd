extends Node

var current_pots:int=0


func on_ball_entered(body: Node3D) -> void:
	var awarded_points: int = int(body.get_meta("awarded_points", 0))
	var delta: int = maxi(0, 3 - awarded_points)
	body.set_meta("awarded_points", 3)
	GameSession.add_score(1, delta)
	on_score()

	PlayerData.total_pots += 1
	PlayerData.save_local()
	FirebaseManager.mark_dirty([
		FirebaseManager.SECTION_STATS
	])
	print("total pot of the player is " , PlayerData.total_pots)

func on_score() -> void:
	DataManager.add_coins(5)
	current_pots+=1
	print(current_pots," shot")
	if current_pots>3:
		GameSession.wind_control(1)


func on_match_end() -> void:
	# DataManager.add_coins(GameSession.score_p1 * 2)
	_save_scores()
	# print(current_pots,"itna h player k")

func _save_scores() -> void:
	var pot: int = GameSession.score_p1
	# Get existing total
	var total_pots: int = int(Prefs.get_int("total_pots", 0))
	# Add current score
	total_pots += pot
	# Save updated total
	Prefs.set_int("total_pots", total_pots)
	
	
	# Check best score
	var best: int = int(Prefs.get_int("max_pots", 0))
	if pot > best:
		Prefs.set_int("max_pots", pot)
		print("New best pots:", pot)
	# Save to disk (if your Prefs requires it)
	Prefs.save()
