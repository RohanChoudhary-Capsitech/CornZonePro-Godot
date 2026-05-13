# =========================================================
# AdManager.gd
# Complete Production Ready Ad Manager
# Godot 4 + AdMob Plugin
#
# Features:
# ✔ Banner Ads
# ✔ Interstitial Ads
# ✔ Rewarded Ads
# ✔ Retry Logic
# ✔ Auto Reload
# ✔ Pause / Resume Game
# ✔ Reward Callback
# ✔ Auto Preload Ads
# ✔ Production Ready Structure
#
# =========================================================

extends Node


# =========================================================
# ADMOB NODE
# =========================================================

@onready var admob = $Admob


# =========================================================
# SETTINGS
# =========================================================

var is_initialized := false

var retry_time := 3.0
var max_retries := 5


# =========================================================
# LOAD STATES
# =========================================================

var banner_loaded := false
var interstitial_loaded := false
var rewarded_loaded := false


# =========================================================
# RETRY COUNTS
# =========================================================

var banner_retries := 0
var interstitial_retries := 0
var rewarded_retries := 0


# =========================================================
# REWARDED CALLBACK
# =========================================================

var reward_callback = null


# =========================================================
# READY
# =========================================================

func _ready():

	process_mode = Node.PROCESS_MODE_ALWAYS

	print("AdManager Started 🚀")

	connect_signals()

	initialize_admob()


# =========================================================
# CONNECT SIGNALS
# =========================================================

func connect_signals():

	# =========================
	# INIT
	# =========================

	admob.initialization_completed.connect(_on_initialized)

	# =========================
	# BANNER
	# =========================

	admob.banner_ad_loaded.connect(_on_banner_loaded)

	admob.banner_ad_failed_to_load.connect(_on_banner_failed)

	# =========================
	# INTERSTITIAL
	# =========================

	admob.interstitial_ad_loaded.connect(_on_interstitial_loaded)

	admob.interstitial_ad_failed_to_load.connect(_on_interstitial_failed)

	admob.interstitial_ad_showed_full_screen_content.connect(_on_ad_opened)

	admob.interstitial_ad_dismissed_full_screen_content.connect(_on_interstitial_closed)

	# =========================
	# REWARDED
	# =========================

	admob.rewarded_ad_loaded.connect(_on_rewarded_loaded)

	admob.rewarded_ad_failed_to_load.connect(_on_rewarded_failed)

	admob.rewarded_ad_showed_full_screen_content.connect(_on_ad_opened)

	admob.rewarded_ad_dismissed_full_screen_content.connect(_on_rewarded_closed)

	# reward earned

	if admob.has_signal("user_earned_reward"):

		admob.user_earned_reward.connect(_on_user_earned_reward)


# =========================================================
# INITIALIZE
# =========================================================

func initialize_admob():

	print("Initializing AdMob...")

	admob.initialize()


func _on_initialized(status):

	is_initialized = true

	print("AdMob Initialized ✅")

	preload_ads()


# =========================================================
# PRELOAD ADS
# =========================================================

func preload_ads():

	#load_banner()

	load_interstitial()

	load_rewarded()


# =========================================================
# BANNER
# =========================================================

func load_banner():

	if not is_initialized:
		return

	if banner_loaded:
		return

	if banner_retries >= max_retries:

		print("Banner Max Retries Reached ❌")

		return


	banner_retries += 1

	print("Loading Banner Ad...")

	admob.load_banner_ad()


func show_banner():

	if banner_loaded:

		admob.show_banner_ad()

		print("Banner Showing ✅")

	else:

		print("Banner Not Loaded")


func hide_banner():

	admob.hide_banner_ad()


func _on_banner_loaded(ad_info, response_info):

	print("Banner Loaded ✅")

	banner_loaded = true

	banner_retries = 0

	show_banner()


func _on_banner_failed(ad_info, error):

	print("Banner Failed ❌")

	print(error.get_message())

	await get_tree().create_timer(retry_time).timeout

	load_banner()


# =========================================================
# INTERSTITIAL
# =========================================================

func load_interstitial():

	if not is_initialized:
		return

	if interstitial_loaded:
		return

	if interstitial_retries >= max_retries:

		print("Interstitial Max Retries Reached ❌")

		return


	interstitial_retries += 1

	print("Loading Interstitial...")

	admob.load_interstitial_ad()


func show_interstitial():

	if interstitial_loaded:

		print("Showing Interstitial ✅")

		admob.show_interstitial_ad()

	else:

		print("Interstitial Not Ready")

		load_interstitial()


func _on_interstitial_loaded(ad_info, response_info):

	print("Interstitial Loaded ✅")

	interstitial_loaded = true

	interstitial_retries = 0


func _on_interstitial_failed(ad_info, error):

	print("Interstitial Failed ❌")

	print(error.get_message())

	await get_tree().create_timer(retry_time).timeout

	load_interstitial()


func _on_interstitial_closed(ad_info):

	print("Interstitial Closed")

	get_tree().paused = false

	interstitial_loaded = false

	load_interstitial()


# =========================================================
# REWARDED
# =========================================================

func load_rewarded():

	if not is_initialized:
		return

	if rewarded_loaded:
		return

	if rewarded_retries >= max_retries:

		print("Rewarded Max Retries Reached ❌")

		return


	rewarded_retries += 1

	print("Loading Rewarded...")

	admob.load_rewarded_ad()


func show_rewarded(callback = null):

	reward_callback = callback

	if rewarded_loaded:

		print("Showing Rewarded ✅")

		admob.show_rewarded_ad()

	else:

		print("Rewarded Not Ready")

		load_rewarded()


func _on_rewarded_loaded(ad_info, response_info):

	print("Rewarded Loaded ✅")

	rewarded_loaded = true

	rewarded_retries = 0


func _on_rewarded_failed(ad_info, error):

	print("Rewarded Failed ❌")

	print(error.get_message())

	await get_tree().create_timer(retry_time).timeout

	load_rewarded()


func _on_rewarded_closed(ad_info):

	print("Rewarded Closed")

	get_tree().paused = false

	rewarded_loaded = false

	load_rewarded()


# =========================================================
# REWARD EARNED
# =========================================================

func _on_user_earned_reward(reward_item, reward_amount):

	print("Reward Earned ✅")

	print("Reward:", reward_item)

	print("Amount:", reward_amount)

	if reward_callback != null:

		reward_callback.call()


# =========================================================
# PAUSE / RESUME
# =========================================================

func _on_ad_opened(ad_info):

	print("Ad Opened → Pause Game")

	get_tree().paused = true


# =========================================================
# UTILITY
# =========================================================

func is_interstitial_ready() -> bool:

	return interstitial_loaded


func is_rewarded_ready() -> bool:

	return rewarded_loaded


func is_banner_ready() -> bool:

	return banner_loaded
