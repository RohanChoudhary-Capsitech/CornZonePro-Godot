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
	print(Prefs.get_int("home_comeing",0))
	var home:=Prefs.get_int("home_comeing",0)
	if 0==home:
		UIManager.enable_canvas($LoadingScreen)
	else:
		UIManager.enable_canvas($HomeScreen)
	#AdManager.show_banner()


func _notification(what: int) -> void:
	if what==NOTIFICATION_APPLICATION_PAUSED:
		Prefs.set_int("home_comeing",0)
		print("mai chla")
	elif what==NOTIFICATION_APPLICATION_RESUMED:
		Prefs.set_int("home_comeing",1)
		print("mai chla")
