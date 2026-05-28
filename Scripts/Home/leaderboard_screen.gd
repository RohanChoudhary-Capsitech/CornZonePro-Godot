extends CanvasLayer
 
@onready var current_rank: Label = $Panel/PanelBg/CurrentUserData/Rank
@onready var username: Label = $Panel/PanelBg/CurrentUserData/Username
@onready var score: Label = $Panel/PanelBg/CurrentUserData/ScoreGroup/Score
 
 
func _ready() -> void:
	if not FirebaseManager.on_data_loaded.is_connected(_on_data_ready):
		FirebaseManager.on_data_loaded.connect(_on_data_ready)
	if not LeaderboardManager.leaderboard_loaded.is_connected(_on_leaderboard_loaded):
		LeaderboardManager.leaderboard_loaded.connect(_on_leaderboard_loaded)
 
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
	   
	   
func _apply_config():
	var daily_bonus = RemoteConfiguration.config.get("daily_bonus", false)
	var halloween_event = RemoteConfiguration.config.get("halloween_event", false)
 
	if daily_bonus == true:
		pass
		#%TitleLabel.visible = true
	else:
		pass
		#%TitleLabel.visible = false
	   
func _on_data_ready() -> void:
	update_ui()
 
 
func _on_leaderboard_loaded(_entries: Array, my_rank: int) -> void:
	if my_rank > 0:
		PlayerData.rank = str(my_rank)
	update_ui()
 
 
func update_ui() -> void:
	current_rank.text = str(PlayerData.rank)
	username.text = str(PlayerData.player_name)
	score.text = str(PlayerData.coins)
 
func _on_cross_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($".")
