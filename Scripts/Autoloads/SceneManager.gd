extends Node

#--CONSTANTS-------------------------
const ALWAYS_KEEP=[
	"res://Scenes/home.tscn",
]

#--STATE-----------------------------
var _cache:Dictionary={}
var _current_scene:Node=null
var _current_path:String=""
var _loading_queue:Array=[]

signal scene_loaded(path:String)
signal scene_changed(path:String)
signal load_progress(path:String,progress:float)


#--INIT-----------------------------
func _ready() -> void:
	_preload_critical_scenes()

func _preload_critical_scenes()-> void:
	var critical: Array[String] = [
		"res://Scenes/home.tscn",
	]
	for path in critical:
		_load_to_cache(path)
		print("[SceneManager] Preloaded: ", path)

#--CHANGE SCENE---------------------
func goto(path:String)->void:
	if not _cache.has(path):
		# not cached yet — load it now
		push_warning("[SceneManager] Not cached, loading now: " + path)
		_load_to_cache(path)
	_swap_scene(path)

func goto_packed(packed:PackedScene)->void:
	_swap_scene_packed(packed)

func _swap_scene(path:String)->void:
	var packed: PackedScene = _cache.get(path,null) as PackedScene
	if null==packed:
		push_error("[SceneManager] Scene not found in cache: " + path)
		return
	_swap_scene_packed(packed,path)

func _swap_scene_packed(packed:PackedScene,path:String="")->void:
	if get_node_or_null("/root/TransitionLayer") != null:
		await TransitionLayer.fade_out()
	elif has_node("TransitionLayer"):
		await $TransitionManager.fade_out()
	
	var previous_scene := _current_scene
	var previous_path := _current_path

	if previous_scene == null or not is_instance_valid(previous_scene):
		previous_scene = get_tree().current_scene
		if is_instance_valid(previous_scene):
			previous_path = previous_scene.scene_file_path

	if previous_scene and is_instance_valid(previous_scene):
		var previous_parent := previous_scene.get_parent()
		if previous_parent:
			previous_parent.remove_child(previous_scene)
		previous_scene.queue_free()
		_current_scene = null
		print("[SceneManager] Freed scene: ", previous_path)
	_auto_free_cache()
	var instance: Node = packed.instantiate()
	get_tree().root.add_child(instance)
	get_tree().current_scene=instance
	_current_scene=instance
	_current_path=path
	print("[SceneManager] Scene changed: ", path)
	print_memory()
	scene_changed.emit(path)
	
	if get_node_or_null("/root/TransitionLayer") != null:
		await TransitionLayer.fade_in()
		print("fade ho rha hai")
	elif has_node("TransitionLayer"):
		await $TransitionManager.fade_in()
		print("fade nhi ho rha hai")

#--PRELOAD-------------------------
func preload_scene(path:String)->void:
	if _cache.has(path):
		return
	_load_to_cache(path)

func preload_multiple(paths:Array)->void:
	for path in paths:
		preload_scene(path)

func _load_to_cache(path:String)->void:
	if _cache.has(path):
		return
	var before: int = OS.get_static_memory_usage()
	var packed: PackedScene = load(path) as PackedScene
	var after: int = OS.get_static_memory_usage()
	if null==packed:
		push_error("[SceneManager] Failed to load: " + path)
		return
	
	_cache[path]=packed
	var used_mb: float = (after-before)/1024.0/1024.0
	print("[SceneManager] Cached: ", path, " (", snapped(used_mb, 0.01), " MB)")
	scene_loaded.emit(path)


#--BACKGROUND LOADING----------------
func preload_async(path:String)->void:
	if _cache.has(path):
		return
	ResourceLoader.load_threaded_request(path)
	_loading_queue.append(path)
	print("[SceneManager] Background loading: ", path)

func preload_async_multiple(paths:Array)->void:
	for path in paths:
		preload_async(path)

func _process(delta: float) -> void:
	if _loading_queue.is_empty():
		return
	
	for path in _loading_queue.duplicate():
		var status: int = ResourceLoader.load_threaded_get_status(path)
		match(status):
			ResourceLoader.THREAD_LOAD_LOADED:
				var packed: PackedScene = ResourceLoader.load_threaded_get(path) as PackedScene
				_cache[path]=packed
				_loading_queue.erase(path)
				print("[SceneManager] Async loaded: ", path)
				scene_loaded.emit(path)
			ResourceLoader.THREAD_LOAD_FAILED:
				push_error("[SceneManager] Async load failed: " + path)
				_loading_queue.erase(path)

func _is_loaded(path:String)->bool:
	return _cache.has(path)

func wait_until_loaded(path:String)->void:
	while not _is_loaded(path):
		await get_tree().process_frame

#--FREE----------------------------
func  free_scene(path:String)->void:
	if ALWAYS_KEEP.has(path):
		print("[SceneManager] Skipping free (protected): ", path)
		return
	if _cache.has(path):
		_cache.erase(path)
		print("[SceneManager] Freed from cache: ", path)

func free_all(except:Array=[])->void:
	var to_free: Array[String] = []
	for path in _cache.keys():
		if not ALWAYS_KEEP.has(path) and not except.has(path):
			to_free.append(path)
	for path in to_free:
		_cache.erase(path)
	print("[SceneManager] Freed ", to_free.size(), " scenes")
	print_memory()

func _auto_free_cache()->void:
	for path in _cache.keys().duplicate():
		if ALWAYS_KEEP.has(path):
			continue
		if _current_path==path:
			continue
		_cache.erase(path)
		print("[SceneManager] Auto freed: ", path)

#--MEMORY INFO-----------------------
func print_memory()->void:
	var ram_mb: float = OS.get_static_memory_usage() / 1024.0 / 1024.0
	var peak_mb: float = OS.get_static_memory_peak_usage() / 1024.0 / 1024.0
	print("─────────────────────────────────")
	print("RAM now:  ", snapped(ram_mb, 0.01), " MB")
	print("RAM peak: ", snapped(peak_mb, 0.01), " MB")
	print("Cached scenes: ", _cache.keys())
	print("─────────────────────────────────")

func get_memory_mb() -> float:
	return OS.get_static_memory_usage() / 1024.0 / 1024.0
