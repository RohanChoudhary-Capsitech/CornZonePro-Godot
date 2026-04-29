extends Resource
class_name BagConfig

@export_group("Bag Details")
@export var bag_name: String = ""
@export var price: int = 0
@export var unlocked: bool = false
@export var icon: Texture2D

@export_group("Swipe")
@export var horizontal_sensitivity: float = 0.15
@export var vertical_sensitivity: float = 0.4
@export var throw_strength_multiplier: float = 0.05
@export var min_swipe_dist: float = 30.0
@export var min_pitch_angle: float = 10.0
@export var max_pitch_angle: float = 45.0
@export var min_bag_strength: float = 1.0
@export var max_bag_strength: float = 20.0

@export_group("Visuals")
#@export var bag_mesh: Mesh
@export var material_override: Material

@export_group("Effects")
@export var trail_enabled: bool = false
#@export var trail_color: Color = Color.WHITE
#@export var impact_particles: PackedScene

@export_group("Audio")
@export var throw_sound: AudioStream
@export var hit_sound: AudioStream
