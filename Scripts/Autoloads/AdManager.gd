# =========================================================
# AdManager.gd
# FINAL FIXED VERSION
# Reward callback runs AFTER ad closes
# Game pauses correctly
# Timer issue fixed
# =========================================================

extends Node

# =========================================================
# ADMOB NODE
# =========================================================

@onready var admob = $Admob

# =========================================================
# SETTINGS
# =========================================================

@export var debug_logs := true

var is_initialized := false

var retry_time := 3.0
var max_retries := 5

# =========================================================
# LOAD STATES
# =========================================================

var banner_loaded := false
var interstitial_loaded := false
var rewarded_loaded := false
var rewarded_interstitial_loaded := false

# =========================================================
# RETRY COUNTS
# =========================================================

var banner_retries := 0
var interstitial_retries := 0
var rewarded_retries := 0
var rewarded_interstitial_retries := 0

# =========================================================
# REWARD CALLBACKS
# =========================================================

var reward_callback = null
var pending_reward_callback = null

# =========================================================
# READY
# =========================================================

func _ready():

	process_mode = Node.PROCESS_MODE_ALWAYS

	log_msg("AdManager Started 🚀")

	connect_signals()

	initialize_admob()

# =========================================================
# LOG
# =========================================================

func log_msg(txt):

	if debug_logs:
		print(txt)

# =========================================================
# CONNECT SIGNALS
# =========================================================

func connect_signals():

	# =====================================================
	# INIT
	# =====================================================

	if admob.has_signal("initialization_completed"):

		admob.initialization_completed.connect(
			_on_initialized
		)

	# =====================================================
	# BANNER
	# =====================================================

	if admob.has_signal("banner_ad_loaded"):

		admob.banner_ad_loaded.connect(
			_on_banner_loaded
		)

	if admob.has_signal("banner_ad_failed_to_load"):

		admob.banner_ad_failed_to_load.connect(
			_on_banner_failed
		)

	# =====================================================
	# INTERSTITIAL
	# =====================================================

	if admob.has_signal("interstitial_ad_loaded"):

		admob.interstitial_ad_loaded.connect(
			_on_interstitial_loaded
		)

	if admob.has_signal("interstitial_ad_failed_to_load"):

		admob.interstitial_ad_failed_to_load.connect(
			_on_interstitial_failed
		)

	if admob.has_signal(
		"interstitial_ad_showed_full_screen_content"
	):

		admob.interstitial_ad_showed_full_screen_content.connect(
			_on_ad_opened
		)

	if admob.has_signal(
		"interstitial_ad_dismissed_full_screen_content"
	):

		admob.interstitial_ad_dismissed_full_screen_content.connect(
			_on_interstitial_closed
		)

	# =====================================================
	# REWARDED
	# =====================================================

	if admob.has_signal("rewarded_ad_loaded"):

		admob.rewarded_ad_loaded.connect(
			_on_rewarded_loaded
		)

	if admob.has_signal("rewarded_ad_failed_to_load"):

		admob.rewarded_ad_failed_to_load.connect(
			_on_rewarded_failed
		)

	if admob.has_signal(
		"rewarded_ad_showed_full_screen_content"
	):

		admob.rewarded_ad_showed_full_screen_content.connect(
			_on_ad_opened
		)

	if admob.has_signal(
		"rewarded_ad_dismissed_full_screen_content"
	):

		admob.rewarded_ad_dismissed_full_screen_content.connect(
			_on_rewarded_closed
		)

	# =====================================================
	# REWARDED INTERSTITIAL
	# =====================================================

	if admob.has_signal("rewarded_interstitial_ad_loaded"):

		admob.rewarded_interstitial_ad_loaded.connect(
			_on_rewarded_interstitial_loaded
		)

	if admob.has_signal(
		"rewarded_interstitial_ad_failed_to_load"
	):

		admob.rewarded_interstitial_ad_failed_to_load.connect(
			_on_rewarded_interstitial_failed
		)

	if admob.has_signal(
		"rewarded_interstitial_ad_showed_full_screen_content"
	):

		admob.rewarded_interstitial_ad_showed_full_screen_content.connect(
			_on_ad_opened
		)

	if admob.has_signal(
		"rewarded_interstitial_ad_dismissed_full_screen_content"
	):

		admob.rewarded_interstitial_ad_dismissed_full_screen_content.connect(
			_on_rewarded_interstitial_closed
		)

	# =====================================================
	# REWARD
	# =====================================================

	if admob.has_signal("rewarded_ad_user_earned_reward"):

		admob.rewarded_ad_user_earned_reward.connect(
			_on_user_earned_reward
		)

	if admob.has_signal(
		"rewarded_interstitial_ad_user_earned_reward"
	):

		admob.rewarded_interstitial_ad_user_earned_reward.connect(
			_on_user_earned_reward
		)

# =========================================================
# INITIALIZE
# =========================================================

func initialize_admob():

	log_msg("Initializing AdMob...")

	admob.initialize()

func _on_initialized(status):

	is_initialized = true

	log_msg("AdMob Initialized ✅")

	preload_ads()

# =========================================================
# PRELOAD ADS
# =========================================================

func preload_ads():

	load_banner()

	load_interstitial()

	load_rewarded()

	load_rewarded_interstitial()

# =========================================================
# BANNER
# =========================================================

func load_banner():

	if not is_initialized:
		return

	if banner_loaded:
		return

	if banner_retries >= max_retries:

		log_msg("Banner Max Retries Reached ❌")

		return

	banner_retries += 1

	log_msg("Loading Banner Ad...")

	admob.load_banner_ad()

func show_banner():

	if banner_loaded:

		admob.show_banner_ad()

		log_msg("Banner Showing ✅")

	else:

		log_msg("Banner Not Loaded")

