extends CanvasLayer

func _ready() -> void:
	GameSession.pots_update.connect(_sync_total_scores)
	_sync_total_scores()

func _on_cross_pressed() -> void:
	UIManager.toggle_canvas($".")

	
func _on_home_pressed() -> void:
	#UIManager.home()
	pass

func _sync_total_scores() -> void:
	$"Control/PausePanel BG/Dash/Player 1 Score".text = str(GameSession.score_p1)
	$"Control/PausePanel BG/Dash/Player 2 Score".text = str(GameSession.score_p2)

func _on_resume_pressed() -> void:
	UIManager.toggle_canvas(self)

func _on_leave_match_pressed() -> void:
	UIManager.toggle_canvas($"../WarningPanel")
