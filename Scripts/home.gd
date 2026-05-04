extends Node3D

func _ready() -> void:
	UIManager.home_setup(
		$LoadingScreen,
		$HomeScreen,
		$LoginScreen,
		$SettingScreen,
		$MapSelectScreen,
		$ProfileScreen,
		$InfoScreen,
		$DailyRewardScreen,
		$RewardScreen,
		$MultiplayerScreen,
		$LeaderBoardScreen
	)
	UIManager.enable_canvas(UIManager.loading_screen)


func _on_join_button_pressed() -> void:
	pass # Replace with function body.
