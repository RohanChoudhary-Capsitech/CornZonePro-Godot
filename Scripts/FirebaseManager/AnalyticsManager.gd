extends Node
var firebase_core
var analytics
var crashlytics
var messaging

func _ready():
 print("Game Started 🚀")

 # Get singletons safely
 firebase_core = Engine.get_singleton("GodotxFirebaseCore")
 analytics = Engine.get_singleton("GodotxFirebaseAnalytics")
 crashlytics = Engine.get_singleton("GodotxFirebaseCrashlytics")
 messaging = Engine.get_singleton("GodotxFirebaseMessaging")



 # Check if loaded
 if firebase_core == null:
  print("❌ Firebase Core not found")
  return

 # Connect signals
 firebase_core.core_initialized.connect(_on_core_initialized)

 if analytics:
  analytics.analytics_initialized.connect(_on_analytics_initialized)

 if crashlytics:
  crashlytics.crashlytics_initialized.connect(_on_crashlytics_initialized)

 # Initialize Core
 print("Initializing Firebase Core...")
 firebase_core.initialize()


func _on_core_initialized(success: bool):
 print("Core Signal Received")

 if success:
  print("✅ Firebase Core initialized!")

  if crashlytics:
   crashlytics.initialize()

  if analytics:
   analytics.initialize()
   print("🔥 Analytics initialize called")

  if messaging:
   messaging.initialize()
   messaging.request_permission()
 else:
  print("❌ Firebase Core initialization failed")


func _on_crashlytics_initialized(success: bool):
 print("Crashlytics initialized: ", success)


func _on_analytics_initialized(success: bool):
 print("📊 Analytics initialized: ", success)
 if success:
  # 🔥 YAHI EVENT DAALO
  analytics.log_event("game_start", {
   "level": 1,
   "mode": "normal",
   "platform": "android"
  })

  print("✅ Event Sent: game_start")
  
func log_event(event_name:String, params:Dictionary = {}):

 if analytics:
  analytics.log_event(event_name, params)
  print("🔥 Event Logged:", event_name)
 else:
  print("❌ Analytics not initialized")

 
 
