extends CanvasLayer
signal reward_collect(reward: Dictionary)


func _on_cross_button_pressed() -> void:
	UIManager.toggle_canvas($".")


func _on_day_1_button_pressed() -> void:
	UIManager.toggle_canvas($"../RewardScreen")
	reward_collect.emit({"day": 1, "coin_amount": 5})
	
func _on_day_2_button_pressed() -> void:
	UIManager.toggle_canvas($"../RewardScreen")
	reward_collect.emit({"day": 2, "coin_amount": 10})


func _on_day_3_button_pressed() -> void:
	UIManager.toggle_canvas($"../RewardScreen")
	reward_collect.emit({"day": 3, "coin_amount": 15})


func _on_day_4_button_pressed() -> void:
	UIManager.toggle_canvas($"../RewardScreen")
	reward_collect.emit({"day": 4, "coin_amount": 20})


func _on_day_5_button_pressed() -> void:
	UIManager.toggle_canvas($"../RewardScreen")
	reward_collect.emit({"day": 5, "coin_amount": 25})


func _on_day_6_button_pressed() -> void:
	UIManager.toggle_canvas($"../RewardScreen")
	reward_collect.emit({"day": 6, "coin_amount": 30})


func _on_day_7_button_pressed() -> void:
	UIManager.toggle_canvas($"../RewardScreen")
	reward_collect.emit({"day": 7, "coin_amount": 35})
