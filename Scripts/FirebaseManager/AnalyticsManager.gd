extends Node

var firebase_core
var analytics
var crashlytics
var messaging


func _ready():
	# Get singletons safely
	firebase_core = Engine.get_singleton("GodotxFirebaseCore")
	analytics = Engine.get_singleton("GodotxFirebaseAnalytics")
	crashlytics = Engine.get_singleton("GodotxFirebaseCrashlytics")
	messaging = Engine.get_singleton("GodotxFirebaseMessaging")

	# Check if loaded
	if firebase_core == null:
		return

	# Connect signals
	firebase_core.core_initialized.connect(_on_core_initialized)
	if analytics:
		analytics.analytics_initialized.connect(_on_analytics_initialized)
	if crashlytics:
		crashlytics.crashlytics_initialized.connect(_on_crashlytics_initialized)
	# Initialize Core
	firebase_core.initialize()


func _on_core_initialized(success: bool):
	if success:
		if crashlytics:
			crashlytics.initialize()
		if analytics:
			analytics.initialize()
		if messaging:
			messaging.initialize()
			messaging.request_permission()
	else:
		print("Firebase Core initialization failed")


func _on_crashlytics_initialized(success: bool):
	print("Crashlytics initialized: ", success)


func _on_analytics_initialized(success: bool):
	if success:
		analytics.log_event("game_start", {
			"level": 1,
			"mode": "normal",
			"platform": "android"
		})



func log_event(event_name: String, params: Dictionary = {}):
	if analytics:
		analytics.log_event(event_name, params)
	else:
		print("Analytics not initialized")
