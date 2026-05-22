extends Control
 
var pending_login_method: String = ""
var user_name:String = ""
var online 
var _auth_flow_in_progress: bool = false
var _loaded_uid: String = ""
var samedevice:bool = false

signal account_created


func _log(msg):
	print("[AUTH] ", msg)
 
func _ready():
	cleanup_invalid_local_files()
	# _log("READY STARTED")
	
	if not Firebase.Auth.login_succeeded.is_connected(on_login_succeeded):
		Firebase.Auth.login_succeeded.connect(on_login_succeeded)
	if not Firebase.Auth.signup_succeeded.is_connected(on_signup_succeeded):
		Firebase.Auth.signup_succeeded.connect(on_signup_succeeded)
	if not Firebase.Auth.login_failed.is_connected(on_login_failed):
		Firebase.Auth.login_failed.connect(on_login_failed)
	if not Firebase.Auth.signup_failed.is_connected(on_signup_failed):
		Firebase.Auth.signup_failed.connect(on_signup_failed)
 
	# Detect logged in device
	PlayerData.detect_device_type()
	online = await FirebaseManager.internet_available()
	await _restore_saved_session()
 
func _restore_saved_session():
	# _log("RESTORE SESSION START")
	var has_local_session = PlayerData.has_saved_login_session()
	await get_tree().create_timer(0.5).timeout
	var has_auth_file = Firebase.Auth.check_auth_file()
	var saved_uid = PlayerData.get_saved_session_uid()
	online = await FirebaseManager.internet_available()

	if not online:
		_log("OFFLINE MODE")
		print("Starting in OFFLINE MODE")

		# User already logged in before
		if has_local_session and saved_uid != "":
			PlayerData.check_logged_in = true

			# Init manager without cloud access
			FirebaseManager.init(
				saved_uid,
				PlayerData.get_saved_session_method(),
				false
			)

			# Load LOCAL data only
			var loaded = await FirebaseManager.load_all(false)
			_log("Offline local load result = " + str(loaded))

			if loaded:
				# %StateLabel.text = "Offline Mode"
				_log("OFFLINE LOGIN SUCCESS")
				_change_to_profile()
				return

		# No saved session
		_show_auth_panel("No internet connection")
		_log("No internet and no local session")
		return

	if not has_local_session and not has_auth_file:
		_log("No local session and no auth file")
		_show_auth_panel()
		return
 
	if not has_auth_file and saved_uid == "":
		_log("Auth expired")
		_show_auth_panel("Please log in.")
		return
 
	#%StateLabel.text = "Logging in..."
	var uid = saved_uid
	if has_auth_file:
		_log("Auth file exists")
		await get_tree().process_frame
		if Firebase.Auth.auth.localid != "":
			uid = Firebase.Auth.auth.localid
	if uid == "":
		PlayerData.clear_login_session()
		_show_auth_panel("Session expired. Please log in.")
		return
	await _init_and_load(uid, "saved_session", false)
	
 
func _show_auth_panel(message: String = ""):
	pass
	#$VBoxContainer.visible = true
	#if message != "":
		#%StateLabel.text = message
 
func on_login_succeeded(auth):
	_log("LOGIN SUCCESS SIGNAL")
	var uid = Firebase.Auth.auth.localid
	if uid == "":
		print("ERROR: uid empty after login!")
		_log("Calling _init_and_load with uid = " + uid)
		return
	if _auth_flow_in_progress or _loaded_uid == uid:
		return

	_log("Firebase localid = " + str(Firebase.Auth.auth.localid))
	Firebase.Auth.save_auth(auth)
	PlayerData.check_logged_in = true
	await _init_and_load(uid, pending_login_method, pending_login_method == "anonymous")
 
func on_signup_succeeded(auth):
	print(auth)
	Firebase.Auth.save_auth(auth)
	PlayerData.check_logged_in = true
	var uid = Firebase.Auth.auth.localid
	if _auth_flow_in_progress or _loaded_uid == uid:
		return
	await _init_and_load(uid, pending_login_method, true)

 
func on_login_failed(error_code, message):
	print(error_code, message)
	_log("LOGIN FAILED")
	_log("Error code = " + str(error_code))
	_log("Message = " + str(message))
	PlayerData.check_logged_in = false

 
func on_signup_failed(error_code, message):
	_log("SIGNUP FAILED")
	_log("Error code = " + str(error_code))
	_log("Message = " + str(message))
	print(error_code, message)
	PlayerData.check_logged_in = false

 
func on_login_as_a_guest_pressed():
	_log("GUEST LOGIN BUTTON PRESSED")
	if _auth_flow_in_progress:
		return
		#
	#var user:String = Prefs.get_string("Username","Player")
	#user_name = user
	pending_login_method = "anonymous"
	Firebase.Auth.login_anonymous()
 
