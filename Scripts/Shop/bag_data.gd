extends TextureRect

@onready var icon = $HBoxContainer/BagIcon
@onready var rarity_text = $HBoxContainer/Rarity
@onready var price_text = $BagBuyButton/BagPrice

@onready var clutch_spot_container = $HBoxContainer/TextureRect2/Powers/ClutchSpot/HBoxContainer
@onready var miss_clock_container = $HBoxContainer/TextureRect2/Powers/MissClock/HBoxContainer
@onready var air_control_container = $HBoxContainer/TextureRect2/Powers/AirControl/HBoxContainer
@onready var power_shot_container = $HBoxContainer/TextureRect2/Powers/PowerShot/HBoxContainer


func setup(data: BagConfig, green: Texture2D, white: Texture2D, parent):
	icon.texture = data.icon
	price_text.text = str(data.price) + " Buy"
	if data.rarity == BagConfig.Rarity.Standard:
		$HBoxContainer.add_theme_constant_override("separation", 0)
	rarity_text.text = BagConfig.Rarity.keys()[data.rarity]
	
	update_signals(clutch_spot_container, data.min_swipe_dist, parent.max_clutch_spot, green, white)
	update_signals(miss_clock_container, data.vertical_sensitivity, parent.max_miss_clock, green, white)
	update_signals(air_control_container, data.horizontal_sensitivity, parent.max_air_control, green, white)
	update_signals(power_shot_container, data.max_bag_strength, parent.max_power_shot, green, white)

func update_signals(container: HBoxContainer, value: float, max_value: float, green: Texture2D, white: Texture2D):
	if not container: return
	
	var ratio = clamp(value / max_value, 0.0, 1.0)
	var green_count = int(ratio * 10)
	
	var signals = container.get_children()
	for i in range(signals.size()):
		if signals[i] is TextureRect:
			signals[i].texture = green if i < green_count else white
		
