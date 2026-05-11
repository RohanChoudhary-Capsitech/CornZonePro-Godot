extends Node

# =========================
# CONSTANTS
# =========================
const PORT := 7777
const MAX_PLAYERS := 2
const MAX_REMOTE_CLIENTS := MAX_PLAYERS - 1
const DISCOVERY_PORT := 8888

const MAP_LIST := [
	"res://Scenes/Maps/street.tscn",
	"res://Scenes/Maps/stadium.tscn",
	"res://Scenes/Maps/backyard.tscn",
	"res://Scenes/Maps/metro.tscn",
	"res://Scenes/Maps/rooftop.tscn",
	"res://Scenes/Maps/lawn.tscn"
]

const HOST_DEFAULT_BAG_ID := "rogue"
const CLIENT_DEFAULT_BAG_ID := "neon"
const BAG_CONFIGS := {
	"rogue": preload("res://Resources/Bags/Rogue_bag.tres"),
	"neon": preload("res://Resources/Bags/Neon_bag.tres")
}

# =========================
# STATE
# =========================
var is_host: bool = false
var my_id: int = 0

var players: Dictionary = {}

# UDP Discovery
var udp := PacketPeerUDP.new()
var broadcast_timer: Timer
var found_servers: Array = []
var rematch_in_progress: bool = false
var pending_rematch_requester_id: int = 0
var outgoing_rematch_target_id: int = 0

# =========================
# SIGNALS
# =========================
signal player_connected(id: int)
signal player_disconnected(id: int)

signal connection_failed
signal server_disconnected

signal game_ready
signal server_found(server: Dictionary)

signal match_forfeit(reason: String)
signal room_join_failed(message: String)

signal rematch_requested
signal rematch_declined(message: String)

var hosted_room_name: String = ""
var hosted_room_id: String = ""


# =========================
# INIT
# # =========================
# func _ready() -> void:

# 	multiplayer.peer_connected.connect(_on_peer_connected)
# 	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

# 	multiplayer.connected_to_server.connect(_on_connected_to_server)
# 	multiplayer.connection_failed.connect(_on_connection_failed)
# 	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _ready() -> void:
	_connect_multiplayer_signals()
# =========================
# HOST
# =========================
func host_game(room_name: String = "") -> void:
	if multiplayer.multiplayer_peer != null:
		await get_tree().process_frame
		disconnect_game()
		await get_tree().process_frame

	is_host = true
	var normalized_room_name := room_name.strip_edges()
	if normalized_room_name.is_empty():
		normalized_room_name = hosted_room_name.strip_edges()
	if normalized_room_name.is_empty():
		normalized_room_name = "%s's Room" % Prefs.get_string("username", "Host")

	hosted_room_name = normalized_room_name
	hosted_room_id = _normalize_room_id(hosted_room_name)

	var peer = ENetMultiplayerPeer.new()

	var error = peer.create_server(PORT, MAX_REMOTE_CLIENTS)

	if error != OK:
		is_host = false
		hosted_room_name = ""
		hosted_room_id = ""
		push_error("Failed to create server")
		room_join_failed.emit("Failed to create room")
		return

	multiplayer.multiplayer_peer = peer

	my_id = multiplayer.get_unique_id()

	var my_data = {
		"id": my_id,
		"name": Prefs.get_string("username", "Host"),
		"bag_id": get_local_bag_id()
	}

	players[my_id] = my_data

	start_broadcast()


# =========================
# JOIN
# =========================
func join_game(ip: String) -> void:
	if multiplayer.multiplayer_peer != null:
		await get_tree().process_frame
		disconnect_game()
		await get_tree().process_frame

	is_host = false

	var peer = ENetMultiplayerPeer.new()

	var error = peer.create_client(ip, PORT)

	if error != OK:
		connection_failed.emit()
		return

	multiplayer.multiplayer_peer = peer

	print("[Network] Connecting to:", ip)


# =========================
# MATCH START
# =========================
func get_random_map() -> String:
	return MAP_LIST[randi() % MAP_LIST.size()]


