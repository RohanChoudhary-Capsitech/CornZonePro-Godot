extends Node3D

func _ready() -> void:
	UIManager.home_setup(
		$LoadingScreen,
		$HomeScreen,
		$LoginScreen,
		$SettingScreen,
		$MapSelectScreen
	)
	UIManager.enable_canvas(UIManager.loading_screen)
