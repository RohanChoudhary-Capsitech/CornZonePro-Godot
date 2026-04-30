#extends ScrollContainer
#
#@onready var hbox = $HBoxContainer
#@export var focused_height: float = 420.0
#@export var normal_height: float = 350.0
#
#func _ready():
	## Allow focus through code
	##follow_focus = true
	## Initial focus
	#hbox.get_child(0).grab_focus()
#
#func _process(_delta):
	## Agar koi scroll kar raha hai (mouse ya swipe), focus update karo
	#_update_snapping_and_focus()
#
#func _update_snapping_and_focus():
	#var center_x = scroll_horizontal + (size.x / 2)
	#var closest_node = null
	#var min_dist = INF
#
	## 1. Pata lagao center ke sabse kareeb kaunsa button hai
	#for child in hbox.get_children():
		#var child_center = child.position.x + (child.size.x / 2)
		#var dist = abs(center_x - child_center)
		#
		#if dist < min_dist:
			#min_dist = dist
			#closest_node = child
	#
	## 2. Jo center mein hai use focus do (agar pehle se nahi hai)
	#if closest_node and get_viewport().gui_get_focus_owner() != closest_node:
		#closest_node.grab_focus()
#
	## 3. Size update logic (Carousel effect)
	#for child in hbox.get_children():
		#var target_y = focused_height if child == closest_node else normal_height
		## Lerp se smooth animation hoga bina manual Tween ke
		#child.custom_minimum_size.y = lerp(child.custom_minimum_size.y, target_y, 0.2)
#
## Single scroll pe clamp (snap) karne ke liye
#func _gui_input(event):
	#if event is InputEventMouseButton:
		#if not event.pressed: # Jab user scroll chhod de
			#_snap_to_closest()
#
#func _snap_to_closest():
	#var center_x = scroll_horizontal + (size.x / 2)
	#var closest_node = null
	#var min_dist = INF
#
	#for child in hbox.get_children():
		#var child_center = child.position.x + (child.size.x / 2)
		#var dist = abs(center_x - child_center)
		#if dist < min_dist:
			#min_dist = dist
			#closest_node = child
	#
	#if closest_node:
		#var target_scroll = closest_node.position.x - (size.x / 2) + (closest_node.size.x / 2)
		#create_tween().tween_property(self, "scroll_horizontal", target_scroll, 0.3).set_trans(Tween.TRANS_SINE)
extends ScrollContainer

@onready var hbox = $HBoxContainer
@export var focused_height: float = 420.0
@export var normal_height: float = 350.0

var is_scrolling = false

func _ready():
	# Default Godot focus auto-scroll band kar do taaki hamara custom logic chale
	follow_focus = false 

func _process(_delta):
	var center_x = scroll_horizontal + (size.x / 2)
	
	# Har frame check karo kaunsa button center ke paas hai
	for child in hbox.get_children():
		var child_center = child.position.x + (child.size.x / 2)
		var dist = abs(center_x - child_center)
		
		# Dynamic Scaling: Jitna center ke paas, utna bada (Smooth effect)
		# 300 yahan 'threshold' hai, ise adjust kar sakte ho transition speed ke liye
		var target_y = normal_height
		if dist < 200: 
			target_y = focused_height
		
		child.custom_minimum_size.y = lerp(child.custom_minimum_size.y, target_y, 0.1)

func _gui_input(event):
	# Jab mouse wheel ya swipe start ho
	if event is InputEventMouseButton or event is InputEventScreenDrag:
		is_scrolling = true
		
	# Jab user scroll chhod de (Button release)
	if event is InputEventMouseButton and not event.pressed:
		is_scrolling = false
		_snap_to_closest()

func _snap_to_closest():
	var center_x = scroll_horizontal + (size.x / 2)
	var closest_node = null
	var min_dist = INF

	for child in hbox.get_children():
		var child_center = child.position.x + (child.size.x / 2)
		var dist = abs(center_x - child_center)
		if dist < min_dist:
			min_dist = dist
			closest_node = child
	
	if closest_node:
		var target_scroll = closest_node.position.x - (size.x / 2) + (closest_node.size.x / 2)
		# Snap animation
		var tween = create_tween()
		tween.tween_property(self, "scroll_horizontal", target_scroll, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		# Snap hone ke baad focus do
		await tween.finished
		closest_node.grab_focus()
