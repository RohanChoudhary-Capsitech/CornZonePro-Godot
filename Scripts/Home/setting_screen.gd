extends CanvasLayer

@export var setting_off: Texture2D
@export var setting_on: Texture2D

@export var social_off: Texture2D
@export var social_on: Texture2D

@export var more_games_off: Texture2D
@export var more_games_on: Texture2D

var facebook_link: String = ""
var instagram_link: String = ""
var twitter_link: String = ""
var linkedin_link: String = ""



func _on_cross_button_pressed() -> void:
	UIManager.toggle_canvas($".")


func _on_privacy_policy_button_pressed() -> void:
	OS.shell_open("https://www.thegamewise.com/privacy-policy/")



func _on_facebook_button_pressed() -> void:
	OS.shell_open(facebook_link)


func _on_instagram_button_pressed() -> void:
	OS.shell_open(instagram_link)


func _on_twitter_button_pressed() -> void:
	OS.shell_open(twitter_link)


func _on_linked_in_button_pressed() -> void:
	OS.shell_open(linkedin_link)


func _on_more_games_button_pressed() -> void:
	OS.shell_open("https://play.google.com/store/apps/dev?id=8346369525251412033")
