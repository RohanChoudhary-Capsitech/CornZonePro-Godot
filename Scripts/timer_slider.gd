extends TextureProgressBar
class_name MatchTimerSlider

@export var map_config:MapConfig

signal time_over

@export var max_time:int
@export var smooth_speed:float=30.0

var timer_paused:bool=false
var current_time:float
var display_value:float

func _ready() -> void:
	if map_config:
		max_time=map_config.time_limit
	
	current_time=max_time
	display_value=max_time
	
	max_value=max_time
	value=display_value
	
	fill_mode=TextureProgressBar.FILL_LEFT_TO_RIGHT


func _process(delta: float) -> void:
	if timer_paused:
		return
	#Real Timer
	if current_time>0:
		current_time-=delta
		current_time=max(current_time,0)
	else:
		time_over.emit()
		
	#Smooth UI
	display_value=lerp(display_value,current_time,delta*smooth_speed)
	value=display_value


func add_time(sec:float)->void:
	current_time+=sec
	current_time=min(current_time,max_time)

func remove_time(sec:float)->void:
	current_time-=sec
	current_time=max(current_time,0)

func reset_timer()->void:
	current_time=max_time
	display_value=max_time
	value=display_value

func pause_timer()->void:
	timer_paused=true

func resume_timer()->void:
	timer_paused=false
