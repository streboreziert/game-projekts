extends CharacterBody2D  # Change from Sprite2D to CharacterBody2D

var m_to_px = 100
var speed = 0
var engine_power = 300
<<<<<<< HEAD
var tire_grip = 0.2
var braking_deceleration = 40

var reverse_gear = 15
=======
var braking_deceleration = 10
var reverse_power = 150  # Power for reverse movement
>>>>>>> 3a88cf902af517a14132fd73aa86a16b1a85ca55

var acceleration = 0
var acceleration_time = 2

signal data(speed)

func _ready():
	z_index = 100  # Keeps sprite above everything

# Adjust speed_change to handle forward, reverse, and braking
func speed_change(delta, input):
<<<<<<< HEAD
	var speed_old = speed
	var air_density = 1.2
	var drag_area = 3
	var rolling_coef = 0.4
	var drag = (0.5 * drag_area * air_density * speed ** 2)
	var rolling_resistance = rolling_coef * mass * 10
	
=======
	var drag = 0.5 * 1.5 * 1.2 * speed ** 2
	var rolling_resistance = 0.2 * 1500 * 10

>>>>>>> 3a88cf902af517a14132fd73aa86a16b1a85ca55
	var power = 0

	if input > 0:  # Forward movement
		power = engine_power * 1000
	elif input < 0:  # Reverse movement
		power = -reverse_power * 1000  # Negative power for reverse movement

	if speed == 0 and input != 0:
		power = engine_power if input > 0 else -reverse_power
		speed = input * new_speed(rolling_resistance, drag, 0, power, delta)
	else:
		var dir = sign(speed)
		speed = dir * new_speed(rolling_resistance, drag, 0, power, delta)

	# Apply deceleration when not pressing the acceleration keys
	if input == 0 and speed != 0:
		var deceleration = braking_deceleration * sign(speed)
		speed = max(speed - deceleration * delta, 0)  # Gradually reduce speed to 0

	# Prevent speed from going negative when accelerating in reverse
	if input > 0 and speed < 0:
		speed = 0  # Stop the car if moving backwards when accelerating forward

func new_speed(rolling, drag, braking, power, delta):
	var kinetic_energy = (1500 * abs(speed) ** 2) / 2.0
	var new_energy = kinetic_energy + (power - drag * abs(speed) - rolling * abs(speed)) * delta
	if new_energy - braking * delta < 0:
		return 0
	return sqrt((2.0 / 1500) * new_energy) - braking * delta

func _physics_process(delta):
	var direction = 0

	# Check for input direction (forward, backward, or idle)
	if Input.is_action_pressed("ui_up"):  # Move forward
		direction = 1
	elif Input.is_action_pressed("ui_down"):  # Move backward
		direction = -1
	else:
		direction = 0  # No input

	speed_change(delta, direction)

	# Apply velocity and move the car
	velocity = Vector2.UP.rotated(rotation) * speed * m_to_px
	move_and_slide()  # Moves and handles collision automatically

	# Handle rotation
	if Input.is_action_pressed("ui_right"):
		rotation += 0.05
	if Input.is_action_pressed("ui_left"):
		rotation -= 0.05

	data.emit(speed * 3.6)  # Emit speed data (in km/h)
