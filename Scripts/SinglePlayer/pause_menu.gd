extends CanvasLayer

@onready var timer_slider := $"../InGame UI/Slider/TimerSlider" as MatchTimerSlider
@onready var coins_text := $"Control/PausePanel BG/CoinsText" as Label

func _on_pause_button_pressed() -> void:
	GameSession.game_paused = true
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($".")
	AnimateManager.pop_animation($Control)
	coins_text.text = str(DataManager.get_coins())
	timer_slider.pause_timer()

func _on_cross_pressed() -> void:
	GameSession.game_paused = false
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($".")
	timer_slider.resume_timer()

func _on_resume_pressed() -> void:
	GameSession.game_paused = false
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($".")
	timer_slider.resume_timer()

func _on_home_pressed() -> void:
	GameSession.game_paused = false
	SoundManager.play_button_clicks()
	UIManager.home()
	if PlayerData.needs_cloud_sync:
		await FirebaseManager.push_to_firestore()

func _on_restart_pressed() -> void:
	GameSession.game_paused = false
	SoundManager.play_button_clicks()
	UIManager.restart()
