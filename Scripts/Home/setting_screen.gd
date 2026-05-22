extends CanvasLayer

@onready var setting_texture = $Panel/SettingBg/TopPanel/Setting
@onready var socials_texture = $Panel/SettingBg/TopPanel/Social
@onready var more_games_texture = $Panel/SettingBg/TopPanel/MoreGames
@onready var godot_credit_texture = $Panel/SettingBg/TopPanel/GodotCredit

@onready var setting_panel = $Panel/SettingBg/SettingPanel
@onready var social_panel = $Panel/SettingBg/SocialPanel
@onready var more_games_panel = $Panel/SettingBg/MoreGamesPanel
@onready var godot_credit_panel = $Panel/SettingBg/GodotCreditPanel


# Music and Audio
@onready var music_on = $Panel/SettingBg/SettingPanel/BG/MusicOnButton
@onready var music_off = $Panel/SettingBg/SettingPanel/BG/MusicOffButton
@onready var sound_on = $Panel/SettingBg/SettingPanel/BG/SoundOnButton
@onready var sound_off = $Panel/SettingBg/SettingPanel/BG/SoundOffButton

@export var setting_off: Texture2D
@export var setting_on: Texture2D

@export var social_off: Texture2D
@export var social_on: Texture2D

@export var more_games_off: Texture2D
@export var more_games_on: Texture2D

@export var godot_off: Texture2D
@export var godot_on: Texture2D

var facebook_link: String = "https://www.facebook.com/profile.php?id=61585251616629"
var instagram_link: String = "https://www.instagram.com/gameewisee/"
var youtube_link: String = "https://www.youtube.com/@thegamerwise"
var linkedin_link: String = "https://www.linkedin.com/company/gamewiseglobal/about/?viewAsMember=true"

var is_setting_open = false
var is_social_open = false
var is_more_game_open = false
var is_godot_open = false

func _ready() -> void:
	setting_panel.visible = false
	social_panel.visible = false
	more_games_panel.visible = false
	
	setting_panel.visible = true
	is_setting_open = true
	_set_animation([$Panel/SettingBg/SettingPanel/BG/MusicText,
	 $Panel/SettingBg/SettingPanel/BG/AudiioText,
	 $Panel/SettingBg/SettingPanel/BG/Divider,
	 $Panel/SettingBg/SettingPanel/BG/VBoxContainer/LoginWithGoogle,
	 $Panel/SettingBg/SettingPanel/BG/VBoxContainer/LoginWithApple,
	 $Panel/SettingBg/SettingPanel/BG/DeleteAccountButton,
	 $Panel/SettingBg/SettingPanel/BG/PrivacyPolicyButton])
	
	if Prefs.get_bool("music", true):
		music_on.visible = true
		music_off.visible = false
		show_fade_item($Panel/SettingBg/SettingPanel/BG/MusicOnButton, 0.05)
	else:
		music_on.visible = false
		music_off.visible = true
		show_fade_item($Panel/SettingBg/SettingPanel/BG/MusicOffButton, 0.05)
	
	if Prefs.get_bool("sound", true):
		sound_on.visible = true
		sound_off.visible = false
		show_fade_item($Panel/SettingBg/SettingPanel/BG/SoundOnButton, 0.1)
	else:
		sound_on.visible = false
		sound_off.visible = true
		show_fade_item($Panel/SettingBg/SettingPanel/BG/SoundOffButton, 0.05)
	

func _on_cross_button_pressed() -> void:
	SoundManager.play_button_clicks()
	UIManager.toggle_canvas($".")


func _on_privacy_policy_button_pressed() -> void:
	SoundManager.play_button_clicks()
	OS.shell_open("https://www.thegamewise.com/privacy-policy/")



func _on_facebook_button_pressed() -> void:
	SoundManager.play_button_clicks()
	OS.shell_open(facebook_link)


func _on_instagram_button_pressed() -> void:
	SoundManager.play_button_clicks()
	OS.shell_open(instagram_link)


func _on_youtube_button_pressed() -> void:
	SoundManager.play_button_clicks()
	OS.shell_open(youtube_link)


func _on_linked_in_button_pressed() -> void:
	SoundManager.play_button_clicks()
	OS.shell_open(linkedin_link)


func _on_more_games_button_pressed() -> void:
	SoundManager.play_button_clicks()
	OS.shell_open("https://play.google.com/store/apps/dev?id=8346369525251412033")


func _on_settings_button_pressed() -> void:
	SoundManager.play_button_clicks()
	if is_setting_open:
		return
	is_setting_open = true
	is_social_open = false
	is_more_game_open = false
	is_godot_open = false
	setting_texture.texture = setting_on
	socials_texture.texture = social_off
	more_games_texture.texture = more_games_off
	godot_credit_texture.texture = godot_off
	setting_panel.visible =  true
	if Prefs.get_bool("music", true):
		show_fade_item($Panel/SettingBg/SettingPanel/BG/MusicOnButton, 0.05)
	else:
		show_fade_item($Panel/SettingBg/SettingPanel/BG/MusicOffButton, 0.05)
	
	if Prefs.get_bool("sound", true):
		show_fade_item($Panel/SettingBg/SettingPanel/BG/SoundOnButton, 0.1)
	else:
		show_fade_item($Panel/SettingBg/SettingPanel/BG/SoundOffButton, 0.05)
	_set_animation([$Panel/SettingBg/SettingPanel/BG/MusicText,
	 $Panel/SettingBg/SettingPanel/BG/AudiioText,
	 $Panel/SettingBg/SettingPanel/BG/Divider,
	 $Panel/SettingBg/SettingPanel/BG/VBoxContainer/LoginWithGoogle,
	 $Panel/SettingBg/SettingPanel/BG/VBoxContainer/LoginWithApple,
	 $Panel/SettingBg/SettingPanel/BG/DeleteAccountButton,
	 $Panel/SettingBg/SettingPanel/BG/PrivacyPolicyButton])
	social_panel.visible = false
	more_games_panel.visible = false
	godot_credit_panel.visible = false
	


