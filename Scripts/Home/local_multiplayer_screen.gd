extends CanvasLayer

const DEFAULT_STATUS_MESSAGE = "Host/search with a room id/name"
const ROOM_SEARCH_TIMEOUT_SECONDS = 5.0

@export var server_button_scene: PackedScene
@onready var container: VBoxContainer = $Panel/PanelBg/ScrollContainer/RoomsContent
@onready var room_input: LineEdit = $Panel/PanelBg/LineEdit
@onready var host_button: Button = $Panel/PanelBg/HostButton
@onready var join_button: Button = $Panel/PanelBg/JoinButton
@onready var status_label: Label = $Panel/PanelBg/Label

var shown_ips: Array = []
var pending_join_room_id: String = ""
var search_timeout_timer: Timer


func _ready() -> void:
	NetworkManager.server_found.connect(_on_server_found)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	NetworkManager.room_join_failed.connect(_on_room_join_failed)
	NetworkManager.game_ready.connect(_on_game_ready)
	search_timeout_timer = Timer.new()
	search_timeout_timer.one_shot = true
	search_timeout_timer.wait_time = ROOM_SEARCH_TIMEOUT_SECONDS
	search_timeout_timer.timeout.connect(_on_room_search_timeout)
	add_child(search_timeout_timer)
	_show_default_status()


func on_menu_opened() -> void:
	_show_default_status()


func _on_cross_button_pressed() -> void:
	SoundManager.play_button_clicks()
	print("Closing multiplayer session")
	NetworkManager.disconnect_game()
	_cancel_room_search_timeout()
	clear_server_list()
	pending_join_room_id = ""
	host_button.disabled = false
	join_button.disabled = false
	room_input.editable = true
	_show_default_status()
	UIManager.toggle_canvas(self)


func _on_host_button_pressed() -> void:
	SoundManager.play_button_clicks()
	var room_name := room_input.text.strip_edges()
	if room_name.is_empty():
		_set_status("Enter a room name first")
		return

	_cancel_room_search_timeout()
	clear_server_list()
	pending_join_room_id = ""
	host_button.disabled = true
	join_button.disabled = true
	room_input.editable = false
	NetworkManager.hosted_room_name = room_name
	NetworkManager.hosted_room_id = _normalize_room_id(room_name)
	_set_status("Hosting room ID: " + NetworkManager.hosted_room_id)
	NetworkManager.host_game()
	print("Hosting... Waiting for player")


func _on_join_button_pressed() -> void:
	SoundManager.play_button_clicks()
	var room_id := _normalize_room_id(room_input.text)
	if room_id.is_empty():
		_set_status("Enter a room ID first")
		return

	clear_server_list()
	pending_join_room_id = room_id
	host_button.disabled = true
	join_button.disabled = true
	room_input.editable = true
	_set_status("Searching for room ID: " + room_id)
	var search_started = NetworkManager.start_search()
	if not search_started:
		host_button.disabled = false
		join_button.disabled = false
		room_input.editable = true
		pending_join_room_id = ""
		return
	_start_room_search_timeout()


func _on_server_found(server: Dictionary) -> void:
	if server.ip in shown_ips:
		return

	var room_id := _normalize_room_id(str(server.get("room_id", "")))
	if not pending_join_room_id.is_empty() and room_id != pending_join_room_id:
		return

	shown_ips.append(server.ip)

	var player_count := int(server.get("player_count", 0))
	var max_players := int(server.get("max_players", 2))
	var is_full := player_count >= max_players

	var btn := server_button_scene.instantiate() as Button
	btn.text = "%s [%s] %d/%d" % [server.name, room_id, player_count, max_players]
	btn.disabled = is_full
	if not is_full:
		btn.pressed.connect(func():
			print("Joining:", server.ip)
			_set_status("Joining room ID: " + room_id)
			_cancel_room_search_timeout()
			NetworkManager.stop_search()
			NetworkManager.join_game(server.ip)
		)

	container.add_child(btn)

	if pending_join_room_id.is_empty():
		return

	if is_full:
		_cancel_room_search_timeout()
		NetworkManager.stop_search()
		host_button.disabled = false
		join_button.disabled = false
		pending_join_room_id = ""
		_set_status("Room already full")
		return

	_set_status("Joining room ID: " + room_id)
	_cancel_room_search_timeout()
	NetworkManager.stop_search()
	NetworkManager.join_game(server.ip)


func clear_server_list() -> void:
	shown_ips.clear()
	for child in container.get_children():
		child.queue_free()


func _on_connection_failed() -> void:
	print("Connection Failed")
	_cancel_room_search_timeout()
	host_button.disabled = false
	join_button.disabled = false
	room_input.editable = true
	pending_join_room_id = ""
	_set_status("Connection failed")


func _on_room_join_failed(message: String) -> void:
	_cancel_room_search_timeout()
	host_button.disabled = false
	join_button.disabled = false
	room_input.editable = true
	pending_join_room_id = ""
	_set_status(message)


func _on_game_ready() -> void:
	_cancel_room_search_timeout()
	_set_status("Room full. Starting match...")


func _set_status(message: String) -> void:
	status_label.text = message
	status_label.visible = not message.is_empty()


func _show_default_status() -> void:
	if not pending_join_room_id.is_empty():
		return
	if not host_button.disabled and not join_button.disabled:
		_set_status(DEFAULT_STATUS_MESSAGE)


func _start_room_search_timeout() -> void:
	if search_timeout_timer == null:
		return

	search_timeout_timer.start()


func _cancel_room_search_timeout() -> void:
	if search_timeout_timer == null or search_timeout_timer.is_stopped():
		return

	search_timeout_timer.stop()


func _on_room_search_timeout() -> void:
	if pending_join_room_id.is_empty():
		return

	NetworkManager.stop_search()
	host_button.disabled = false
	join_button.disabled = false
	room_input.editable = true
	pending_join_room_id = ""
	_set_status("Room not found!!! Refresh")


func _normalize_room_id(value: String) -> String:
	return value.strip_edges().to_upper()
