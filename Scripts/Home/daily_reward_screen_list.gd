extends CanvasLayer
signal reward_collect(reward: Dictionary)

@onready var buttons = [
	$Panel/GridContainer/Day1/Day1Button,
	$Panel/GridContainer/Day2/Day2Button,
	$Panel/GridContainer/Day3/Day3Button,
	$Panel/GridContainer/Day4/Day4Button,
	$Panel/GridContainer/Day5/Day5Button,
	$Panel/GridContainer/Day6/Day6Button,
	$Panel/Day7/Day7Button
]

func _ready() -> void:
	DataManager.check_streak_status()
	update_button_visibility()

func update_button_visibility():
	var current_day = DataManager.get_current_day()
	var can_claim_today = DataManager.can_claim()
	
	for i in range(buttons.size()):
		var day_num = i + 1
		buttons[i].disabled = !(day_num == current_day and can_claim_today)

func _on_cross_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($".")

func send_reward(day: int, amount: int):
	UIManager.toggle_canvas($"../RewardScreen")
	AnimateManager.pop_animation($"../RewardScreen/Panel")
	reward_collect.emit({"day": day, "coin_amount": amount})

func _on_day_1_button_pressed() -> void:
	SoundManager.play_button_clicks()
	send_reward(1, 5)
	
func _on_day_2_button_pressed() -> void:
	SoundManager.play_button_clicks()
	send_reward(2, 10)

func _on_day_3_button_pressed() -> void:
	SoundManager.play_button_clicks()
	send_reward(3, 15)

func _on_day_4_button_pressed() -> void:
	SoundManager.play_button_clicks()
	send_reward(4, 20)

func _on_day_5_button_pressed() -> void:
	SoundManager.play_button_clicks()
	send_reward(5, 25)

func _on_day_6_button_pressed() -> void:
	SoundManager.play_button_clicks()
	send_reward(6, 30)

func _on_day_7_button_pressed() -> void:
	SoundManager.play_button_clicks()
	send_reward(7, 35)