func _on_socials_button_pressed() -> void:
	SoundManager.play_button_clicks()
	if is_social_open:
		return
	is_social_open = true
	is_setting_open = false
	is_more_game_open = false
	is_godot_open = false
	socials_texture.texture = social_on
	setting_texture.texture = setting_off
	more_games_texture.texture = more_games_off
	godot_credit_texture.texture = godot_off
	social_panel.visible = true
	_set_animation([$Panel/SettingBg/SocialPanel/SocialBG/VBoxContainer/Facebook,
	 $Panel/SettingBg/SocialPanel/SocialBG/VBoxContainer/Instagram,
	 $Panel/SettingBg/SocialPanel/SocialBG/VBoxContainer/Linkedin,
	 $Panel/SettingBg/SocialPanel/SocialBG/VBoxContainer/Youtube,
	 $Panel/SettingBg/SocialPanel/SocialBG/TextureRect,
	 $Panel/SettingBg/SocialPanel/SocialBG/Label])
	setting_panel.visible = false
	more_games_panel.visible = false
	godot_credit_panel.visible = false

func _on_more_game_panel_button_pressed() -> void:
	SoundManager.play_button_clicks()
	if is_more_game_open:
		return
	is_more_game_open = true
	is_setting_open = false
	is_social_open = false
	is_godot_open = false
	more_games_texture.texture = more_games_on
	setting_texture.texture = setting_off
	socials_texture.texture = social_off
	godot_credit_texture.texture = godot_off
	more_games_panel.visible = true
	_set_animation([$Panel/SettingBg/MoreGamesPanel/BG/MoreGamesButton,
	 $Panel/SettingBg/MoreGamesPanel/BG/ScrollContainer/GamesContainer,
	 $Panel/SettingBg/MoreGamesPanel/BG/TextureRect])
	setting_panel.visible =  false
	social_panel.visible = false
	godot_credit_panel.visible = false

	
func _on_godot_credit_button_pressed() -> void:
	SoundManager.play_button_clicks()
	if is_godot_open:
		return
	is_godot_open = true
	is_more_game_open = false
	is_setting_open = false
	is_social_open = false
	godot_credit_texture.texture = godot_on
	setting_texture.texture = setting_off
	socials_texture.texture = social_off
	more_games_texture.texture = more_games_off
	godot_credit_panel.visible = true
	_set_animation([$Panel/SettingBg/GodotCreditPanel/BG/ScrollContainer/VBoxContainer/Label1,
	 $Panel/SettingBg/GodotCreditPanel/BG/ScrollContainer/VBoxContainer/Label2,
	 $Panel/SettingBg/GodotCreditPanel/BG/ScrollContainer/VBoxContainer/Label3,
	 $Panel/SettingBg/GodotCreditPanel/BG/ScrollContainer/VBoxContainer/Label4,
	 $Panel/SettingBg/GodotCreditPanel/BG/ScrollContainer/VBoxContainer/Label5])
	setting_panel.visible =  false
	social_panel.visible = false
	more_games_panel.visible = false
	


# Audio and Music settings system
func _on_music_on_button_pressed() -> void:
	SoundManager.play_button_clicks()
	$Panel/SettingBg/SettingPanel/BG/MusicOnButton.visible = false
	$Panel/SettingBg/SettingPanel/BG/MusicOffButton.visible =  true
	SoundManager.set_music(false)
	SoundManager.stop_bgm()


func _on_music_off_button_pressed() -> void:
	SoundManager.play_button_clicks()
	$Panel/SettingBg/SettingPanel/BG/MusicOffButton.visible =  false
	$Panel/SettingBg/SettingPanel/BG/MusicOnButton.visible = true
	SoundManager.set_music(true)
	SoundManager.play_bgm()


func _on_sound_on_button_pressed() -> void:
	SoundManager.play_button_clicks()
	$Panel/SettingBg/SettingPanel/BG/SoundOnButton.visible = false
	$Panel/SettingBg/SettingPanel/BG/SoundOffButton.visible = true
	SoundManager.set_sfx(false)

func _on_sound_off_button_pressed() -> void:
	SoundManager.play_button_clicks()
	$Panel/SettingBg/SettingPanel/BG/SoundOffButton.visible = false
	$Panel/SettingBg/SettingPanel/BG/SoundOnButton.visible = true
	SoundManager.set_sfx(true)


func show_fade_item(node: Control, delay: float):
	# RESET ALPHA
	node.modulate.a = 0.0
	# MAKE VISIBLE
	node.show()
 
	# WAIT
	await get_tree().create_timer(delay).timeout
 
	# FADE TWEEN
	var tween = create_tween()
 
	tween.tween_property(
		node,
		"modulate:a",
		1.0,
		0.35
	).set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_OUT)


func _set_animation(nodes:Array[Node]):
	var val = 0.0
	var inc = 0.05
	for node in nodes:
		val += inc
		show_fade_item(node, val)
