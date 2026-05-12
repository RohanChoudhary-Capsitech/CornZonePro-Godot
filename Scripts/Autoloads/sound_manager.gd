extends Node

@export_group("Audio sources")
@onready var bgm_source: AudioStreamPlayer = $BGMSource
@onready var sfx_source: AudioStreamPlayer = $SFXSource
@onready var pot_source: AudioStreamPlayer = $PotSource

@export_group("Audio Clips")
@export var bgm_clip: AudioStream
@export var button_tap_clip: AudioStream
@export var bag_throw_clip: AudioStream
@export var bag_drop_clip: AudioStream
@export var bag_pot_clip: AudioStream
@export var coin_collect_clip: AudioStream
@export var gameover_clip: AudioStream
@export var win_clip: AudioStream
@export var wind_clip: AudioStream
@export var powerup_clip: AudioStream

var is_music_on: bool = true
var is_sound_on: bool = true

func _ready() -> void:
	load_setting()
	bgm_source.stream = bgm_clip
	bgm_source.bus = "Music"
	play_bgm()
	

func load_setting():
	is_music_on = Prefs.get_bool("music")
	is_sound_on = Prefs.get_bool("sound")


func play_bgm():
	is_music_on = Prefs.get_bool("music")
	if not is_music_on:
		return
	if bgm_source.playing: return
	bgm_source.play()
	print("BGM Playing")
	
func stop_bgm():
	if bgm_source.playing:
		bgm_source.stop()


func play_sfx(clip: AudioStream):
	is_sound_on = Prefs.get_bool("sound")
	if not is_sound_on or clip == null: return
	sfx_source.stream = clip
	sfx_source.play()
	
func play_button_clicks():
	play_sfx(button_tap_clip)
	
func play_bag_throw():
	play_sfx(bag_throw_clip)
	
func play_bag_drop():
	play_sfx(bag_drop_clip)

func play_bag_pot():
	is_sound_on = Prefs.get_bool("sound")
	if not is_sound_on or bag_pot_clip == null: return
	pot_source.stream = bag_pot_clip
	pot_source.play()

func play_coin_collect():
	play_sfx(coin_collect_clip)

func play_game_over():
	play_sfx(gameover_clip)

func play_win():
	play_sfx(win_clip)
	
func play_wind():
	play_sfx(wind_clip)

func play_powerup():
	play_sfx(powerup_clip)