@rpc("any_peer", "reliable")
func register_player(data: Dictionary):
	var sender_id = multiplayer.get_remote_sender_id()
	if is_host and not players.has(sender_id) and players.size() >= MAX_PLAYERS:
		room_full_rpc.rpc_id(sender_id, "Room already full")
		_disconnect_peer(sender_id)
		return

	players[sender_id] = data

	print("[Network] Player registered:", sender_id)

	if is_host and players.size() == MAX_PLAYERS:
		print("[Network] Game Ready")

		var map = get_random_map()

		start_match_rpc.rpc(map)

		if multiplayer.is_server():
			start_match_rpc(map)

		game_ready.emit()


@rpc("any_peer", "reliable")
func start_match_rpc(map_path: String):
	print("[RPC RECEIVED] Loading:", map_path)
	rematch_in_progress = false
	_clear_rematch_request_state()

	GameSession.start_match("Local", map_path, "Local", 20.0)

	SceneManager.preload_async(map_path)

	await SceneManager.wait_until_loaded(map_path)

	SceneManager.goto(map_path)


# =========================
# REMATCH
# =========================
func send_rematch_request() -> void:
	if rematch_in_progress:
		return

	for id in players.keys():
		if id != multiplayer.get_unique_id():
			outgoing_rematch_target_id = int(id)
			receive_rematch_request.rpc_id(id)


@rpc("any_peer", "reliable")
func receive_rematch_request() -> void:
	if rematch_in_progress:
		return

	pending_rematch_requester_id = multiplayer.get_remote_sender_id()
	rematch_requested.emit()


@rpc("any_peer", "reliable")
func accept_rematch() -> void:
	if rematch_in_progress:
		return

	if multiplayer.is_server():
		var mode := GameSession.selected_mode
		var map_path := GameSession.selected_map_path
		var ui := GameSession.required_ui
		var time_limit := GameSession.time_left

		_begin_rematch(mode, map_path, ui, time_limit)


func reject_rematch() -> void:
	if not multiplayer or multiplayer.multiplayer_peer == null:
		return

	if multiplayer.is_server():
		if pending_rematch_requester_id > 0:
			rematch_declined_rpc.rpc_id(
				pending_rematch_requester_id,
				"Opponent declined rematch"
			)
		_clear_rematch_request_state()
	else:
		decline_rematch.rpc_id(1)
		_clear_rematch_request_state()


@rpc("any_peer", "reliable")
func decline_rematch() -> void:
	if not multiplayer.is_server():
		return

	rematch_declined.emit("Opponent declined rematch")
	_clear_rematch_request_state()


@rpc("authority", "reliable")
func rematch_declined_rpc(message: String) -> void:
	rematch_declined.emit(message)
	_clear_rematch_request_state()


@rpc("authority", "reliable")
func start_rematch(
	mode: String,
	map_path: String,
	ui: String,
	time_limit: float
) -> void:
	rematch_in_progress = true
	UIManager.restart(mode, map_path, ui, time_limit)


func _begin_rematch(
	mode: String,
	map_path: String,
	ui: String,
	time_limit: float
) -> void:
	if mode.is_empty() or map_path.is_empty():
		push_warning("[Network] Cannot rematch without an active match")
		return

	rematch_in_progress = true
	start_rematch.rpc(mode, map_path, ui, time_limit)
	start_rematch(mode, map_path, ui, time_limit)
	_clear_rematch_request_state()


# =========================
# THROW RPC
# =========================
@rpc("any_peer", "reliable")
func request_throw(direction: Vector3, strength: float) -> void:
	if not multiplayer.is_server():
		return

	var bag: Node = null
	var latest_spawn_index := -1

	for node in get_tree().get_nodes_in_group("active_bag"):
		if not is_instance_valid(node):
			continue
		if not node.has_method("is_waiting_for_throw"):
			continue
		if not bool(node.call("is_waiting_for_throw")):
			continue

		var spawn_index := int(node.get_meta("bag_spawn_index", -1))
		if spawn_index > latest_spawn_index:
			latest_spawn_index = spawn_index
			bag = node

	if bag == null:
		print("NO ACTIVE BAG")
		return

	var sender_id := multiplayer.get_remote_sender_id()

	var sender_player := 1 if sender_id == 1 else 2

	if sender_player != GameSession.current_turn:
		print("WRONG TURN")
		return

	bag.call("server_apply_throw", direction, strength)


