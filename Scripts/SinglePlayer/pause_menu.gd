extends CanvasLayer

@onready var timer_slider := $"../InGame UI/Slider/TimerSlider" as MatchTimerSlider
@onready var coins_text := $"Control/PausePanel BG/CoinsText" as Label

func _on_pause_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($".")
	pop_animation($Control)
	coins_text.text = str(DataManager.get_coins())
	timer_slider.pause_timer()

func _on_cross_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($".")
	timer_slider.resume_timer()

func _on_resume_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($".")
	timer_slider.resume_timer()

func _on_home_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.home()
	if PlayerData.needs_cloud_sync:
		await FirebaseManager.push_to_firestore()

func _on_restart_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.restart()

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
