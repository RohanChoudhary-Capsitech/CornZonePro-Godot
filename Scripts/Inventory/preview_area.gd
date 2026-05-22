extends Control

@onready var pivot = $InspectTexture/SubViewportContainer/SubViewport/ModelPivot
#@onready var model: GeometryInstance3D = $InspectTexture/SubViewportContainer/SubViewport/ModelPivot/Bag

@export var model: GeometryInstance3D

@export var rotation_speed := 0.5
@export var return_speed := 5.0
@export var max_vertical_angle := 180.0

var dragging := false


func set_item_material(material):
	model.material_override = load(material)
	pivot.rotation_degrees = Vector3.ZERO
	model.position = Vector3.ZERO

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed

	if event is InputEventMouseMotion and dragging:
		_apply_rotation(event.relative)

	if event is InputEventScreenTouch:
		dragging = event.pressed

	if event is InputEventScreenDrag and dragging:
		_apply_rotation(event.relative)

func _notification(what):
	if what == NOTIFICATION_MOUSE_EXIT:
		dragging = false

func _apply_rotation(relative_movement: Vector2):
	pivot.rotate_y(deg_to_rad(relative_movement.x * rotation_speed))
	pivot.rotate_object_local(Vector3.RIGHT, deg_to_rad(relative_movement.y * rotation_speed))
	
	var current_rotation = pivot.rotation
	var max_rad = deg_to_rad(max_vertical_angle)
	current_rotation.x = clamp(current_rotation.x, -max_rad, max_rad)
	pivot.rotation = current_rotation

func _process(delta):
	if not dragging:
		pivot.rotation.x = lerp_angle(pivot.rotation.x, 0.0, delta * return_speed)
		pivot.rotation.y = lerp_angle(pivot.rotation.y, 0.0, delta * return_speed)
		pivot.rotation.z = lerp_angle(pivot.rotation.z, 0.0, delta * return_speed)