# =========================
# CALLBACKS
# =========================
func _on_peer_connected(id: int) -> void:
	print("[Network] Player connected:", id)
	if is_host and players.size() >= MAX_PLAYERS:
		room_full_rpc.rpc_id(id, "Room already full")
		_disconnect_peer(id)
		return

	player_connected.emit(id)

	if is_host:
		register_player.rpc_id(id, players[my_id])


func _on_peer_disconnected(id: int) -> void:
	print("[Network] Player disconnected:", id)

	players.erase(id)

	player_disconnected.emit(id)

	if not GameSession.match_over:
		if is_host:
			match_forfeit.emit("client left")


func _on_connected_to_server() -> void:
	my_id = multiplayer.get_unique_id()

	var my_data = {
		"id": my_id,
		"name": Prefs.get_string("username", "Player"),
		"bag_id": get_local_bag_id()
	}

	register_player.rpc_id(1, my_data)

	print("[Network] Connected ID:", my_id)


func _on_connection_failed() -> void:
	print("[Network] Connection failed")

	multiplayer.multiplayer_peer = null

	connection_failed.emit()


func _on_server_disconnected() -> void:
	print("[Network] Server disconnected")

	disconnect_game()

	if not GameSession.match_over:
		match_forfeit.emit("host left")

	server_disconnected.emit()


# =========================
# DISCONNECT
# =========================
func disconnect_game() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()

	multiplayer.multiplayer_peer = null

	players.clear()
	hosted_room_name = ""
	hosted_room_id = ""
	rematch_in_progress = false
	_clear_rematch_request_state()

	is_host = false
	my_id = 0

	stop_broadcast()
	stop_search()

	print("[Network] Fully Disconnected")

# =========================
# BROADCAST
# =========================
func start_broadcast() -> void:
	udp.close()

	udp.set_broadcast_enabled(true)

	udp.set_dest_address("255.255.255.255", DISCOVERY_PORT)

	broadcast_timer = Timer.new()

	broadcast_timer.wait_time = 1.0
	broadcast_timer.autostart = true

	broadcast_timer.timeout.connect(_broadcast_ping)

	add_child(broadcast_timer)


func _broadcast_ping() -> void:
	var msg = {
		"name": hosted_room_name if not hosted_room_name.is_empty() else Prefs.get_string("username", "Host"),
		"room_id": hosted_room_id if not hosted_room_id.is_empty() else _normalize_room_id(Prefs.get_string("username", "Host")),
		"player_count": players.size(),
		"max_players": MAX_PLAYERS,
		"port": PORT
	}

	udp.put_packet(JSON.stringify(msg).to_utf8_buffer())


func stop_broadcast() -> void:
	if broadcast_timer:
		broadcast_timer.queue_free()
		broadcast_timer = null


# =========================
# SEARCH
# =========================
func start_search() -> bool:
	udp.close()

	found_servers.clear()

	var error := udp.bind(DISCOVERY_PORT)
	if error != OK:
		var message := "Unable to search for rooms: " + error_string(error)
		push_error("[Network] " + message)
		room_join_failed.emit(message)
		return false

	print("[Network] Searching...")
	return true


func stop_search() -> void:
	udp.close()


func _process(_delta: float) -> void:
	if udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()

		var ip = udp.get_packet_ip()

		var data = JSON.parse_string(packet.get_string_from_utf8())

		if typeof(data) != TYPE_DICTIONARY:
			return

		var server = {
			"name": data.get("name", "Unknown"),
			"room_id": _normalize_room_id(str(data.get("room_id", data.get("name", "")))),
			"ip": ip,
			"player_count": int(data.get("player_count", 0)),
			"max_players": int(data.get("max_players", MAX_PLAYERS)),
			"port": data.get("port", PORT)
		}

		for s in found_servers:
			if s.ip == server.ip:
				return

		found_servers.append(server)

		print("[Network] Found:", server)

		server_found.emit(server)


# =========================
# UTILS
# =========================
func join_found_server(index: int) -> void:
	if index >= 0 and index < found_servers.size():
		join_game(found_servers[index].ip)


func get_local_ip() -> String:
	var addresses = IP.get_local_addresses()

	for address in addresses:
		if (
			address.begins_with("192.168")
			or address.begins_with("10.")
			or address.begins_with("172.")
		):
			return address

	return "127.0.0.1"


