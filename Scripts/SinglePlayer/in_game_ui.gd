extends CanvasLayer

@onready var timer_slider := $Slider/TimerSlider as MatchTimerSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DataManager.coins_changed.connect(update_ui)
	update_ui()

func update_ui()->void:
	$Coins/Label.text = str(DataManager.get_coins())

func _on_add_timer_pressed() -> void:
	var possible:bool=DataManager.spend_coins(20)
	if possible:
		timer_slider.add_time(5)
	else:
		print("Not neough coins")


func _on_show_projectile_pressed() -> void:
	var possible:bool=DataManager.spend_coins(30)
	if possible:
		GameSession.activate_projectile_preview(5.0)
	else:
		print("Not enough coins")
