extends CanvasLayer

@onready var timer_slider: TextureProgressBar = $"../InGame UI/Slider/TimerSlider"

func _ready() -> void:
	timer_slider.time_over.connect(gameover)

func gameover()->void:
	UIManager.enable_canvas($".")
	$"Control/Black Bg/PausePanel BG/CoinsText".text=str(GameSession.score_p1*2)


func _on_home_pressed() -> void:
	UIManager.home()
