extends Control

# ── Inspector exports (match your Unity serialized fields) ──────────────────
@export var items: Array[TextureRect] = []

#@export_group("Dot Settings")
#@export var dots: Array[TextureRect] = []
#@export var active_dot_scale: float = 0.55
#@export var normal_dot_scale: float = 0.35
#@export var active_dot_sprite: Texture2D    # pics[0] equivalent
#@export var normal_dot_sprite: Texture2D    # pics[1] equivalent

var is_dragging: bool = false
var drag_start_x: float = 0.0
var scroll_start: float = 0.0
@export_group("Effect")
@export var scale_multiplier: float = 0.4   # how much bigger center gets
@export var min_scale: float = 0.7          # smallest side item scale

@export_group("Snap")
@export var snap_speed: float = 10.0

# ── Internal state ──────────────────────────────────────────────────────────
var positions: Array[float] = []   # normalized 0..1 for each item
var target_index: int = 0
var scroll_pos: float = 0.0        # current normalized scroll (0..1)

@onready var scroll_bar: HScrollBar = $HScrollBar


func _ready() -> void:
	var count := items.size()
	positions.resize(count)

	for i in count:
		# Space items evenly 0..1, same as Unity's (float)i / (count - 1)
		positions[i] = float(i) / float(count - 1) if count > 1 else 0.0

	# Initial scroll to first item
	scroll_pos = 0.0
	scroll_bar.value = scroll_pos

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_x = event.position.x
				scroll_start = scroll_bar.value
			else:
				is_dragging = false

	if event is InputEventMouseMotion and is_dragging:
		# Drag sensitivity: divide by screen width for normalized delta
		var drag_delta: float = (drag_start_x - event.position.x) / size.x
		scroll_bar.value = clampf(scroll_start + drag_delta, 0.0, 1.0)

	# Touch support
	if event is InputEventScreenTouch:
		if event.pressed:
			is_dragging = true
			drag_start_x = event.position.x
			scroll_start = scroll_bar.value
		else:
			is_dragging = false

	if event is InputEventScreenDrag and is_dragging:
		var drag_delta: float = (drag_start_x - event.position.x) / size.x
		scroll_bar.value = clampf(scroll_start + drag_delta, 0.0, 1.0)

func _process(delta: float) -> void:
	_update_effects()
	_snap_to_closest(delta)


func _update_effects() -> void:
	scroll_pos = scroll_bar.value   # HScrollBar is already 0..1

	for i in items.size():
		var distance: float = abs(scroll_pos - positions[i])

		# Scale: center item = 1 + scale_multiplier, sides approach min_scale
		# Matches: Mathf.Lerp(1f + scaleMultiplier, minScale, distance * 2f)
		var map_scale: float = lerpf(1.0 + scale_multiplier, min_scale, distance * 2.0)
		map_scale = clampf(map_scale, min_scale, 1.0 + scale_multiplier)

		# Unity only scaled Y — replicate that exactly
		items[i].scale = Vector2(1.0, map_scale)

		# Dots
		#if i < dots.size():
			#var dot_scale: float = active_dot_scale if i == target_index else normal_dot_scale
			## Smooth lerp like Unity's Vector3.Lerp with deltaTime * snapSpeed
			#dots[i].scale = dots[i].scale.lerp(
				#Vector2.ONE * dot_scale,
				#get_process_delta_time() * snap_speed
			#)
			## Sprite swap — your pics[0] / pics[1]
			#dots[i].texture = active_dot_sprite if i == target_index else normal_dot_sprite


func _snap_to_closest(delta: float) -> void:
	var closest_distance: float = INF

	for i in positions.size():
		var distance: float = abs(scroll_pos - positions[i])
		if distance < closest_distance:
			closest_distance = distance
			target_index = i

	var target: float = positions[target_index]

	# Smooth snap — matches Mathf.Lerp(scrollPos, target, Time.deltaTime * snapSpeed)
	scroll_bar.value = lerpf(scroll_bar.value, target, delta * snap_speed)
