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
	$"../HomeScreen/Panel/TopPanel/Coin/CoinText".text = str(PlayerData.coins)
	$"../InventoryScreen/Panel/TopPanel/Coin/CoinText".text = str(PlayerData.coins)
	get_node("../DailyRewardScreen").update_button_visibility()


func _on_x_button_pressed() -> void:
	SoundManager.play_button_clicks()
	if AdManager.is_rewarded_ready():
		AdManager.show_rewarded(Callable(self, "claim_reward"))
	else:
		AnimateManager.show_notification($Notification, "No ads available", 1.5)


func claim_reward():
	DataManager.add_coins(current_reward_data.coin_amount * 2)
	SoundManager.play_coin_collect()
	DataManager.save_claim_success()
	UIManager.toggle_canvas($".")
	$"../HomeScreen/Panel/TopPanel/Coin/CoinText".text = str(PlayerData.coins)
	$"../InventoryScreen/Panel/TopPanel/Coin/CoinText".text = str(PlayerData.coins)
	get_node("../DailyRewardScreen").update_button_visibility()
