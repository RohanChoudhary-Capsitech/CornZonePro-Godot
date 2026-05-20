extends CanvasLayer

var current_reward_data = {}

func _ready() -> void:
	var reward_node = get_node("../DailyRewardScreen")
	reward_node.reward_collect.connect(_on_reward_collect)

func _on_reward_collect(reward):
	current_reward_data = reward
	$Panel/PanelBG/DayText.text = "Day " + str(reward.day)
	$Panel/PanelBG/CoinValue.text = "+"+ str(reward.coin_amount)
	#print(reward)


func _on_claim_pressed() -> void:
	SoundManager.play_button_clicks()
	DataManager.add_coins(current_reward_data.coin_amount)
	SoundManager.play_coin_collect()
	DataManager.save_claim_success()
	UIManager.toggle_canvas($".")
	$"../HomeScreen/Panel/TopPanel/Coin/CoinText".text = str(Prefs.get_int("coins",0))
	get_node("../DailyRewardScreen").update_button_visibility()
