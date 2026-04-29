extends Resource
class_name MapConfig

@export_group("Basic")
@export var map_name: String = ""

@export_group("Gameplay")
@export var time_limit: float = 20.0
@export var wind_strength: float = 0.0
@export var coin_reward: int = 10

@export_group("Modes")
@export var supports_single_player: bool = false
@export var supports_pass_and_play: bool = false

@export_group("Unlock")
@export var single_player_unlocked: bool = false
@export var pass_and_play_unlocked: bool = false

@export_group("Price")
@export var single_player_cost: int
@export var pass_and_play_cost: int
