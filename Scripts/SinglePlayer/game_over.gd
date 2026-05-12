extends CanvasLayer

@onready var timer_slider := $"../InGame UI/Slider/TimerSlider" as MatchTimerSlider
@onready var coins_text := $"Control/PausePanel BG/CoinsText" as Label

func _ready() -> void:
	timer_slider.time_over.connect(gameover)

func gameover()->void:
	SoundManager.play_game_over()
	UIManager.enable_canvas($".")
	coins_text.text = str(DataManager.get_coins())


func _on_home_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.home()


func _on_share_pressed() -> void:
	print("share button pressed")
	if Engine.has_singleton("GodotShare"):
		var share: Object = Engine.get_singleton("GodotShare")
		share.shareText("Test from Godot")
	else:
		print("Plugin not found")


func _on_restart_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.restart()
