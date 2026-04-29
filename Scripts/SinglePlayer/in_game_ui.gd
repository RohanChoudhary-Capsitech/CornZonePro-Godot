extends CanvasLayer

@onready var timer_slider := $Slider/TimerSlider as MatchTimerSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameSession.score_changed.connect(update_ui)
	update_ui()

func update_ui()->void:
	$Coins/Label.text=str(GameSession.score_p1*2)
	timer_slider.add_time(5)