func is_connected_to_network() -> bool:
	return multiplayer.multiplayer_peer != null


func get_saved_equipped_bag_id(pref_key: String = "equipped_bag_id") -> String:
	var bag_id := str(Prefs.get_string(pref_key, "")).to_lower()
	if BAG_CONFIGS.has(bag_id):
		return bag_id

	return ""


func get_local_bag_id() -> String:
	var bag_id := get_saved_equipped_bag_id()
	if not bag_id.is_empty():
		return bag_id

	return HOST_DEFAULT_BAG_ID if is_host else CLIENT_DEFAULT_BAG_ID


func get_bag_config_for_player(player_index: int) -> BagConfig:
	var bag_id := get_bag_id_for_player(player_index)
	return get_bag_config_by_id(bag_id)


func get_bag_config_by_id(bag_id: String) -> BagConfig:
	var normalized_bag_id := bag_id.to_lower()
	if BAG_CONFIGS.has(normalized_bag_id):
		return BAG_CONFIGS[normalized_bag_id] as BagConfig

	return BAG_CONFIGS[HOST_DEFAULT_BAG_ID] as BagConfig


func get_bag_id_for_player(player_index: int) -> String:
	if GameSession.selected_mode == "Local":
		return _get_local_multiplayer_bag_id_for_player(player_index)
	if GameSession.selected_mode == "PassPlay":
		return _get_pass_play_bag_id_for_player(player_index)

	if player_index == 2:
		return get_alternate_bag_id(get_local_bag_id())

	return get_local_bag_id()


func get_alternate_bag_id(bag_id: String) -> String:
	var normalized_bag_id := bag_id.to_lower()
	if normalized_bag_id == HOST_DEFAULT_BAG_ID:
		return CLIENT_DEFAULT_BAG_ID
	if normalized_bag_id == CLIENT_DEFAULT_BAG_ID:
		return HOST_DEFAULT_BAG_ID

	return CLIENT_DEFAULT_BAG_ID


func _get_local_multiplayer_bag_id_for_player(player_index: int) -> String:
	var player_data := get_player_data_for_index(player_index)
	var bag_id := str(player_data.get("bag_id", "")).to_lower()
	var fallback_bag_id := HOST_DEFAULT_BAG_ID if player_index == 1 else CLIENT_DEFAULT_BAG_ID
	if not BAG_CONFIGS.has(bag_id):
		return fallback_bag_id

	var other_player_index := 2 if player_index == 1 else 1
	var other_player_data := get_player_data_for_index(other_player_index)
	var other_bag_id := str(other_player_data.get("bag_id", "")).to_lower()

	if BAG_CONFIGS.has(other_bag_id) and other_bag_id == bag_id:
		return fallback_bag_id

	return bag_id


func _get_pass_play_bag_id_for_player(player_index: int) -> String:
	var player_one_bag_id := get_saved_equipped_bag_id()
	if player_one_bag_id.is_empty():
		player_one_bag_id = HOST_DEFAULT_BAG_ID

	if player_index == 1:
		return player_one_bag_id

	var player_two_bag_id := get_saved_equipped_bag_id("equipped_bag_id_p2")
	if player_two_bag_id.is_empty() or player_two_bag_id == player_one_bag_id:
		player_two_bag_id = get_alternate_bag_id(player_one_bag_id)

	return player_two_bag_id


func get_player_data_for_index(player_index: int) -> Dictionary:
	if player_index == 1:
		return players.get(1, {})

	for peer_id in players.keys():
		if int(peer_id) != 1:
			return players.get(peer_id, {})

	return {}


func _clear_rematch_request_state() -> void:
	pending_rematch_requester_id = 0
	outgoing_rematch_target_id = 0


@rpc("authority", "reliable")
func room_full_rpc(message: String) -> void:
	room_join_failed.emit(message)
	disconnect_game()



func _connect_multiplayer_signals() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _normalize_room_id(value: String) -> String:
	return value.strip_edges().to_upper()


func _disconnect_peer(peer_id: int) -> void:
	var peer := multiplayer.multiplayer_peer as ENetMultiplayerPeer
	if peer == null:
		return

	peer.disconnect_peer(peer_id, true)
