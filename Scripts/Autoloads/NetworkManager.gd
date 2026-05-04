extends Node

# ─── CONSTANTS ────────────────────────────
const PORT := 7777
const MAX_PLAYERS := 2
const DISCOVERY_PORT := 8888

# ─── STATE ────────────────────────────────
var is_host: bool = false
var my_id: int = 0
var players: Dictionary = {}

# UDP
var udp := PacketPeerUDP.new()
var broadcast_timer: Timer
var found_servers: Array = []

# ─── SIGNALS ──────────────────────────────
signal player_connected(id: int)
signal player_disconnected(id: int)
signal connection_failed
signal server_disconnected
signal game_ready
signal server_found(server: Dictionary)

# ─── INIT ─────────────────────────────────
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# ─── HOST ─────────────────────────────────
func host_game() -> void:
	# 🔥 IMPORTANT FIX
	if multiplayer.multiplayer_peer != null:
		disconnect_game()

	is_host = true

	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)

	if error != OK:
		push_error("Failed to create server: " + str(error))
		return

	multiplayer.multiplayer_peer = peer
	my_id = multiplayer.get_unique_id()

	var my_data = {
		"id": my_id,
		"name": Prefs.get_string("username", "Host")
	}

	players[my_id] = my_data

	start_broadcast()

# ─── JOIN ─────────────────────────────────
func join_game(ip: String) -> void:
	is_host = false

	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, PORT)

	if error != OK:
		push_error("[Network] Failed to connect: " + str(error))
		connection_failed.emit()
		return

	multiplayer.multiplayer_peer = peer
	print("[Network] Connecting to:", ip)

# ─── RPC ──────────────────────────────────
@rpc("any_peer", "reliable")
func register_player(data: Dictionary):
	var sender_id = multiplayer.get_remote_sender_id()
	players[sender_id] = data

	print("[Network] Player registered:", sender_id)

	if is_host and players.size() == MAX_PLAYERS:
		print("[Network] Game Ready")

		# 🔥 PRINT FULL PLAYER LIST
		print("------ FINAL PLAYER LIST ------")
		for id in players:
			print("ID:", id, " Data:", players[id])
		print("-------------------------------")

		game_ready.emit()

# ─── CALLBACKS ────────────────────────────
func _on_peer_connected(id: int) -> void:
	print("[Network] Player connected:", id)
	player_connected.emit(id)

	if is_host:
		register_player.rpc_id(id, players[my_id])

func _on_peer_disconnected(id: int) -> void:
	print("[Network] Player disconnected:", id)
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_to_server() -> void:
	my_id = multiplayer.get_unique_id()

	var my_data = {
		"id": my_id,
		"name": Prefs.get_string("username", "Player")
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
	server_disconnected.emit()

# ─── DISCONNECT ───────────────────────────
func disconnect_game() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()  # 🔥 force close socket
	
	multiplayer.multiplayer_peer = null
	players.clear()
	is_host = false
	my_id = 0
	
	stop_broadcast()
	stop_search()

	print("[Network] Fully Disconnected")

# ─── BROADCAST (HOST) ─────────────────────
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
		"name": Prefs.get_string("username", "Host"),
		"port": PORT
	}
	udp.put_packet(JSON.stringify(msg).to_utf8_buffer())

func stop_broadcast() -> void:
	if broadcast_timer:
		broadcast_timer.queue_free()
		broadcast_timer = null

# ─── SEARCH (CLIENT) ──────────────────────
func start_search() -> void:
	udp.close()
	found_servers.clear()
	udp.bind(DISCOVERY_PORT)
	print("[Network] Searching...")

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
			"ip": ip,
			"port": data.get("port", PORT)
		}

		for s in found_servers:
			if s.ip == server.ip:
				return

		found_servers.append(server)
		print("[Network] Found:", server)
		server_found.emit(server)

# ─── UTILS ────────────────────────────────
func join_found_server(index: int) -> void:
	if index >= 0 and index < found_servers.size():
		join_game(found_servers[index].ip)

func get_local_ip() -> String:
	var addresses = IP.get_local_addresses()
	for address in addresses:
		if address.begins_with("192.168") or address.begins_with("10.") or address.begins_with("172."):
			return address
	return "127.0.0.1"

func is_connected_to_network() -> bool:
	return multiplayer.multiplayer_peer != null
