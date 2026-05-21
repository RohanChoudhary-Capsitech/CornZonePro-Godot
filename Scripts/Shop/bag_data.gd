extends TextureRect
 
@onready var icon = $HBoxContainer/BagIcon
@onready var rarity_text = $HBoxContainer/Rarity
@onready var bag_button: Button = $BagBuyButton
@onready var price_text = $BagBuyButton/BagPrice
 
@onready var clutch_spot_container = $HBoxContainer/TextureRect2/Powers/ClutchSpot/HBoxContainer
@onready var miss_clock_container = $HBoxContainer/TextureRect2/Powers/MissClock/HBoxContainer
@onready var air_control_container = $HBoxContainer/TextureRect2/Powers/AirControl/HBoxContainer
@onready var power_shot_container = $HBoxContainer/TextureRect2/Powers/PowerShot/HBoxContainer
 
var bag_config: BagConfig
var bag_list_parent: Node
 
 
func setup(data: BagConfig, green: Texture2D, white: Texture2D, parent):
	bag_config = data
	bag_list_parent = parent
 
	icon.texture = data.icon
	if data.rarity == BagConfig.Rarity.Standard:
		$HBoxContainer.add_theme_constant_override("separation", 2)
	rarity_text.text = BagConfig.Rarity.keys()[data.rarity]
   
	update_signals(clutch_spot_container, data.min_swipe_dist, parent.max_clutch_spot, green, white)
	update_signals(miss_clock_container, data.vertical_sensitivity, parent.max_miss_clock, green, white)
	update_signals(air_control_container, data.horizontal_sensitivity, parent.max_air_control, green, white)
	update_signals(power_shot_container, data.max_bag_strength, parent.max_power_shot, green, white)
	_refresh_button_label()
 
	if not bag_button.pressed.is_connected(_on_bag_buy_button_pressed):
		bag_button.pressed.connect(_on_bag_buy_button_pressed)
 
func update_signals(container: HBoxContainer, value: float, max_value: float, green: Texture2D, white: Texture2D):
	if not container: return
   
	var ratio = clamp(value / max_value, 0.0, 1.0)
	var green_count = int(ratio * 10)
   
	var signals = container.get_children()
	for i in range(signals.size()):
		if signals[i] is TextureRect:
			signals[i].texture = green if i < green_count else white
 
 
func _on_bag_buy_button_pressed() -> void:
	if bag_config == null:
		return
 
	var bag_id := _get_bag_id()
	if bag_id.is_empty():
		return
 
	if NetworkManager.save_equipped_bag_id(bag_id):
		SoundManager.play_button_clicks()
		if bag_list_parent != null and bag_list_parent.has_method("load_bag_data"):
			bag_list_parent.call_deferred("load_bag_data")
		else:
			_refresh_button_label()
 
 
func _refresh_button_label() -> void:
	if bag_config == null:
		return
 
	var bag_id := _get_bag_id()
	if NetworkManager.get_local_bag_id() == bag_id:
		price_text.text = "Equipped"
		return
 
	price_text.text = "Equip"
 
 
func _get_bag_id() -> String:
	if bag_config == null:
		return ""
 
	if not bag_config.item_id.is_empty() and NetworkManager.BAG_CONFIGS.has(bag_config.item_id.to_lower()):
		return bag_config.item_id.to_lower()
 
	return bag_config.bag_name.to_lower()
 
 
