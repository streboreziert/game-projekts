extends Node2D

enum State { GREEN, YELLOW_AFTER_GREEN, RED, YELLOW_BEFORE_GREEN }
var current_state: State = State.GREEN
var state_index := 0

@onready var timer: Timer = $Timer
@onready var area: Area2D = $Area2D
@onready var red_light = $Red
@onready var yellow_light = $Yellow
@onready var green_light = $Green

# Colors
var full_red = Color(1, 0, 0)
var dim_red = Color(0.2, 0, 0)

var full_yellow = Color(1, 1, 0)
var dim_yellow = Color(0.2, 0.2, 0)

var full_green = Color(0, 1, 0)
var dim_green = Color(0, 0.2, 0)

# Sequence of traffic states
var state_sequence = [
	State.GREEN,
	State.YELLOW_AFTER_GREEN,
	State.RED,
	State.YELLOW_BEFORE_GREEN
]

func _ready():
	print("🚦 StopZone with dimming traffic lights ready.")
	update_lights()
	timer.timeout.connect(_on_timer_timeout)
	timer.start(5.0)

func _on_timer_timeout():
	state_index = (state_index + 1) % state_sequence.size()
	current_state = state_sequence[state_index]

	match current_state:
		State.GREEN:
			timer.start(5.0)
		State.YELLOW_AFTER_GREEN:
			timer.start(2.0)
		State.RED:
			timer.start(4.0)
		State.YELLOW_BEFORE_GREEN:
			timer.start(2.0)

	update_lights()

func update_lights():
	match current_state:
		State.GREEN:
			green_light.modulate = full_green
			yellow_light.modulate = dim_yellow
			red_light.modulate = dim_red
		State.YELLOW_AFTER_GREEN, State.YELLOW_BEFORE_GREEN:
			green_light.modulate = dim_green
			yellow_light.modulate = full_yellow
			red_light.modulate = dim_red
		State.RED:
			green_light.modulate = dim_green
			yellow_light.modulate = dim_yellow
			red_light.modulate = full_red

	print("🚦 LIGHT:", state_name(current_state))

signal punish(n)
func _on_area_2d_body_entered(body):
	print("➡️", body.name, "entered zone. LIGHT:", state_name(current_state))

func _on_area_2d_body_exited(body):
	print("⬅️", body.name, " exited zone.")
	if current_state == State.RED:
		print("❌ PENALTY! Red light crossed.")
		punish.emit(4)
	else:
		print("✅ Safe crossing.")

func state_name(state: State) -> String:
	match state:
		State.GREEN: return "GREEN"
		State.YELLOW_AFTER_GREEN: return "YELLOW (after green)"
		State.RED: return "RED"
		State.YELLOW_BEFORE_GREEN: return "YELLOW (before green)"
		_: return "UNKNOWN"
