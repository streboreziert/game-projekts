extends Node2D

enum LightState { RED, YELLOW_BEFORE_GREEN, GREEN, YELLOW_BEFORE_RED }
var state = LightState.RED

@onready var red = $RedLight
@onready var yellow = $YellowLight
@onready var green = $GreenLight

var timer : Timer

func _ready():
	# Create timer in code
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)

	set_light_state(LightState.RED)
	timer.start(3.0)

func _on_timer_timeout():
	match state:
		LightState.RED:
			set_light_state(LightState.YELLOW_BEFORE_GREEN)
			timer.start(1.0)
		LightState.YELLOW_BEFORE_GREEN:
			set_light_state(LightState.GREEN)
			timer.start(3.0)
		LightState.GREEN:
			set_light_state(LightState.YELLOW_BEFORE_RED)
			timer.start(1.5)
		LightState.YELLOW_BEFORE_RED:
			set_light_state(LightState.RED)
			timer.start(3.0)

func set_light_state(new_state):
	state = new_state

	# Reset all lights
	red.visible = false
	yellow.visible = false
	green.visible = false

	match state:
		LightState.RED:
			red.visible = true
		LightState.YELLOW_BEFORE_GREEN:
			yellow.visible = true
			red.visible = true
		LightState.YELLOW_BEFORE_RED:
			yellow.visible = true
		LightState.GREEN:
			green.visible = true
