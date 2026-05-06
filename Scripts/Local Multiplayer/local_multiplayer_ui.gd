extends Node

func _ready() -> void:
	UIManager.multiplayer_setup(
		$"InGame UI",
		$PauseMenu,
		$GameOver,
		$WarningPanel,
		$"Rematch popup"
	)
	UIManager.enable_canvas($"InGame UI")
