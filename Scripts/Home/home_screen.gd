extends CanvasLayer
@onready var coin_text: Label = $Panel/TopPanel/Coin/CoinText
@onready var profile_icon = $"Panel/Profile/Profile Icon/TextureRect"
@onready var profile_name = $Panel/Profile/Label
@onready var profile_edit: Button = $"../ProfileScreen/Panel/ProfileBg/ProfilePic/EditButton"
 
@export var icons: Array[Texture2D]
 
func _ready() -> void:
	#AdManager.show_banner()
	#coin_text.text = str(Prefs.get_int("coins",0))
	profile_icon.texture = icons[Prefs.get_int("profile_index",0)]
	if not FirebaseManager.on_data_loaded.is_connected(_on_data_ready):
		FirebaseManager.on_data_loaded.connect(_on_data_ready)
	if FirebaseManager.data_loaded or PlayerData.has_loaded_data:
		await _on_data_ready()
	else:
		pass
		#rank_label.text = "Loading..."
#
	if not RemoteConfiguration.config_loaded.is_connected(_apply_config):
		RemoteConfiguration.config_loaded.connect(_apply_config)
	if RemoteConfiguration.is_loaded:
		_apply_config()
	#input_player_name.editable = false
	#is_editing = false
	#player_name_submit.pressed.connect(_on_edit_pressed);
	#input_player_name.text_submitted.connect(_on_name_submitted)
	PlayerData.detect_device_type()

func _on_setting_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($"../SettingScreen")
	pop_animation($"../SettingScreen/Panel")

func _on_timer_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.single_player()
	UIManager.toggle_canvas($"../MapSelectScreen")

func _on_profile_icon_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($"../ProfileScreen")
	pop_animation($"../ProfileScreen/Panel")

func _on_info_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($"../InfoScreen")
	pop_animation($"../InfoScreen/Panel")

func _on_daily_reward_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($"../DailyRewardScreen")

func _on_pass_n_play_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.pass_play()
	UIManager.toggle_canvas($"../MapSelectScreen")

func _on_lan_button_pressed() -> void:
	SoundManager.play_button_clicks()
	var multiplayer_screen := $"../MultiplayerScreen"
	UIManager.toggle_canvas(multiplayer_screen)
	pop_animation($"../MultiplayerScreen/Panel")
	if multiplayer_screen.visible and multiplayer_screen.has_method("on_menu_opened"):
		multiplayer_screen.on_menu_opened()


func _on_leaderboard_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($"../LeaderBoardScreen")
	pop_animation($"../LeaderBoardScreen/Panel")

func _on_shop_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($"../ShopScreen")


func _on_inventory_button_pressed() -> void:
	SoundManager.play_button_clicks()
	var inventory_screen := $"../InventoryScreen"
	if inventory_screen.has_method("refresh_from_local"):
		inventory_screen.refresh_from_local()
	UIManager.toggle_canvas(inventory_screen)
 
func _on_data_ready():
	_update_ui()
func _apply_config():
	var daily_bonus = RemoteConfiguration.config.get("daily_bonus",false)
	var halloween_event = RemoteConfiguration.config.get("halloween_event",false)
	if daily_bonus == true:
		pass
		#%TitleLabel.visible = true
	else:
		pass
		#%TitleLabel.visible = false
 
func _update_ui():
	profile_name.text = str(PlayerData.player_name)
	coin_text.text = str(PlayerData.coins)

func pop_animation(node: Control):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(1.15, 1.15), 0.3)
	tween.tween_property(node, "scale", Vector2.ONE, 0.3)
