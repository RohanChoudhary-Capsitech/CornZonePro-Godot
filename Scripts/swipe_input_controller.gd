class_name SwipeInputController

extends Node

signal swipe_completed(direction: Vector3, strength: float)
signal swipe_updated(direction: Vector3, strength: float)

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

func is_network_game() -> bool:
	return GameSession.selected_mode == "Local"

func get_my_player_id() -> int:
	return 1 if multiplayer.is_server() else 2

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			start_pos = event.position
			start_time = Time.get_ticks_msec()
		else:
			end_pos = event.position
			end_time = Time.get_ticks_msec()
			swipe_dis = start_pos.distance_to(end_pos)
			swipe_time = end_time - start_time
			if swipe_time > 0 and swipe_dis >= min_swipe_dist:
				process_swipe(end_pos, swipe_dis)

	if event is InputEventScreenDrag:
		_emit_swipe_preview(event.position)

	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_emit_swipe_preview(event.position)

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
				process_swipe(end_pos, swipe_dis)

func _emit_swipe_preview(current_pos: Vector2) -> void:
	# 🟢 ONLY block in multiplayer
	# if is_network_game():
	# 	if GameSession.current_turn != get_my_player_id():
	# 		return

	var dist: float = start_pos.distance_to(current_pos)
	if dist < min_swipe_dist:
		return

	var direction: Vector3 = get_swipe_direction(start_pos, current_pos)
	var strength: float = clamp(dist * throw_strength_multiplier, 1.0, 20.0)

	swipe_updated.emit(direction, strength)

func process_swipe(release_pos: Vector2, dist: float) -> void:
	# 🟢 ONLY block in multiplayer
	if is_network_game():
		if GameSession.current_turn != get_my_player_id():
			return

	var direction: Vector3 = get_swipe_direction(start_pos, release_pos)
	var strength: float = clamp(dist * throw_strength_multiplier, 1.0, 20.0)

	swipe_completed.emit(direction, strength)

func get_swipe_direction(s_pos: Vector2, e_pos: Vector2) -> Vector3:
	var swipe: Vector2 = s_pos - e_pos
	var cam_basis: Basis = main_camera.global_transform.basis
	var yaw_angle: float = deg_to_rad(swipe.x * horizontal_sensitivity)
	var yaw_basis: Basis = Basis(Vector3.UP, yaw_angle)
	var forward: Vector3 = -cam_basis.z
	forward.y = 0
	forward = forward.normalized()
	var dir: Vector3 = yaw_basis * forward
	var pitch_angle: float = clamp(swipe.y * vertical_sensitivity, 10.0, 45.0)
	var pitch_basis: Basis = Basis(cam_basis.x, deg_to_rad(pitch_angle))
	return (pitch_basis * dir).normalized()
