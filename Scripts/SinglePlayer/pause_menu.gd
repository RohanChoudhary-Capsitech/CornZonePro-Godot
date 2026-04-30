extends CanvasLayer

@onready var timer_slider := $"../InGame UI/Slider/TimerSlider" as MatchTimerSlider
@onready var coins_text := $"Control/PausePanel BG/CoinsText" as Label

func _on_pause_button_pressed() -> void:
	UIManager.toggle_canvas($".")
	coins_text.text = str(GameSession.score_p1 * 2)
	timer_slider.pause_timer()

func _on_cross_pressed() -> void:
	UIManager.toggle_canvas($".")
	timer_slider.resume_timer()

func _on_resume_pressed() -> void:
	UIManager.toggle_canvas($".")
	timer_slider.resume_timer()

func _on_home_pressed() -> void:
	UIManager.home()

func _on_restart_pressed() -> void:
	print("Restart button pressed")
