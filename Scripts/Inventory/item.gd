extends Control

signal item_clicked(material)

@export var equip_icon: Texture2D
@export var equipped_icon: Texture2D

@onready var button_background = $TextureRect

@onready var data_icon = $Icon
@onready var button = $Icon/Button
var item_material
var actual_material: Material



@onready var equip_button: Button = $TextureRect/EquipButton
 
var _item_id: String = ""
var _item_type: String = ""  # "Cornbags" or "Boards"

func _ready():
	button.pressed.connect(_on_button_pressed)

func setup(item_id: String, item_type: String):
	item_material = CatalogManager.get_material(item_id)
	#actual_material = 
	print("Item material is ",item_material)
	_item_id = item_id
	_item_type = item_type
	
 
	# Load icon from catalog JSON
	var icon_path: String = CatalogManager.get_item_icon(item_id)
	if icon_path != "":
		var tex = load(icon_path)
		if tex:
			data_icon.texture = tex
	if not equip_button.pressed.is_connected(_on_equip_pressed):
		equip_button.pressed.connect(_on_equip_pressed)

	_refresh_equip_state()
 
func _refresh_equip_state() -> void:
	var is_equipped = (
		(_item_type == "Cornbags" and PlayerData.equipped_cornbag == _item_id) or
		(_item_type == "Boards"   and PlayerData.equipped_board   == _item_id)
	)
	button_background.texture = equipped_icon if is_equipped else equip_icon
	equip_button.text = "Equipped" if is_equipped else "Equip"
	equip_button.disabled = is_equipped
 
func _on_equip_pressed() -> void:
	if _item_type == "Cornbags":
		PlayerData.equipped_cornbag = _item_id
	elif _item_type == "Boards":
		PlayerData.equipped_board = _item_id 
	PlayerData.save_local()
	_on_button_pressed()
	FirebaseManager.mark_dirty([FirebaseManager.SECTION_INVENTORY])
 
	# Refresh all sibling cards so equipped state updates
	for card in get_parent().get_children():
		if card.has_method("_refresh_equip_state"):
			card._refresh_equip_state()
	# if PlayerData.needs_cloud_sync:
	# 	await FirebaseManager.push_to_firestore()




func _on_button_pressed() -> void:
	SoundManager.play_button_clicks()
	item_clicked.emit(item_material)
