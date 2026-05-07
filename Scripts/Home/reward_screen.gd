extends CanvasLayer

func _ready() -> void:
	var reward_node = get_node("../DailyRewardScreen")
	reward_node.reward_collect.connect(_on_reward_collect)

func _on_reward_collect(reward):
	$Panel/PanelBG/DayText.text = "Day " + str(reward.day)
	$Panel/PanelBG/CoinValue.text = "+"+ str(reward.coin_amount)
	#print(reward)


func _on_claim_pressed() -> void:
	UIManager.toggle_canvas($".")
