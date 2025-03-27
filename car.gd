extends CharacterBody2D

var m_to_px = 100
var speed = 0.0
var engine_power = 300        # Forward power
var reverse_power = 150       # Reverse power (lower)
var braking_deceleration = 40
var max_reverse_speed = 20.0  # Cap reverse speed

var tire_grip = 0.2
var acceleration = 0
var acceleration_time = 2

signal data(speed)

func _ready():
	z_index = 100
	print("✅ _ready() called: Script is running")

	if has_node("BrakeLights"):
		print("✅ Found BrakeLights node")
	else:
		print("❌ Missing BrakeLights node")

	if has_node("UI/DirectionLabel"):
		print("✅ Found UI/DirectionLabel node")
	else:
		print("❌ Missing UI/DirectionLabel node")

func speed_change(delta, input):
	var air_density = 1.2
	var drag_area = 3
	var rolling_coef = 0.4
	var drag = 0.5 * drag_area * air_density * speed * speed
	var rolling_resistance = rolling_coef * 1500 * 10

	var input_dir = sign(input)
	var speed_dir = sign(speed)

	var power = 0.0
	if input > 0:
		power = engine_power * 1000
	elif input < 0:
		power = reverse_power * 1000

	# Case: switching direction — apply braking
	if speed != 0 and input != 0 and input_dir != speed_dir:
		print("🔃 Switching direction. Braking...")
		var decel = braking_deceleration * speed_dir
		speed -= decel * delta
		if sign(speed) != speed_dir:
			speed = 0
		return

	# Case: no input — natural deceleration
	if input == 0 and speed != 0:
		print("🛑 No input. Decelerating...")
		var decel = braking_deceleration * speed_dir
		speed -= decel * delta
		if sign(speed) != speed_dir:
			speed = 0
		return

	# Case: accelerating in current direction
	if input != 0:
		var s = new_speed(rolling_resistance, drag, 0, power, delta)
		if input > 0:
			speed = s
		else:
			speed = -s
			if speed < -max_reverse_speed:
				speed = -max_reverse_speed

		print("🚀 Accelerating. Speed =", speed)

func new_speed(rolling, drag, braking, power, delta):
	var kinetic_energy = (1500 * abs(speed) * abs(speed)) / 2.0
	var new_energy = kinetic_energy + (power - drag * abs(speed) - rolling * abs(speed)) * delta
	if new_energy - braking * delta < 0:
		return 0
	return sqrt((2.0 / 1500) * new_energy) - braking * delta

func _physics_process(delta):
	var direction = 0

	if Input.is_action_pressed("ui_up"):
		direction = 1
	elif Input.is_action_pressed("ui_down"):
		direction = -1
	else:
		direction = 0

	speed_change(delta, direction)

	velocity = Vector2.UP.rotated(rotation) * speed * m_to_px
	move_and_slide()

	if Input.is_action_pressed("ui_right"):
		rotation += 0.05
	if Input.is_action_pressed("ui_left"):
		rotation -= 0.05

	data.emit(speed * 3.6)  # emit km/h
	print("📦 _physics_process: speed =", speed, "direction =", direction)

	# --- Brake lights ---
	if has_node("BrakeLights"):
		$BrakeLights.visible = false
		if direction == 0 and speed != 0:
			$BrakeLights.visible = true
			print("💡 Brake lights ON (idle braking)")
		elif direction != 0 and sign(direction) != sign(speed):
			$BrakeLights.visible = true
			print("💡 Brake lights ON (reversing direction)")

	# --- UI Direction Indicator ---
	if has_node("UI/DirectionLabel"):
		var direction_text = "Idle"
		if speed > 0:
			direction_text = "Forward"
		elif speed < 0:
			direction_text = "Reverse"
		$UI/DirectionLabel.text = "Direction: " + direction_text
		print("🧭 Direction UI =", direction_text)
