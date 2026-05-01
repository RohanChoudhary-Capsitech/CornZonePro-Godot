extends ScrollContainer

@onready var hbox = $HBoxContainer
@export var focused_scale: float = 1.4
@export var normal_scale: float = 1.0
@export var scroll_speed: float = 0.1

var target_scroll_x: float = 0.0
var is_scrolling: bool = false

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
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_scroll_x -= 100
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_scroll_x += 100
		if not event.pressed:
			_snap_to_closest()
	if event is InputEventScreenDrag:
		target_scroll_x -= event.relative.x

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
