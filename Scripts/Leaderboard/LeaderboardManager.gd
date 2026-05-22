extends Node

signal leaderboard_loaded(entries: Array, my_rank: int)

const COLLECTION = "leaderboard"
const PAGE_SIZE  = 10
const CACHE_TTL_SECONDS = 300

var _col = null
var _cached_entries: Array = []
var _cached_my_rank: int = -1
var _last_fetch_time: int = 0
var _fetch_in_progress: bool = false

func _ready():
	_ensure_collection()
	

func _ensure_collection():
	if _col == null:
		_col = Firebase.Firestore.collection(COLLECTION)

# ─────────────────────────────────────────────────────────────
# 🔥 SAVE / UPDATE PLAYER ENTRY
# ─────────────────────────────────────────────────────────────
func update_entry():
	_ensure_collection()
	_enterDataFirebase()

	
# ─────────────────────────────────────────────────────────────
# 📊 FETCH TOP PLAYERS
# ─────────────────────────────────────────────────────────────
func fetch_top(force_refresh: bool = false) -> Array:
	_ensure_collection()
	var now := int(Time.get_unix_time_from_system())
	if not force_refresh and not _cached_entries.is_empty() and now - _last_fetch_time < CACHE_TTL_SECONDS:
		emit_signal("leaderboard_loaded", _cached_entries, _cached_my_rank)
		return _cached_entries
	if _fetch_in_progress:
		if not _cached_entries.is_empty():
			emit_signal("leaderboard_loaded", _cached_entries, _cached_my_rank)
		return _cached_entries
	_fetch_in_progress = true

	var query := FirestoreQuery.new()
	query.from(COLLECTION, false)
	query.order_by("Coins", FirestoreQuery.DIRECTION.DESCENDING)
	query.limit(PAGE_SIZE)

	var docs = await Firebase.Firestore.query(query)

	var entries: Array = []

	if docs == null:
		FirebaseManager.print_firebase_query(COLLECTION, entries)
		_fetch_in_progress = false
		return entries

	for doc in docs:
		if doc == null:
			continue

		var data = doc.get_unsafe_document()
		if data == null or data.is_empty():
			continue

		data["uid"] = doc.doc_name
		entries.append(data)

	FirebaseManager.print_firebase_query(COLLECTION, entries)

	# Sort locally (tie-breaker logic)
	_sort_entries(entries)

	var my_rank := await get_global_rank()
	_cached_entries = entries.duplicate(true)
	_cached_my_rank = my_rank
	_last_fetch_time = now
	_fetch_in_progress = false

	PlayerData.rank = str(my_rank)
	PlayerData.save_local()

	emit_signal("leaderboard_loaded", entries, my_rank)

	return entries

# ─────────────────────────────────────────────────────────────
# 🧠 GET CURRENT PLAYER RANK (GLOBAL)
# ─────────────────────────────────────────────────────────────
func _get_my_rank_from_entries(entries: Array) -> int:
	if FirebaseManager.player_id == "":
		return -1

	var my_uid = FirebaseManager.player_id
	for i in range(entries.size()):
		if entries[i].get("uid", "") == my_uid:
			return i + 1
	return -1


func get_global_rank() -> int:
	if FirebaseManager.player_id == "":
		return -1

	var query := FirestoreQuery.new()
	query.from(COLLECTION, false)
	query.order_by("Coins", FirestoreQuery.DIRECTION.DESCENDING)

	var docs = await Firebase.Firestore.query(query)

	if docs == null:
		return -1

	var my_uid = FirebaseManager.player_id
	var rank := 1

	for doc in docs:
		if doc == null:
			continue

		if doc.doc_name == my_uid:
			return rank

		rank += 1

	return rank


func _enterDataFirebase(): 
	if FirebaseManager.player_id == "":
		return

	var uid = FirebaseManager.player_id

	var data := {
		"uid": uid,
		"player_name": PlayerData.player_name,
		"Coins": PlayerData.coins,
		"ELO": PlayerData.elo,
		"MatchesWon": PlayerData.matches_won,
		"MatchesLost": PlayerData.matches_lost,
		"Rank": PlayerData.rank,
		"updated_at": int(Time.get_unix_time_from_system())
	}
	FirebaseManager.print_firebase_write(COLLECTION, uid, data)
	await _col.set_doc(uid, data)

# ─────────────────────────────────────────────────────────────
# 🔽 SORTING (TIE BREAKER)
# ─────────────────────────────────────────────────────────────
func _sort_entries(entries: Array):
	entries.sort_custom(func(a, b):
		var coins_a := int(a.get("Coins", 0))
		var coins_b := int(b.get("Coins", 0))

		if coins_a != coins_b:
			return coins_a > coins_b

		var wins_a := int(a.get("MatchesWon", 0))
		var wins_b := int(b.get("MatchesWon", 0))

		if wins_a != wins_b:
			return wins_a > wins_b

		return int(a.get("ELO", 0)) > int(b.get("ELO", 0))
	)

# ─────────────────────────────────────────────────────────────
# 🧪 DEBUG (OPTIONAL)
# ─────────────────────────────────────────────────────────────
func print_leaderboard(entries: Array):
	print("=== LEADERBOARD ===")
	for i in range(entries.size()):
		var e = entries[i]
		print("%d. %s | Coins: %d" % [
			i + 1,
			e.get("player_name", "Unknown"),
			e.get("Coins", 0)
		])
