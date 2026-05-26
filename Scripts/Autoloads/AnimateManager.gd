extends Node

func show_fade_item(node: Control, delay: float):
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
