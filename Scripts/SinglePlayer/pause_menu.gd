extends CanvasLayer

@onready var timer_slider := $"../InGame UI/Slider/TimerSlider" as MatchTimerSlider
@onready var coins_text := $"Control/PausePanel BG/CoinsText" as Label

func _on_pause_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($".")
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
