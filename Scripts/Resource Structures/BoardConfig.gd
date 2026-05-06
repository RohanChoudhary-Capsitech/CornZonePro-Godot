extends Resource

class_name BoardConfig

enum Rarity {Standard, Epic, Rare}

@export_group("Board Details")
@export var board_name: String = ""
@export var price: int = 0 # Price
@export var unlocked: bool = false
@export var icon: Texture2D # Icon
@export var rarity: Rarity # Rarity
