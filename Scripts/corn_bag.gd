extends RigidBody3D
@onready var swipe_controller: SwipeInputController = $SwipeInputController
 
var thrown: bool = false
@export var throw_gravity_scale: float = 4.0

func _ready() -> void:
	freeze = true
	contact_monitor = true
	max_contacts_reported = 8
	swipe_controller.swipe_completed.connect(_on_swipe_completed)
	body_entered.connect(_on_body_entered)

func _on_swipe_completed(direction: Vector3, strength: float) -> void:
	if thrown:
		return
	freeze = false
	print(direction, strength)
	gravity_scale = throw_gravity_scale
	apply_central_impulse(direction * strength)
	thrown = true
	await get_tree().create_timer(1.5).timeout
	request_next_bag()

func request_next_bag():
	var scoring_player: int = GameSession.current_turn
	if has_meta("throw_player"):
		scoring_player = int(get_meta("throw_player"))
	var bag_score: int = int(get_meta("awarded_points", 0))
	var uses_bag_result_slots: bool = GameSession.selected_mode == "PassPlay" or GameSession.selected_mode == "Local"
	if uses_bag_result_slots:
		var bag_result_index: int = GameSession.record_bag_result(scoring_player, bag_score)
		set_meta("bag_result_index", bag_result_index)
		set_meta("awarded_points", bag_score)
	GameSession.on_bag_thrown()
	if GameSession.match_over:
		return
	get_parent().spawn_bag();

func _on_body_entered(body: Node) -> void:
	if body.has_method("on_bag_landed"):
		body.on_bag_landed(self)
	
