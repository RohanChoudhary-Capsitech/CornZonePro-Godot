extends CanvasLayer

@export var icons: Array[Texture2D]
@onready var profile_panel = $ProfilePanel
@onready var profile_name = $Panel/ProfileBg/UserNameBG/UserName
@onready var achievememt = $Panel/ProfileBg/PlayerCard/Achievement/Value

func _ready() -> void:
	GameSession.pots_update.connect(update_ui)
	GameSession.match_played.connect(update_ui)
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
	$Panel/ProfileBg/ProfilePic.texture = icons[Prefs.get_int("profile_index", 0)]
	$ProfilePanel.visible = false

func _on_cross_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($".")

func _on_data_ready() -> void:
	update_ui()

func update_ui()->void:
	$"Panel/ProfileBg/PlayerCard/Total Pots/Value".text=str(PlayerData.total_pots)
	$Panel/ProfileBg/PlayerCard/GamePlaySection/GamesPlayedValue.text=str(PlayerData.matches_played)
	profile_name.text = str(PlayerData.player_name)

func _apply_config():
	var daily_bonus = RemoteConfiguration.config.get("daily_bonus",false)
	var halloween_event = RemoteConfiguration.config.get("halloween_event",false)
 
	if daily_bonus == true:
		pass
	else:
		pass

func _on_edit_button_pressed() -> void:
	SoundManager.play_button_clicks()
	$ProfilePanel.visible = true

func _on_female_icon_pressed() -> void:
	Prefs.set_int("profile_index", 1)
	$Panel/ProfileBg/ProfilePic.texture = icons[1]
	$"../HomeScreen/Panel/Profile/Profile Icon/TextureRect".texture = icons[1]
	$"../InventoryScreen/Panel/Profile/Profile Icon/TextureRect".texture = icons[1]
	$ProfilePanel.visible = false

func _on_male_icon_pressed() -> void:
	Prefs.set_int("profile_index", 0)
	$Panel/ProfileBg/ProfilePic.texture = icons[0]
	$"../HomeScreen/Panel/Profile/Profile Icon/TextureRect".texture = icons[0]
	$"../InventoryScreen/Panel/Profile/Profile Icon/TextureRect".texture = icons[0]
	$ProfilePanel.visible = false
	
