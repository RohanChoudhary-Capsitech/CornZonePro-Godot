extends CanvasLayer
@onready var coin_text: Label = $Panel/TopPanel/Coin/CoinText

func _ready() -> void:
	coin_text.text=str(Prefs.get_int("coins",0))

func _on_setting_button_pressed() -> void:
	UIManager.toggle_canvas($"../SettingScreen")

func _on_timer_button_pressed() -> void:
	UIManager.single_player()



func _on_profile_icon_pressed() -> void:
	UIManager.toggle_canvas($"../ProfileScreen")

func _on_info_button_pressed() -> void:
	UIManager.toggle_canvas($"../InfoScreen")

func _on_daily_reward_button_pressed() -> void:
	UIManager.toggle_canvas($"../DailyRewardScreen")

func _on_pass_n_play_button_pressed() -> void:
	UIManager.pass_play()

func _on_lan_button_pressed() -> void:
	UIManager.local_multiplayer()
