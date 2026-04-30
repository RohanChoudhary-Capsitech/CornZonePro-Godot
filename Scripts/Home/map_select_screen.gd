extends HBoxContainer

@export var focused_height: float = 420.0
@export var normal_height: float = 350.0
@export var animation_speed: float = 0.2

func _ready():
	for button in get_children():
		if button is Button:
			button.focus_entered.connect(_on_button_focus_changed.bind(button, true))
			button.focus_exited.connect(_on_button_focus_changed.bind(button, false))

func _on_button_focus_changed(button: Button, is_focused: bool):
	var target_height = focused_height if is_focused else normal_height
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(button, "custom_minimum_size:y", target_height, animation_speed)
	
	button.pivot_offset = button.size / 2
