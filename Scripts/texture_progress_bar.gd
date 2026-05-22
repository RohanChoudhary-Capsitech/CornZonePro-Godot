extends TextureProgressBar
var _tween: Tween
var _fetch_done := 0
var _fetch_count := 3
var _current_progress := 0.0
const MILESTONE_AUTH   := 0.30
const MILESTONE_PLAYER := 0.65
const MILESTONE_CONFIG := 0.90
const MILESTONE_DONE   := 1.00
func _ready():
	value = 0
	# first launch — no auth file exists yet, skip firebase entirely
	if not Firebase.Auth.check_auth_file():
		_start_offline_load()
		return
 
	if _is_online():
		_start_online_load()
	else:
		_start_offline_load()
# ── CONNECTIVITY ─────────────────────────────────────
func _is_online() -> bool:
	return HTTPClient.new().connect_to_host("8.8.8.8", 443) == OK
# ── OFFLINE ──────────────────────────────────────────
func _start_offline_load():
	_tween = create_tween()
	_tween.tween_property(self, "value", max_value, 5.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.finished.connect(_on_loading_finished)
# ── ONLINE ───────────────────────────────────────────
func _start_online_load():
	_crawl_to(MILESTONE_AUTH, 6.0)
	Firebase.Auth.login_succeeded.connect(_on_auth_done, CONNECT_ONE_SHOT)
	Firebase.Auth.login_failed.connect(_on_auth_failed, CONNECT_ONE_SHOT)
func _on_auth_failed(_err = null):
	_finish_loading()
func _on_auth_done(_result = null):
	_snap_to(MILESTONE_AUTH)
	_crawl_to(MILESTONE_PLAYER, 5.0)
	var uid: String = Firebase.Auth.auth.get("localid", "")
	if uid.is_empty():
		_on_player_done()
		return
	var player_task = Firebase.Firestore.collection("players").get(uid)
	if player_task:
		player_task.completed.connect(_on_player_done, CONNECT_ONE_SHOT)
	else:
		_on_player_done()
func _on_player_done(_result = null):
	_snap_to(MILESTONE_PLAYER)
	_crawl_to(MILESTONE_CONFIG, 4.0)
 
func _on_config_done(_result = null):
	_finish_loading()
# ── HELPERS ───────────────────────────────────────────
func _crawl_to(target: float, duration: float):
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "value", max_value * target, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
func _snap_to(target: float):
	if _tween and _tween.is_valid():
		_tween.kill()
	value = max_value * target
func _finish_loading():
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "value", max_value, 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.finished.connect(_on_loading_finished)
# ── SHARED ───────────────────────────────────────────
func _on_loading_finished():
	var val: int = int(Prefs.get_int("user", 0))
	if val == 1 and PlayerData.player_id != "":
		UIManager.enable_canvas(UIManager.home_screen)
	else:
		UIManager.enable_canvas(UIManager.login_screen)
