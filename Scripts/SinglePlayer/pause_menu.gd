extends CanvasLayer

@onready var timer_slider: TextureProgressBar = $"../InGame UI/Slider/TimerSlider"

func _on_pause_button_pressed() -> void:
	UIManager.toggle_canvas($".")
	$"Control/Black Bg/PausePanel BG/CoinsText".text=str(GameSession.score_p1*2)
	timer_slider.pause_timer()

func _on_cross_pressed() -> void:
	UIManager.toggle_canvas($".")
	timer_slider.resume_timer()

func _on_resume_pressed() -> void:
	UIManager.toggle_canvas($".")
	timer_slider.resume_timer()


func _on_home_pressed() -> void:
	UIManager.home()
