extends Node

const PORT=7777
const MAX_PLAYERS=2

var is_host:bool = false
var my_id:int=0
var players:Dictionary={}


signal player_connected(id:int)
signal player_disconnected(id:int)
signal connection_failed
signal server_disconnected
signal client_disconnected
signal game_ready


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_game()->void:
	is_host=true
	
	var peer=ENetMultiplayerPeer.new()
	var error=peer.create_server(PORT,MAX_PLAYERS)
	
	if error!=OK:
		push_error("FAILED to create server: "+str(error))
		return
	
	multiplayer.multiplayer_peer=peer
	my_id=multiplayer.get_unique_id()
	print("Server created! My ID: ", my_id)
	print("Waiting for players...")
	
	players[my_id]={
		"id":my_id,
		"name":Prefs.get_string("Username","Player 1")
	}

func  join_game(ip: String)->void:
	is_host=false
	
	var peer=ENetMultiplayerPeer.new()
	var error=peer.create_client(ip,PORT)
	
	if error!=OK:
		push_error("FAILED to create server: "+str(error))
		connection_failed.emit()
		return
	
	multiplayer.multiplayer_peer=peer
	print("[Network] Connecting to:", ip)

@rpc("any_peer","reliable")
func register_player(data:Dictionary):
	var sender_id=multiplayer.get_remote_sender_id()
	players[sender_id]=data
	print("[Network] Registered player:", sender_id)
	
	if is_host and MAX_PLAYERS==players.size():
		print("[Network] All players ready")
		game_ready.emit()


func _on_peer_connected(id: int)->void:
	print("[Network] Player connected:", id)
	player_connected.emit(id)
	
	if is_host:
		var my_data=players[my_id]
		register_player.rpc_id(id,my_data)

func _on_peer_disconnected(id: int)->void:
	print("[Network] Player disconnected:", id)
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_to_server()->void:
	my_id=multiplayer.get_unique_id()
	var my_data = {
		"id": my_id,
		"name": Prefs.get_string("username", "Player")
	}
	
	register_player.rpc_id(1,my_data)
	print("[Network] Connected! My ID:", my_id)


func _on_connection_failed()->void:
	print("[Network] Connection failed!")
	multiplayer.multiplayer_peer = null
	connection_failed.emit()

func _on_server_disconnected()->void:
	print("[Network] Server disconnected!")
	disconnect_game()
	server_disconnected.emit()


func disconnect_game() -> void:
	multiplayer.multiplayer_peer = null
	players.clear()
	is_host = false
	my_id = 0
	print("[Network] Disconnected")


func get_local_ip() -> String:
	var addresses = IP.get_local_addresses()
	for address in addresses:
		if address.begins_with("192.168") or address.begins_with("10.") or address.begins_with("172."):
			print("[Network] Local IP:", address)
			return address
	return "127.0.0.1"

func is_connected_to_network() -> bool:
	return multiplayer.multiplayer_peer != null
