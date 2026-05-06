extends RigidBody3D

@onready var swipe_controller: SwipeInputController = $SwipeInputController

var thrown: bool = false

@export var throw_gravity_scale: float = 4.0


func _ready() -> void:
	print("NODE PATH:", get_path(), " AUTH:", get_multiplayer_authority())

	thrown = false
	freeze = true
	sleeping = false

	contact_monitor = true
	max_contacts_reported = 8

	# Prevent duplicate signal connections after rematch
	if not swipe_controller.swipe_completed.is_connected(_on_swipe_completed):
		swipe_controller.swipe_completed.connect(_on_swipe_completed)

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_swipe_completed(direction: Vector3, strength: float) -> void:
	if thrown:
		return

	# Offline
	if GameSession.selected_mode != "Local":
		_apply_throw(direction, strength)
		return
	#thrown=true
	# No multiplayer
	if not multiplayer or multiplayer.multiplayer_peer == null:
		return

	# Turn check (client-side guard)
	if not _is_my_turn():
		print("Blocked: Not your turn")
		return

	# Host executes directly
	if multiplayer.is_server():
		_apply_throw(direction, strength)
	else:
		# Client sends request to server
		print("CLIENT sending RPC throw")
		request_throw.rpc_id(1, direction, strength)


func _apply_throw(direction: Vector3, strength: float, from_sync := false) -> void:
	if thrown:
		return

	# 🔴 Tag who threw this (important for scoring + validation)
	var throw_player := GameSession.current_turn
	set_meta("throw_player", throw_player)

	freeze = false
	gravity_scale = throw_gravity_scale
	apply_central_impulse(direction * strength)
	thrown = true

	# Server syncs to clients
	if GameSession.selected_mode == "Local" and multiplayer and multiplayer.is_server() and not from_sync:
		sync_throw.rpc(direction, strength)

	# Only server advances game
	if multiplayer and multiplayer.is_server():
		await get_tree().create_timer(1.5).timeout
		request_next_bag()


# =========================
# RPC: Client → Server
# =========================
@rpc("any_peer", "reliable")
func request_throw(direction: Vector3, strength: float) -> void:
	print("RPC HIT on peer:", multiplayer.get_unique_id(), " sender:", multiplayer.get_remote_sender_id())

	# Only server processes
	if not multiplayer or not multiplayer.is_server():
		return

	var sender_id: int = multiplayer.get_remote_sender_id()
	var sender_player := _player_id_for_peer(sender_id)

	print("SERVER: sender_player =", sender_player, " current_turn =", GameSession.current_turn)

	# Validate turn
	if sender_player != GameSession.current_turn:
		print("REJECTED THROW (wrong turn)")
		return

	print("ACCEPTED THROW")
	_apply_throw(direction, strength)


# =========================
# RPC: Server → Clients
# =========================
@rpc("authority", "reliable")
func sync_throw(direction: Vector3, strength: float) -> void:
	# Server ignores its own sync
	if multiplayer and multiplayer.is_server():
		return

	_apply_throw(direction, strength, true)


# =========================
# Turn + bag progression
# =========================
func request_next_bag() -> void:
	var scoring_player: int = GameSession.current_turn
	if has_meta("throw_player"):
		scoring_player = int(get_meta("throw_player"))

	var bag_score: int = int(get_meta("awarded_points", 0))
	var uses_bag_result_slots: bool = GameSession.selected_mode == "PassPlay" or GameSession.selected_mode == "Local"

	if uses_bag_result_slots:
		var bag_result_index: int = GameSession.record_bag_result(scoring_player, bag_score)
		set_meta("bag_result_index", bag_result_index)
		set_meta("awarded_points", bag_score)

	GameSession.on_bag_thrown()

	if GameSession.match_over:
		return

	if GameSession.selected_mode == "Local":
		if multiplayer and multiplayer.is_server():
			var bag = get_parent().spawn_bag()
			bag.name = "CornBag"
			# bag.set_multiplayer_authority(1)
			spawn_bag_rpc.rpc()
	else:
		get_parent().spawn_bag()


@rpc("authority", "reliable")
func spawn_bag_rpc() -> void:
	if multiplayer.is_server():
		return

	var bag = get_parent().spawn_bag()
	if bag:
		bag.name = "CornBag"
		# bag.set_multiplayer_authority(1)
		bag.thrown = false
		print("CLIENT SPAWNED BAG:", bag.get_path())
# =========================
# Helpers
# =========================
func _player_id_for_peer(peer_id: int) -> int:
	return 1 if peer_id == 1 else 2


func _is_my_turn() -> bool:
	if not multiplayer or multiplayer.multiplayer_peer == null:
		return true

	var my_id := 1 if multiplayer.is_server() else 2
	print("TURN:", GameSession.current_turn, " MY ID:", my_id)

	return GameSession.current_turn == my_id


func _on_body_entered(body: Node) -> void:
	if body.has_method("on_bag_landed"):
		body.on_bag_landed(self)
