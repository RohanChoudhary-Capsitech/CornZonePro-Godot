extends CanvasLayer

func _ready() -> void:
	GameSession.pots_update.connect(_sync_total_scores)
	_sync_total_scores()

func _on_cross_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($".")

	
func _on_home_pressed() -> void:
	SoundManager.play_button_clicks()
	#UIManager.home()
	pass

func _sync_total_scores() -> void:
	$"Control/PausePanel BG/Dash/Player 1 Score".text = str(GameSession.score_p1)
	$"Control/PausePanel BG/Dash/Player 2 Score".text = str(GameSession.score_p2)

func _on_resume_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas(self)

func _on_leave_match_pressed() -> void:
	SoundManager.play_button_clicks()
	$"../WarningPanel".show_leave_match_warning()
	pop_animation($"../WarningPanel/Control")
	

func pop_animation(node: Control):
	node.scale = Vector2.ZERO
	node.pivot_offset = node.size / 2
	var tween = create_tween()
	tween.tween_property(node, "scale", Vector2(1.15, 1.15), 0.35)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ONE, 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
