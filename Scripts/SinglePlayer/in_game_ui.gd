extends CanvasLayer

@onready var timer_slider := $Slider/TimerSlider as MatchTimerSlider
@onready var wind_animation := get_node_or_null("WindAnimation") as Node2D
@onready var wind_particles := get_node_or_null("WindAnimation/GPUParticles2D") as GPUParticles2D
@onready var no_wind_button := $"PowerUp Panel/PowerUp Panel BG/NoWind" as Button
@onready var micro_interaction := $MicroInteraction
var no_wind_until_msec: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameSession.activate_wind.connect(show_wind)
	DataManager.coins_changed.connect(update_ui)
	if no_wind_button:
		no_wind_button.disabled = true
	update_ui()
	AnimateManager.micro_interaction_signal.connect(pop_in)
	AnimateManager.party_popper_signal.connect(party_popper)

func update_ui()->void:
	$Coins/Label.text = str(DataManager.get_coins())
	timer_slider.add_time(5)

func _on_add_timer_pressed() -> void:
	var possible:bool=await DataManager.spend_coins(20)
	if possible:
		timer_slider.add_time(5)
		SoundManager.play_powerup()
	else:
		if AdManager.is_rewarded_ready():
			AdManager.Callable(self, "add_time")
		else:
			AnimateManager.show_notification($Notification, " No ads available", 1.5)

func add_time():
	timer_slider.add_time(5)
	SoundManager.play_powerup()

func show_wind()->void:
	if Time.get_ticks_msec() < no_wind_until_msec:
		return
	if wind_animation:
		wind_animation.visible = true
	if wind_particles:
		wind_particles.emitting = true
		wind_particles.restart()
	if no_wind_button:
		no_wind_button.disabled = false
	SoundManager.play_wind()

func hide_wind():
	if wind_particles:
		wind_particles.emitting = false
	if wind_animation:
		wind_animation.visible = false
	if no_wind_button:
		no_wind_button.disabled = true


func _on_show_projectile_pressed() -> void:
	var possible:bool = await DataManager.spend_coins(30)
	if possible:
		AnimateManager.power_up = true
		print("SIGNAL BUS POWERUP WALA ",AnimateManager.power_up)
		GameSession.activate_projectile_preview(5.0)
		SoundManager.play_powerup()
	else:
		if AdManager.is_rewarded_ready():
			AdManager.show_rewarded(Callable(self, "add_projectile"))
		else:
			AnimateManager.show_notification($Notification, " No ads available", 1.5)

func add_projectile():
	AnimateManager.power_up = true
	print("SIGNAL BUS POWERUP WALA ",AnimateManager.power_up)
	GameSession.activate_projectile_preview(5.0)
	SoundManager.play_powerup()

func pop_in(img_path: String):
	print("THIS GOT CALLED")
	var texture = load(img_path) as Texture2D
	micro_interaction.texture = texture
	micro_interaction.visible = true
	
	# Reset — no position override, stays where placed in scene
	micro_interaction.scale = Vector2.ZERO
	micro_interaction.modulate.a = 0.0
	micro_interaction.rotation = 0.0

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(micro_interaction, "scale", Vector2.ONE, 0.1)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(micro_interaction, "modulate:a", 1.0, 0.1)\
		.set_trans(Tween.TRANS_LINEAR)
	await get_tree().create_timer(0.8).timeout
	var tween2 = create_tween()
	tween2.tween_property(micro_interaction, "modulate:a", 0.0, 0.5)\
		.set_trans(Tween.TRANS_LINEAR)

	await get_tree().create_timer(0.5).timeout
	micro_interaction.visible = false

func party_popper():
	$Confetti.restart()
	$Confetti.emitting = true

func _on_no_wind_pressed() -> void:
	var possible: bool = await DataManager.spend_coins(10)
	if not possible:
		if AdManager.is_rewarded_ready():
			AdManager.show_rewarded(Callable(self, "hide_wind"))
		else:
			AnimateManager.show_notification($Notification, " No ads available", 1.5)

	no_wind_until_msec = Time.get_ticks_msec() + 5000
	hide_wind()
	SoundManager.play_powerup()

	await get_tree().create_timer(5.0).timeout

	if Time.get_ticks_msec() >= no_wind_until_msec:
		show_wind()
