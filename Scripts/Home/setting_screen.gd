extends CanvasLayer

@onready var setting_texture = $Panel/SettingBg/TopPanel/Setting
@onready var socials_texture = $Panel/SettingBg/TopPanel/Social
@onready var more_games_texture = $Panel/SettingBg/TopPanel/MoreGames

@onready var setting_panel = $Panel/SettingBg/SettingPanel
@onready var social_panel = $Panel/SettingBg/SocialPanel
@onready var more_games_panel = $Panel/SettingBg/MoreGamesPanel

@export var setting_off: Texture2D
@export var setting_on: Texture2D

@export var social_off: Texture2D
@export var social_on: Texture2D

@export var more_games_off: Texture2D
@export var more_games_on: Texture2D

var facebook_link: String = "https://www.facebook.com/profile.php?id=61585251616629"
var instagram_link: String = "https://www.instagram.com/gameewisee/"
var gamewise_link: String = "https://www.thegamewise.com/"
var linkedin_link: String = "https://www.linkedin.com/company/gamewiseglobal/about/?viewAsMember=true"

var is_setting_open = false
var is_social_open = false
var is_more_game_open = false

func _ready() -> void:
	setting_panel.visible = false
	social_panel.visible = false
	more_games_panel.visible = false
	
	setting_panel.visible = true
	is_setting_open = true

func _on_cross_button_pressed() -> void:
	UIManager.toggle_canvas($".")


func _on_privacy_policy_button_pressed() -> void:
	OS.shell_open("https://www.thegamewise.com/privacy-policy/")



func _on_facebook_button_pressed() -> void:
	OS.shell_open(facebook_link)


func _on_instagram_button_pressed() -> void:
	OS.shell_open(instagram_link)


func _on_twitter_button_pressed() -> void:
	OS.shell_open(gamewise_link)


func _on_linked_in_button_pressed() -> void:
	OS.shell_open(linkedin_link)


func _on_more_games_button_pressed() -> void:
	OS.shell_open("https://play.google.com/store/apps/dev?id=8346369525251412033")


func _on_settings_button_pressed() -> void:
	if is_setting_open:
		return
	is_setting_open = true
	is_social_open = false
	is_more_game_open = false
	setting_texture.texture = setting_on
	socials_texture.texture = social_off
	more_games_texture.texture = more_games_off
	setting_panel.visible =  true
	social_panel.visible = false
	more_games_panel.visible = false
	


func _on_socials_button_pressed() -> void:
	if is_social_open:
		return
	is_social_open = true
	is_setting_open = false
	is_more_game_open = false
	socials_texture.texture = social_on
	setting_texture.texture = setting_off
	more_games_texture.texture = more_games_off
	social_panel.visible = true
	setting_panel.visible = false
	more_games_panel.visible = false

func _on_more_game_panel_button_pressed() -> void:
	if is_more_game_open:
		return
	is_more_game_open = true
	is_setting_open = false
	is_social_open = false
	more_games_texture.texture = more_games_on
	setting_texture.texture = setting_off
	socials_texture.texture = social_off
	more_games_panel.visible = true
	setting_panel.visible =  false
	social_panel.visible = false
	
