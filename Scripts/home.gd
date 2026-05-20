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
		$InventoryScreen,
		$NoInternetScreen
	)
	var home:=Prefs.get_int("home_comeing",0)
	if home == 0:
		UIManager.enable_canvas($LoadingScreen)
	else:
		UIManager.enable_canvas($HomeScreen)
