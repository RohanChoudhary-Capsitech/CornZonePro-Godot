extends CanvasLayer

func _ready() -> void:
	GameSession.pots_update.connect(_sync_total_scores)
	_sync_total_scores()

func _on_resume_pressed() -> void:
	UIManager.toggle_canvas($".")

func _on_cross_pressed() -> void:
	UIManager.toggle_canvas($".")

func _on_restart_pressed() -> void:
	UIManager.restart()

func _on_home_pressed() -> void:
	UIManager.home()

func _sync_total_scores() -> void:
	$"Control/Black Bg/PausePanel BG/Dash/Player 1 Score".text = str(GameSession.score_p1)
	$"Control/Black Bg/PausePanel BG/Dash/Player 2 Score".text = str(GameSession.score_p2)
