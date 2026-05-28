extends ScrollContainer

@onready var hbox = $HBoxContainer
@export var focused_scale: float = 1.4
@export var normal_scale: float = 1.0
@export var scroll_speed: float = 0.1

var target_scroll_x: float = 0.0
var is_scrolling: bool = false


#var touch_start_position:= Vector2.ZERO

var is_dragging := false
const DRAG_THRESHOLD := 15.0

var drag_start_position := Vector2.ZERO

func _ready():
	follow_focus = false
	for child in hbox.get_children():
		child.pivot_offset = child.size / 2

func _process(_delta):
	scroll_horizontal = lerp(float(scroll_horizontal), target_scroll_x, scroll_speed)
	var center_x: float = scroll_horizontal + (size.x / 2)
	for child in hbox.get_children():
		var child_center: float = child.global_position.x + (child.size.x / 2)
		var scroll_center: float = global_position.x + (size.x / 2)
		var dist: float = abs(scroll_center - child_center)
		var t: float = clamp(1.0 - (dist / (size.x / 2)), 0.0, 1.0)
		var s: float = lerp(normal_scale, focused_scale, t)		
		child.scale = Vector2(s, s)
		
func _gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			drag_start_position = event.position
			is_dragging = false
		else:
			# Finger released
			if is_dragging:
				_snap_to_closest()
				_release_buttons()
				# IMPORTANT
				get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		target_scroll_x -= event.relative.x
		# Detect drag distance
		if event.position.distance_to(drag_start_position) > DRAG_THRESHOLD:
			if not is_dragging:
				is_dragging = true
				_disable_buttons()
			#is_dragging = true
			# Prevent button click
			#get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_scroll_x -= 100
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_scroll_x += 100
		if not event.pressed:
			_snap_to_closest()

func _snap_to_closest():
	var center_x: float = target_scroll_x + (size.x / 2)
	var closest_node: Control = null
	var min_dist: float = INF

	for child in hbox.get_children():
		var child_center: float = child.position.x + (child.size.x / 2)
		var dist: float = abs(center_x - child_center)
		if dist < min_dist:
			min_dist = dist
			closest_node = child
	
	if closest_node:
		target_scroll_x = closest_node.position.x - (size.x / 2) + (closest_node.size.x / 2)


func _disable_buttons():
	for child in hbox.get_children():
		if child is Button:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _release_buttons():
	await get_tree().process_frame
	for child in hbox.get_children():
		if child is Button:
			child.mouse_filter = Control.MOUSE_FILTER_STOP
