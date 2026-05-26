extends Node
 

signal local_data_loaded
# ── Profile ───────────────────────────────────────────────────────
var player_id: String = ""
var player_name: String = ""
var status: String = ""
var last_claim_time:float = 0.0
var reward_day:int = 1
 
# ── Stats ─────────────────────────────────────────────────────────
var elo: int = 1000
var matches_won: int = 0
var matches_lost: int = 0
var matches_played: int = 0
var kd: float = 1.0
var total_pots: int = 0
var rank: String = ""
var rank_points: int = 0
var last_saved_timestamp: int = 0  # Unix timestamp (equivalent of lastSavedTicks)
 
# ── Inventory ─────────────────────────────────────────────────────
var equipped_cornbag: String = "S3"
var equipped_board: String = "B6"
var bags_owned: Array = ["S3","S16"]
var boards_owned: Array = ["B6"]
 
# ── Miscellaneous ─────────────────────────────────────────────────
var coins: int = 0
var achievements: int = 0
var daily_rewards_taken: int = 0
var login_method: String = ""
var needs_cloud_sync: bool = false
var IAP: bool = false
var check_logged_in : bool = false
var has_loaded_data: bool = false
# Logged in device type
var device_type: String = "unknown"  # android / ios / pc / web / unknown
var device_id: String = ""
const DEVICE_ID_PATH = "user://device_id.txt"
var session_id: String = ""
var session_active: bool = false

 
# ── Local save path ───────────────────────────────────────────────
const SAVE_PATH = "user://playerData.json"
const SESSION_PATH = "user://loginSession.json"
 
func _ready():
	get_or_create_device_id()
	if player_id != "":
		check_logged_in = true
	# print("LOGGED IN: ",check_logged_in)
 
 
func reset_defaults():
	player_id = ""
	player_name = ""
	status = ""
	elo = 1000
	matches_won = 0
	matches_lost = 0
	matches_played = 0
	kd = 1.0
	total_pots = 0
	rank = ""
	rank_points = 0
	last_saved_timestamp = 0
	equipped_cornbag = "S3"
	equipped_board = "B6"
	bags_owned = ["S3","S16"]
	boards_owned = ["B6"]
	coins = 0
	achievements = 0
	daily_rewards_taken = 0
	login_method = ""
	device_type = ""
	check_logged_in = false	
	has_loaded_data = false
	last_claim_time = 0.0
	reward_day = 1
 
