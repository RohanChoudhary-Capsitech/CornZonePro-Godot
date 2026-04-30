extends CanvasLayer

@onready var timer_slider := $"../InGame UI/Slider/TimerSlider" as MatchTimerSlider

func _ready() -> void:
	timer_slider.time_over.connect(gameover)

func gameover()->void:
	UIManager.enable_canvas($".")
	$"Control/PausePanel BG/CoinsText".text=str(GameSession.score_p1*2)


func _on_home_pressed() -> void:
	UIManager.home()


func _on_share_pressed() -> void:
	print("chla h")
	$"Control/PausePanel BG/Label2".visible=true
	if Engine.has_singleton("GodotShare"):
		var share = Engine.get_singleton("GodotShare")
		share.shareText("Test from Godot")
	else:
		print("Plugin not found")


func _on_restart_pressed() -> void:
	print("mai chala")
