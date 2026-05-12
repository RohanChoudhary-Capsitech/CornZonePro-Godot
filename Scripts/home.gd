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
		$LeaderBoardScreen,
		$ShopScreen,
		$InventoryScreen
	)
	UIManager.enable_canvas(UIManager.loading_screen)
	#AdManager.show_banner()
