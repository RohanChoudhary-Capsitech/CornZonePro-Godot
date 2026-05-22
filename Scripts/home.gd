extends Node3D
 
signal username_changed(user_name: String)
@onready var username:LineEdit = $LoginScreen/LoginPanel/Panel/UserName
var user_name: String = ""
 
func _ready() -> void:
	if not username.text_changed.is_connected(_on_user_name_text_changed):
		username.text_changed.connect(_on_user_name_text_changed)
	UIManager.home_setup(
		$LoadingScreen,
		$HomeScreen,
		$LoginScreen,
		$SettingScreen,
		$MapSelectScreen,
		$ProfileScreen,
		$InfoScreen,
		$DailyRewardScreen,
		$RewardScreen,
		$MultiplayerScreen,
		$LeaderBoardScreen,
		$ShopScreen,
		$InventoryScreen,
		$LoginLoadingScreen,
		$NoInternetScreen
	)
	var home:= Prefs.get_int("home_comeing",0)
	if 0==home:
		UIManager.enable_canvas($LoadingScreen)
	else:
		UIManager.enable_canvas($HomeScreen)
	#AdManager.show_banner()
 
#add player name before login
func _on_user_name_text_changed(new_text: String) -> void:
	user_name = new_text.strip_edges()
	username_changed.emit(user_name)
	Authentication.user_name = user_name

 
 
func _on_delete_account_button_pressed() -> void:
	var uid = Firebase.Auth.auth.localid
	print("UID:::::",uid)
	if uid == "":
		print("Cannot delete player data: missing Firebase uid")
		return
 
	await _delete_player_document("players/" + uid + "/Profile", "Profile")
	await _delete_player_document("players/" + uid + "/Stats", "stats")
	await _delete_player_document("players/" + uid + "/Inventory", "inventory")
	await _delete_player_document("players/" + uid + "/Miscellaneous", "misc")
	await _delete_player_document("players/" + uid + "/Session", "active")
	await _delete_player_document("players", uid)
	#await _delete_player_document("usernames/", Authentication.user_name)
 
	var auth_deleted = await _delete_authenticated_user()
	if not auth_deleted:
		print("Player data was deleted, but Firebase Auth account delete failed")
		return
	#PlayerData.reset_defaults()
	delete_local_save()
	get_tree().quit()
 
func delete_local_save() -> void:
	var uid = Firebase.Auth.auth.localid
 
	var path_arr: Array = [
		"user://playerData_" + uid + ".json",
		"user://device_id.txt",
		"user://loginSession.json",
		"user://user.auth",
		"user://prefs.save"
	]
 
	var dir := DirAccess.open("user://")
 
	for full_path in path_arr:
		if FileAccess.file_exists(full_path):
			# DirAccess.remove() needs just the filename, not full path
			var filename = full_path.replace("user://", "")
			var error := dir.remove(filename)
			if error == OK:
				print("[Account] Deleted: ", filename)
			else:
				push_error("[Account] Failed to delete: ", filename, " — ", error_string(error))
		else:
			print("[Account] Not found, skipping: ", full_path)
 
func _delete_player_document(collection_path: String, document_id: String) -> void:
	var collection = Firebase.Firestore.collection(collection_path)
	var document = FirestoreDocument.new()
	document.doc_name = document_id
	document.collection_name = collection_path
	var result = await collection.delete(document)
	print("Deleted ", collection_path, "/", document_id, ": ", result)
 
 
func _delete_authenticated_user() -> bool:
	if Firebase.Auth.auth.is_empty() or not Firebase.Auth.auth.has("idtoken"):
		print("Cannot delete Firebase Auth account: missing id token")
		return false
 
	Firebase.Auth.delete_user_account()
	var result: Array = await Firebase.Auth.auth_request
	if result[0] != 1:
		print("Firebase Auth account delete failed: ", result[0], " ", result[1])
		return false
 
	print("Firebase Auth account deleted")
	return true