func hide_banner():

	admob.hide_banner_ad()

func _on_banner_loaded(ad_info, response_info):

	log_msg("Banner Loaded ✅")

	banner_loaded = false

	banner_retries = 0

	show_banner()

func _on_banner_failed(ad_info, error):

	log_msg("Banner Failed ❌")

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

		log_msg("Interstitial Max Retries Reached ❌")

		return

	interstitial_retries += 1

	log_msg("Loading Interstitial...")

	admob.load_interstitial_ad()

func show_interstitial(callback = null):

	pending_reward_callback = callback

	if interstitial_loaded:

		log_msg("Showing Interstitial ✅")

		admob.show_interstitial_ad()

	else:

		log_msg("Interstitial Not Ready")

		load_interstitial()

func _on_interstitial_loaded(ad_info, response_info):

	log_msg("Interstitial Loaded ✅")

	interstitial_loaded = true

	interstitial_retries = 0

func _on_interstitial_failed(ad_info, error):

	log_msg("Interstitial Failed ❌")

	print(error.get_message())

	await get_tree().create_timer(retry_time).timeout

	load_interstitial()

func _on_interstitial_closed(ad_info):

	log_msg("Interstitial Closed")

	get_tree().paused = false

	interstitial_loaded = false

	load_interstitial()

	# =========================================
	# RUN CALLBACK AFTER AD CLOSE
	# =========================================

	if pending_reward_callback != null:

		print("RUNNING INTERSTITIAL CALLBACK")

		pending_reward_callback.call()

		pending_reward_callback = null
# =========================================================
# REWARDED
# =========================================================

func load_rewarded():

	if not is_initialized:
		return

	if rewarded_loaded:
		return

	if rewarded_retries >= max_retries:

		log_msg("Rewarded Max Retries Reached ❌")

		return

	rewarded_retries += 1

	log_msg("Loading Rewarded...")

	admob.load_rewarded_ad()

func show_rewarded(callback = null):

	pending_reward_callback = callback

	if rewarded_loaded:

		log_msg("Showing Rewarded ✅")

		admob.show_rewarded_ad()

	else:

		log_msg("Rewarded Not Ready")

		load_rewarded()

func _on_rewarded_loaded(ad_info, response_info):

	log_msg("Rewarded Loaded ✅")

	rewarded_loaded = true

	rewarded_retries = 0

func _on_rewarded_failed(ad_info, error):

	log_msg("Rewarded Failed ❌")

	print(error.get_message())

	await get_tree().create_timer(retry_time).timeout

	load_rewarded()

func _on_rewarded_closed(ad_info):

	log_msg("Rewarded Closed")

	get_tree().paused = false

	rewarded_loaded = false

	load_rewarded()

	# =========================================
	# RUN CALLBACK AFTER AD CLOSE
	# =========================================

	if reward_callback != null:

		print("RUNNING REWARD CALLBACK")

		reward_callback.call()

		reward_callback = null

	pending_reward_callback = null

# =========================================================
# REWARDED INTERSTITIAL
# =========================================================

func load_rewarded_interstitial():

	if not is_initialized:
		return

	if rewarded_interstitial_loaded:
		return

	if rewarded_interstitial_retries >= max_retries:

		log_msg(
			"Rewarded Interstitial Max Retries Reached ❌"
		)

		return

	rewarded_interstitial_retries += 1

	log_msg("Loading Rewarded Interstitial...")

	admob.load_rewarded_interstitial_ad()

func show_rewarded_interstitial(callback = null):

	pending_reward_callback = callback

	if rewarded_interstitial_loaded:

		log_msg(
			"Showing Rewarded Interstitial ✅"
		)

		admob.show_rewarded_interstitial_ad()

	else:

		log_msg(
			"Rewarded Interstitial Not Ready"
		)

		load_rewarded_interstitial()

func _on_rewarded_interstitial_loaded(
	ad_info,
	response_info
):

	log_msg(
		"Rewarded Interstitial Loaded ✅"
	)

	rewarded_interstitial_loaded = true

	rewarded_interstitial_retries = 0

func _on_rewarded_interstitial_failed(
	ad_info,
	error
):

	log_msg(
		"Rewarded Interstitial Failed ❌"
	)

	print(error.get_message())

	await get_tree().create_timer(retry_time).timeout

	load_rewarded_interstitial()

func _on_rewarded_interstitial_closed(ad_info):

	log_msg("Rewarded Interstitial Closed")

	get_tree().paused = false

	rewarded_interstitial_loaded = false
	load_rewarded_interstitial()

	# =========================================
	# HANDLE BOTH REWARDED + CANCEL CASE
	# =========================================

	if pending_reward_callback != null:

		if reward_callback != null:
			print("REWARDED → TRUE")
			pending_reward_callback.call(true)
		else:
			print("NOT REWARDED / CANCELLED → FALSE")
			pending_reward_callback.call(false)

	reward_callback = null
	pending_reward_callback = null

# =========================================================
# REWARD EARNED
# =========================================================

func _on_user_earned_reward(
	ad_info,
	reward_data
):

	log_msg("Reward Earned ✅")

	print("Reward earned but waiting for ad close")

	reward_callback = pending_reward_callback

# =========================================================
# PAUSE / RESUME
# =========================================================

func _on_ad_opened(ad_info):

	log_msg("Ad Opened → Pause Game")

	get_tree().paused = true

# =========================================================
# UTILITY
# =========================================================

func is_banner_ready() -> bool:
	return banner_loaded

func is_interstitial_ready() -> bool:
	return interstitial_loaded

func is_rewarded_ready() -> bool:
	return rewarded_loaded

func is_rewarded_interstitial_ready() -> bool:
	return rewarded_interstitial_loaded
