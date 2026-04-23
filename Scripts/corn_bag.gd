extends RigidBody3D
@onready var swipe_controller: SwipeInputController = $SwipeInputController
 
var thrown: bool = false

func _ready() -> void:
	freeze = true
	swipe_controller.swipe_completed.connect(_on_swipe_completed)

func _on_swipe_completed(direction: Vector3, strength: float) -> void:
	if thrown:
		return
	freeze = false
	print(direction, strength)
	self.gravity_scale = 4
	apply_central_impulse(direction * strength)
	thrown = true
	await get_tree().create_timer(1.5).timeout
	request_next_bag()

func request_next_bag():
	get_parent().spawn_bag();
	
