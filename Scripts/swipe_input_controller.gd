class_name SwipeInputController

extends Node
 
signal swipe_completed(direction: Vector3, strength: float)
 
@export_group("Swipe Settings")

@export var horizontal_sensitivity: float = 0.15
@export var vertical_sensitivity: float = 0.4
@export var throw_strength_multiplier: float = 0.05
@export var min_swipe_dist: float = 30.0

var start_time: int = 0
var end_time: int = 0
var main_camera: Camera3D
var start_pos: Vector2
var end_pos: Vector2
var swipe_dis: float = 0.0
var swipe_time: float = 0.0
 
 
func _ready() -> void:
	main_camera = get_viewport().get_camera_3d()
 
 
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			start_pos = event.position
			start_time = Time.get_ticks_msec()
		else:
			end_pos = event.position
			end_time = Time.get_ticks_msec()
			swipe_dis = start_pos.distance_to(end_pos)
			swipe_time = end_time - start_time
			if swipe_time > 0 and swipe_dis >= min_swipe_dist:
				process_swipe(end_pos, swipe_dis, swipe_time)
  
func process_swipe(release_pos: Vector2, dist: float, time: float) -> void:
	var direction = get_swipe_direction(start_pos, release_pos)
	print(dist)
	var strength = (dist * throw_strength_multiplier)
	print(strength)
	strength = clamp(strength, 1.0, 20.0)
	swipe_completed.emit(direction, strength)
	
 
 
func get_swipe_direction(s_pos: Vector2, e_pos: Vector2) -> Vector3:
	var swipe = s_pos-e_pos
	var cam_basis = main_camera.global_transform.basis
	var yaw_angle = deg_to_rad(swipe.x * horizontal_sensitivity)
	var yaw_basis = Basis(Vector3.UP, yaw_angle)
	var forward = -cam_basis.z
	forward.y = 0
	forward = forward.normalized()
	var dir = yaw_basis * forward
	var pitch_angle = clamp(swipe.y * vertical_sensitivity, 10.0, 45.0)
	var pitch_basis = Basis(cam_basis.x, deg_to_rad(pitch_angle))
	return (pitch_basis * dir).normalized()
 
