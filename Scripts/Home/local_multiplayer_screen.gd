extends CanvasLayer

@export var server_button_scene: PackedScene
@onready var container = $Panel/PanelBg/ScrollContainer/RoomsContent
@onready var host_button: Button = $Panel/PanelBg/HostButton
@onready var join_button: Button = $Panel/PanelBg/JoinButton

var shown_ips: Array = []

func _ready() -> void:
	NetworkManager.server_found.connect(_on_server_found)
	NetworkManager.connection_failed.connect(_on_connection_failed)

func _on_cross_button_pressed() -> void:
	print("Closing multiplayer session")
	NetworkManager.disconnect_game()
	clear_server_list()
	host_button.disabled = false
	join_button.disabled = false
	UIManager.toggle_canvas(self)

# ─── HOST ────────────────────────────────
func _on_host_button_pressed() -> void:
	clear_server_list()
	NetworkManager.host_game()
	join_button.disabled=true
	print("Hosting... Waiting for player")

# ─── SEARCH ──────────────────────────────
func _on_join_button_pressed() -> void:
	clear_server_list()
	host_button.disabled=true
	NetworkManager.start_search()

# ─── SERVER FOUND ────────────────────────
func _on_server_found(server: Dictionary) -> void:
	if server.ip in shown_ips:
		return
	
	shown_ips.append(server.ip)

	var btn = server_button_scene.instantiate()
	btn.text = server.name + " (" + server.ip + ")"
	
	btn.pressed.connect(func():
		print("Joining:", server.ip)
		NetworkManager.join_game(server.ip)
	)
	
	container.add_child(btn)

# ─── HELPERS ─────────────────────────────
func clear_server_list() -> void:
	shown_ips.clear()
	for child in container.get_children():
		child.queue_free()

func _on_connection_failed():
	print("Connection Failed")
