# =========================
# corn_bag.gd
# =========================
extends RigidBody3D

const AWARDED_POINTS_META := "awarded_points"
const POINTER_SCORED_META := "pointer_scored"
const TOUCHED_BOARD_META := "touched_board"

@onready var swipe_controller: SwipeInputController = $SwipeInputController
@onready var bag_visual: GeometryInstance3D = $sandbag_geo1

var thrown: bool = false
var throw_requested: bool = false

@export var throw_gravity_scale: float = 4.0


func _ready() -> void:
	add_to_group("active_bag")

	print("NODE PATH:", get_path(), " AUTH:", get_multiplayer_authority())

	thrown = false
	throw_requested = false

	freeze = true
	sleeping = false

	contact_monitor = true
	max_contacts_reported = 8

	if not swipe_controller.swipe_completed.is_connected(_on_swipe_completed):
		swipe_controller.swipe_completed.connect(_on_swipe_completed)

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	_apply_bag_visual()


func is_waiting_for_throw() -> bool:
	return not thrown and not throw_requested


func _mark_as_thrown() -> void:
	thrown = true
	throw_requested = false
	if is_in_group("active_bag"):
		remove_from_group("active_bag")


func _apply_bag_visual() -> void:
	if bag_visual == null:
		return

	var throw_player := int(get_meta("throw_player", 1))
	var material: Material = null

	if (
		GameSession.selected_mode == "Local"
		or GameSession.selected_mode == "PassPlay"
	):
		var bag_config := NetworkManager.get_bag_config_for_player(throw_player)
		if bag_config:
			material = bag_config.material_override
	else:
		var local_bag_config := NetworkManager.get_bag_config_by_id(NetworkManager.get_local_bag_id())
		#print("Bag material ", local_bag_config)
		if local_bag_config:
			material = local_bag_config.material_override

	if material != null:
		bag_visual.material_override = material


func _start_throw_physics(direction: Vector3, strength: float) -> void:
	freeze = false
	sleeping = false
	gravity_scale = throw_gravity_scale
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	set_meta(AWARDED_POINTS_META, 0)
	set_meta(POINTER_SCORED_META, false)
	set_meta(TOUCHED_BOARD_META, false)
	apply_central_impulse(direction * strength)
	_mark_as_thrown()


func _on_swipe_completed(direction: Vector3, strength: float) -> void:
	if thrown or throw_requested:
		return

	# Offline
	if GameSession.selected_mode != "Local":
		_apply_throw(direction, strength)
		return

	# Multiplayer missing
	if not multiplayer or multiplayer.multiplayer_peer == null:
		return

	# Turn check
	if not _is_my_turn():
		print("Blocked: Not your turn")
		return

	# Host throws directly
	if multiplayer.is_server():
		_apply_throw(direction, strength)
	else:
		print("CLIENT sending RPC throw")
		throw_requested = true

		# Tell host
		NetworkManager.request_throw.rpc_id(1, direction, strength)


func server_apply_throw(direction: Vector3, strength: float) -> void:
	_apply_throw(direction, strength)


func _apply_throw(direction: Vector3, strength: float) -> void:
	if thrown:
		return
	SoundManager.play_bag_throw()
	set_meta("throw_player", GameSession.current_turn)
	_start_throw_physics(direction, strength)

	# Sync to clients
	if (
		GameSession.selected_mode == "Local"
		and multiplayer
		and multiplayer.is_server()
	):
		sync_throw.rpc(direction, strength)

	# Offline modes still need to advance the turn and spawn the next bag.
	var should_schedule_next_bag := GameSession.selected_mode != "Local"
	if (
		GameSession.selected_mode == "Local"
		and multiplayer
		and multiplayer.is_server()
	):
		should_schedule_next_bag = true

	if should_schedule_next_bag:
		await get_tree().create_timer(1.5).timeout
		call_deferred("request_next_bag")


@rpc("authority", "reliable")
func sync_throw(direction: Vector3, strength: float) -> void:
	if multiplayer.is_server():
		return

	_start_throw_physics(direction, strength)


func request_next_bag() -> void:
	var scoring_player: int = GameSession.current_turn

	if has_meta("throw_player"):
		scoring_player = int(get_meta("throw_player"))

	var bag_score: int = int(get_meta("awarded_points", 0))

	var uses_bag_result_slots := (
		GameSession.selected_mode == "PassPlay"
		or GameSession.selected_mode == "Local"
	)

	if uses_bag_result_slots:
		var bag_result_index := GameSession.record_bag_result(
			scoring_player,
			bag_score
		)

		set_meta("bag_result_index", bag_result_index)
		set_meta("awarded_points", bag_score)
	# deactivate_bag()
	GameSession.on_bag_thrown()
	var next_throw_player := GameSession.current_turn

	if GameSession.match_over:
		return

	if GameSession.selected_mode == "Local":
		if multiplayer and multiplayer.is_server():
			var spawn_point := get_parent()
			if is_instance_valid(spawn_point):
				spawn_point.call_deferred("spawn_bag", next_throw_player)
				spawn_point.rpc("spawn_bag_rpc", next_throw_player)
	else:
		get_parent().call_deferred("spawn_bag", next_throw_player)


func _is_my_turn() -> bool:
	if not multiplayer or multiplayer.multiplayer_peer == null:
		return true

	var my_id := 1 if multiplayer.is_server() else 2

	print("TURN:", GameSession.current_turn, " MY ID:", my_id)

	return GameSession.current_turn == my_id


func _on_body_entered(body: Node) -> void:
	SoundManager.play_bag_drop()
	if body.has_method("on_bag_landed"):
		body.on_bag_landed(self)
		return

	if _is_ground_body(body):
		_handle_ground_after_board()

func deactivate_bag():
	freeze = true
	sleeping = true


func _is_ground_body(body: Node) -> bool:
	return body is StaticBody3D and body.name == "Ground"


func _handle_ground_after_board() -> void:
	if GameSession.selected_mode == "Local":
		if not multiplayer or multiplayer.multiplayer_peer == null or not multiplayer.is_server():
			return

	if bool(get_meta(POINTER_SCORED_META, false)):
		return
	if not bool(get_meta(TOUCHED_BOARD_META, false)):
		return

	var awarded_points := int(get_meta(AWARDED_POINTS_META, 0))
	if awarded_points <= 0:
		return

	var scoring_player: int = int(get_meta("throw_player", GameSession.current_turn))
	set_meta(AWARDED_POINTS_META, 0)
	GameSession.add_score(scoring_player, -awarded_points)
	GameSession.pots_update.emit()

	if has_meta("bag_result_index"):
		GameSession.update_bag_result(scoring_player, int(get_meta("bag_result_index")), 0)

	if GameSession.selected_mode == "Local" and GameSession.mode_logic and GameSession.mode_logic.has_method("sync_match_state"):
		GameSession.mode_logic.sync_match_state()
