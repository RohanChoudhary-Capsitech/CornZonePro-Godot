extends CanvasLayer

var isInternetConnected:bool = false

func _ready():
	Authentication.account_created.connect(naya_func)
	Authentication.duplicate_name.connect(notificate_changed)

func _on_submit_button_pressed() -> void:
	SoundManager.play_button_clicks()
	isInternetConnected = await  FirebaseManager.internet_available()
	if isInternetConnected == true:
		print("internet is available")
		Authentication.on_login_as_a_guest_pressed()
		UIManager.toggle_canvas($"../LoginLoadingScreen")
	else:
		print("internet not available")
		UIManager.toggle_canvas($"../NoInternetScreen")
	Prefs.set_int("user",1)
	
 
func naya_func():
	UIManager.enable_canvas($"../HomeScreen")
	
func notificate_changed():
	$"../LoginLoadingScreen/LoadingText".text = "Username exists"