# ── Shared init function used by all login paths ──────────────────
func _init_and_load(uid: String, login_method: String, create_defaults: bool):
	
	_log("_init_and_load START")
	_log("uid = " + uid)
	_log("login_method = " + login_method)
	_log("create_defaults = " + str(create_defaults))
	if _auth_flow_in_progress or _loaded_uid == uid:
		return
	_auth_flow_in_progress = true
	# Init Firebase manager
	var session_ok = await _handle_session(uid)
	if not session_ok:
		print("Session blocked → stopping login")
		PlayerData.clear_login_session()
		Firebase.Auth.logout()
		_show_auth_panel("Account already in use")
		_auth_flow_in_progress = false
		return

	# var clean_name = user_name.strip_edges().to_lower()
	# var available = await FirebaseManager.is_username_available(clean_name)
	# if not available:
	# 	print("Username already exists")
	# 	return
	FirebaseManager.init(uid, login_method, create_defaults,user_name)
	if create_defaults:
		var clean_name = user_name.strip_edges().to_lower()

	# fallback random username
		if clean_name == "":
			clean_name = FirebaseManager.generate_random_names().to_lower() + uid.right(4)

		var available = await FirebaseManager.is_username_available(clean_name)
		if not available:
			print("Username already exists")
			_auth_flow_in_progress = false
			return

		await FirebaseManager.register_username(clean_name)
	# await FirebaseManager.register_username(clean_name)
	
	online = await FirebaseManager.internet_available()

	# Load player data from Firestore
	var loaded = await FirebaseManager.load_all(online)
	if not loaded and not create_defaults:
		PlayerData.reset_defaults()
		_show_auth_panel("Connect to internet once to restore your data.")
		_auth_flow_in_progress = false
		return
 
	PlayerData.save_login_session(uid, login_method)
	PlayerData.save_local()	
	_loaded_uid = uid
	_auth_flow_in_progress = false
	_change_to_profile()



func _handle_session(uid: String) -> bool:
	_log("SESSION CHECK START")
	var session_ref = Firebase.Firestore.collection("players/" + uid + "/Session")
	PlayerData.get_or_create_device_id()

	var doc = await session_ref.get_doc("active")
	var data = {}
	if doc != null and doc.has_method("get_unsafe_document"):
		data = doc.get_unsafe_document()
	FirebaseManager.print_firebase_read("players/" + uid + "/Session", "active", data, doc != null and not data.is_empty())

	var current_time = int(Time.get_unix_time_from_system())
	var my_device_id     = PlayerData.device_id


	if not data.is_empty():
		var last_active = int(data.get("last_active", 0))
		var server_device_id = str(data.get("device_id", ""))
		var time_since_last  = current_time - last_active

		_log("Session check:")
		_log("   My device:     ")
		_log("   Server device: ")
		_log("   Time since:    ")

		# SAME DEVICE → always allow
		if server_device_id == my_device_id:
			print("Same device relogin")
			samedevice = true
			PlayerData.session_id     = str(randi())
			PlayerData.session_active = true
			var same_device_session_data := {
				"session_id":  PlayerData.session_id,
				"last_active": current_time,
				"device":      PlayerData.device_type,
				"device_id":   my_device_id
			}
			FirebaseManager.print_firebase_write("players/" + uid + "/Session", "active", same_device_session_data)
			await session_ref.set_doc("active", same_device_session_data)
			return true


		if time_since_last < 40:
			print("Account active on another device (", time_since_last, "s ago)")
			#%StateLabel.text = "Account already in use on another device"
			return false

	PlayerData.session_id = str(randi())
	PlayerData.session_active = true

	var session_data := {
		"session_id": PlayerData.session_id,
		"last_active": current_time,
		"device": PlayerData.device_type,
		"device_id": my_device_id
	}
	_log("SESSION CHECK COMPLETE")
	FirebaseManager.print_firebase_write("players/" + uid + "/Session", "active", session_data)
	await session_ref.set_doc("active", session_data)

	return true
 
func _change_to_profile():
	_log("PROFILE CHANGE")
	account_created.emit()
	print("profile called")
	Prefs.set_int("user",1)
		
		
func cleanup_invalid_local_files():
	var dir = DirAccess.open("user://")
	var has_playerdata := false
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.begins_with("playerData_") and file_name.ends_with(".json"):
			has_playerdata = true
			break
			
	file_name = dir.get_next()
	dir.list_dir_end()
	if not has_playerdata and FileAccess.file_exists("user://user.auth"):
		dir.remove("user.auth")
