extends Node

signal notify
signal micro_interaction_signal(img_path: String)
signal party_popper_signal

var power_up:bool = false
var show_once:bool = true
var is_pot:bool = false
var is_grounded:bool = false
var successive_pots = 0

func show_notification(label_node: Label, message: String, display_time: float = 2.0):
	if not is_instance_valid(label_node) or not label_node.is_inside_tree():
		return
	
	label_node.text = message
	label_node.modulate.a = 1.0
	label_node.show()
	
	pop_animation(label_node)
	
	await get_tree().create_timer(display_time + 0.5).timeout
	if not is_instance_valid(label_node) or not label_node.is_inside_tree():
		return
	var fade_tween = create_tween()
	var property_tweener = fade_tween.tween_property(
		label_node,
		"modulate:a",
		0.0,
		0.35
	)
	if property_tweener:
		property_tweener.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		await fade_tween.finished
	else:
		fade_tween.kill()
		
	if is_instance_valid(label_node):
		label_node.hide()


func show_fade_item(node: Control, delay: float):
	if not is_instance_valid(node) or not node.is_inside_tree():
		return
	node.modulate.a = 0.0
	node.show()
	await get_tree().create_timer(delay).timeout
 
	var tween = create_tween()
 
	tween.tween_property(
		node,
		"modulate:a",
		1.0,
		0.35
	).set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_OUT)


func set_animation(nodes:Array[Node]):
	var val = 0.0
	var inc = 0.05
	for node in nodes:
		val += inc
		show_fade_item(node, val)

func pop_animation(node: Control):
	node.scale = Vector2.ZERO
	node.pivot_offset = node.size / 2
	var tween = create_tween()
	tween.tween_property(node, "scale", Vector2(1.15, 1.15), 0.35)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ONE, 0.15)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
