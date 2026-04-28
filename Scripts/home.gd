extends Node3D

func _ready() -> void:
	UIManager.home_setup(
		$LoadingScreen,
		$HomeScreen,
		$LoginScreen,
		$SettingScreen
	)
	UIManager.enable_canvas(UIManager.loading_screen)