func save_login_session(uid: String, method: String = ""):
	check_logged_in = uid != ""
	var data = {
		"logged_in": check_logged_in,
		"player_id": uid,
		"login_method": method
	}
	var file = FileAccess.open(SESSION_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
 
func has_saved_login_session() -> bool:
	var data = get_saved_login_session()
	check_logged_in = not data.is_empty() and bool(data.get("logged_in", false)) and str(data.get("player_id", "")) != ""
	return check_logged_in

func get_saved_login_session() -> Dictionary:
	if not FileAccess.file_exists(SESSION_PATH):
		return {}
	var file = FileAccess.open(SESSION_PATH, FileAccess.READ)
	if not file:
		return {}
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data is Dictionary:
		return data
	return {}

func get_saved_session_uid() -> String:
	return str(get_saved_login_session().get("player_id", ""))

func get_saved_session_method() -> String:
	return str(get_saved_login_session().get("login_method", "saved_session"))
 
func clear_login_session():
	check_logged_in = false
	if FileAccess.file_exists(SESSION_PATH):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove("loginSession.json")
			

# ─────────────────────────────────────────────────────────────────
func has_skin(skin_id: String) -> bool:
	return bags_owned.has(skin_id) or boards_owned.has(skin_id)
 
# ── Save to local disk ────────────────────────────────────────────
func save_local():
	if player_id == "" or not has_loaded_data:
		return
	last_saved_timestamp = int(Time.get_unix_time_from_system())
	var data = {
		"needs_cloud_sync": needs_cloud_sync,
 
		"Profile": {
			"player_name": player_name,
			"status": status,
			"leaderboard_score": coins,
			"last_saved_timestamp": last_saved_timestamp,
			"Device_type": device_type,
			"last_claim_time": last_claim_time,
			"reward_day": reward_day,
			"LoginMethod": login_method,
		},
 
		"Stats": {
			"Coins": coins,
			"ELO": elo,
			"MatchesWon": matches_won,
			"MatchesLost": matches_lost,
			"MatchesPlayed": matches_played,
			"kd": kd,
			"TotalPots": total_pots,
			"Rank": rank,
			"RankPoints": rank_points,
			"last_saved_timestamp": last_saved_timestamp
		},
 
		"Inventory": {
			"BagEquipped": equipped_cornbag,
			"BoardEquipped": equipped_board,
			"BagsOwned": bags_owned,
			"BoardsOwned": boards_owned
		}
 
		# "Misc": {
		# 	"Coins": coins,
		# 	"Achievements": achievements,
		# 	"DailyRewardsTaken": daily_rewards_taken,
		# 	"LoginMethod": login_method,
		# 	"In-App-Purchase": IAP,
		# 	"DisplayAds": !IAP
		# }
	}
	var file = FileAccess.open(get_save_path(), FileAccess.WRITE)
	get_save_path()
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
	else:
		pass


func get_save_path() -> String:
	if player_id == "":
		return SAVE_PATH  # user://playerData.json
	# print("user://playerData_%s.json" % player_id)	
	return "user://playerData_%s.json" % player_id  # user://playerData_abc123.json		
 
# ── Load from local disk ──────────────────────────────────────────
func load_local() -> bool:
	var save_path = get_save_path()
	if not FileAccess.file_exists(save_path):
		return false
	var file = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return false
	var json_string = file.get_as_text()
	file.close()
	var data = JSON.parse_string(json_string)
	if data == null:
		return false
 
	if data.has("needs_cloud_sync"):
		needs_cloud_sync = data["needs_cloud_sync"]
 
	# 🔥 Apply each section
	if data.has("Profile"):
		apply_dict(data["Profile"])
 
	if data.has("Stats"):
		apply_dict(data["Stats"])
 
	if data.has("Inventory"):
		apply_dict(data["Inventory"])
 
	# if data.has("Misc"):
	# 	apply_dict(data["Misc"])
		
	# Inside apply_dict()
	if data.has("last_saved_timestamp"):
		last_saved_timestamp = data["last_saved_timestamp"]
 
	has_loaded_data = true
	local_data_loaded.emit()
	return true
 
 
# ── Read only the timestamp from disk (no overwrite) ─────────────
func read_local_timestamp() -> int:
	var save_path = get_save_path()
	if not FileAccess.file_exists(save_path):
		return 0
	var file = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return 0
	var result = JSON.parse_string(file.get_as_text())
	file.close()
	if result and result.has("Profile"):
		return int(result["Profile"].get("last_saved_timestamp", 0))
 
	return 0
 
# ── Apply a dict (from Firestore or local) to live data ──────────
func apply_dict(data: Dictionary):
	player_id    = data.get("player_id", player_id)
	player_name  = data.get("player_name", player_name)
	status       = data.get("status", status)
	elo          = data.get("ELO", data.get("elo", elo))
	matches_won  = data.get("MatchesWon", data.get("matches_won", matches_won))
	matches_lost = data.get("MatchesLost", data.get("matches_lost", matches_lost))
	matches_played = data.get("MatchesPlayed", data.get("matches_played",matches_played))
	kd           = float(data.get("kd", kd))
	total_pots   = data.get("TotalPots", data.get("total_pots", total_pots))
	rank         = data.get("Rank", data.get("rank", rank))
	rank_points  = data.get("RankPoints", data.get("rank_points", rank_points))
	coins        = data.get("Coins", data.get("coins", coins))
	achievements = data.get("Achievements", data.get("achievements", achievements))
	daily_rewards_taken = data.get("DailyRewardsTaken", data.get("daily_rewards_taken", daily_rewards_taken))
	login_method = data.get("LoginMethod", data.get("login_method", login_method))
	last_saved_timestamp = data.get("last_saved_timestamp", last_saved_timestamp)
	last_claim_time = float(data.get("last_claim_time", last_claim_time))
	reward_day = int(data.get("reward_day", reward_day))

	print("claim data",last_claim_time)
	print("reward day",reward_day)
 
	# Equipped items
	var bag = data.get("BagEquipped", data.get("equipped_cornbag", ""))
	if bag != "":
		equipped_cornbag = bag
	var board = data.get("BoardEquipped", data.get("equipped_board", ""))
	if board != "":
		equipped_board = board
 
	# ── Arrays need explicit casting ──────────────────────────────
	if data.has("BagsOwned") or data.has("bags_owned"):
		bags_owned = _extract_array(data.get("BagsOwned", data.get("bags_owned", [])))   # cast to plain Array
 
	if data.has("BoardsOwned") or data.has("boards_owned"):
		boards_owned = _extract_array(data.get("BoardsOwned", data.get("boards_owned", [])))
	
	# Inside apply_dict()
	if data.has("last_saved_timestamp"):
		last_saved_timestamp = data["last_saved_timestamp"]
 
# ── Helper to handle all possible Firestore array formats ─────────
func _extract_array(value) -> Array:
	if value == null:
		return []
	# Plain GDScript array
	if value is Array:
		return value
	# GDFirebase wraps arrays in a dict like {"values": [...]}
	if value is Dictionary:
		if value.has("values"):
			var result = []
			for item in value["values"]:
				# Each item is {"stringValue": "..."} or {"integerValue": ...}
				if item is Dictionary:
					if item.has("stringValue"):
						result.append(str(item["stringValue"]))
					elif item.has("integerValue"):
						result.append(int(item["integerValue"]))
					elif item.has("doubleValue"):
						result.append(float(item["doubleValue"]))
				else:
					result.append(item)
			return result
	# Single string value accidentally stored as string
	if value is String and value != "":
		return [value]
	return []
 
func _apply_json(json_string: String) -> bool:
	var result = JSON.parse_string(json_string)
	if result == null:
		return false
	# Apply each section separately
	if result.has("Profile"):
		apply_dict(result["Profile"])
 
	if result.has("Stats"):
		apply_dict(result["Stats"])
 
	if result.has("Inventory"):
		apply_dict(result["Inventory"])
 
	# if result.has("Misc"):
	# 	apply_dict(result["Misc"])
	return true
 
# ── Auto-save on quit / pause ─────────────────────────────────────
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_local()  # always save locally
		# Force immediate Firestore sync on exit
		# if FirebaseManager._sync_pending:
		# 	FirebaseManager._push_to_firestore()
 

func peek_local_timestamp() -> int:
	# Read the save file and return only the timestamp, don't apply anything
	var path = get_save_path()
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return 0
	var json = JSON.parse_string(file.get_as_text())
	file.close()
	if json is Dictionary:

		# Check Profile section
		if json.has("Profile"):

			var profile_data = json["Profile"]
			print(profile_data)

			if profile_data is Dictionary:
				return int(profile_data.get("last_saved_timestamp", 0))
	return 0


func get_or_create_device_id() -> String:
	if device_id != "":
		return device_id

	# Try reading from file
	if FileAccess.file_exists(DEVICE_ID_PATH):
		var file = FileAccess.open(DEVICE_ID_PATH, FileAccess.READ)
		device_id = file.get_as_text().strip_edges()
		file.close()

		if device_id != "":
			return device_id

	# Generate new unique ID (better than timestamp + randi)
	device_id = _generate_device_id()

	# Save locally
	var file = FileAccess.open(DEVICE_ID_PATH, FileAccess.WRITE)
	file.store_string(device_id)
	file.close()

	return device_id


func _generate_device_id() -> String:
	var base = str(Time.get_unix_time_from_system()) + "_" + str(randi()) + "_" + str(OS.get_unique_id())
	return base.sha256_text()  # hashed → fixed length + secure
 
func detect_device_type():
	var os_name = OS.get_name()
 
	match os_name:
		"Android":
			device_type = "android"
		"iOS":
			device_type = "ios"
		"Windows", "Linux", "macOS":
			device_type = "pc"
		"Web":
			device_type = "web"
		_:
			device_type = "unknown"
