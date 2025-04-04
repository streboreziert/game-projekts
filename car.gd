extends CharacterBody2D

var m_to_px = 100 * scale[0]
var speed = 0
var engine_power = 143
var reverse_power = engine_power * 0.6
var braking_deceleration = 10.0
var max_reverse_speed = 30.0 / 3.6
var mass = 1500

var tire_grip = 0.2
var acceleration = 0
var acceleration_time = 2
signal speed_data(speed)

@export var stop_position: Vector2 = Vector2(559, -517)  # Set the stop sign's coordinates
@export var stop_tolerance: float = 10  # Tolerance for stopping (in pixels)
@export var lane_tolerance: float = 50  # Lane tolerance for the stop sign (road size)

var stopped_early = false  # Flag to track if the car stopped early

var announcement_label: Label  # Reference to the announcement label

func _ready():
	z_index = 100
<<<<<<< Updated upstream
=======
	print("✅ _ready() called: Script is running")

	# Find the AnnouncementLabel node in the scene
	announcement_label = $AnnouncementLabel  # Make sure to reference the correct node path

	if announcement_label:
		announcement_label.visible = false  # Hide the label by default
	else:
		print("❌ Missing AnnouncementLabel node")

	if has_node("BrakeLights"):
		print("✅ Found BrakeLights node")
	else:
		print("❌ Missing BrakeLights node")

	if has_node("UI/DirectionLabel"):
		print("✅ Found UI/DirectionLabel node")
	else:
		print("❌ Missing UI/DirectionLabel node")
>>>>>>> Stashed changes

func speed_change(delta, input):
	var air_density = 1.2
	var drag_area = 1.5
	var rolling_coef = 0.2
	var drag = 0.5 * drag_area * air_density * speed **2
	var rolling_resistance = rolling_coef * mass * 10

	var input_dir = sign(input)
	var speed_dir = sign(speed)
	print("dir: ", input_dir, "   ", speed_dir)
	var power = 0.0
	if input > 0:
		power = engine_power * 1000
	elif input < 0:
		power = reverse_power * 1000
	if speed != 0 and input != 0 and input_dir != speed_dir:
		print("1")
		var decel = braking_deceleration * speed_dir
		speed -= decel * delta
		return

	if input == 0 and speed != 0:
		print("2")
		speed = speed_dir * new_speed(rolling_resistance, drag, power, delta)
		return

	if input != 0:
		var s = new_speed(rolling_resistance, drag, power, delta)
		print(rolling_resistance, " ", drag, " ", power, " ", delta)
		print("3.1", "  ", input_dir, "  ", s)
		speed = s * input_dir
		if speed < -max_reverse_speed:
			speed = -max_reverse_speed
			print("3.2")


func new_speed(rolling, drag, power, delta):
	var kinetic_energy = (mass * abs(speed) **2) / 2.0
	var new_energy = kinetic_energy + (power - drag * abs(speed) - rolling * abs(speed)) * delta
	if new_energy > 0:
		var temp_speed = sqrt((2.0 / mass) * new_energy)
		if ((temp_speed-abs(speed))/delta) > 10.0:
			temp_speed = abs(speed) + 10 * delta
			print("overg")
			print(temp_speed)
		return temp_speed
	else:
		return 0

var steer_input = 0.0
func _physics_process(delta):
	var direction = 0

	if Input.is_action_pressed("ui_up"):
		direction = 1
	elif Input.is_action_pressed("ui_down"):
		direction = -1
	
	speed_change(delta, direction)

	velocity = Vector2.UP.rotated(rotation) * speed * m_to_px
	move_and_slide()

	# ✅ Fixed for Godot 4: stop on collision using get_slide_collision_count()
	var collision_count = get_slide_collision_count()
	if collision_count > 0:
		for i in range(collision_count):
			var collision = get_slide_collision(i)
			if collision:
				print("💥 Collision with:", collision.get_collider())
				speed = -speed * 0.2
				break

	# ✅ Realistic steering
	var steer_time = 0.3
	if Input.is_action_pressed("ui_left"):
		steer_input -= delta/steer_time
		if steer_input < -1:
			steer_input = -1
	elif Input.is_action_pressed("ui_right"):
		steer_input += delta/steer_time
		if steer_input > 1:
			steer_input = 1
	elif !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right") and steer_input != 0:
		steer_input = 0

	var min_steer_radius = 12.0
	var max_steer_radius = 20.0
	var abs_speed = abs(speed)

	if speed != 0 and steer_input != 0:
		var steer_radius = lerp(min_steer_radius, max_steer_radius, clamp(abs_speed / 100.0, 0, 1))
		var turn_amount = (speed / steer_radius) * steer_input * delta
		rotation += turn_amount
		print("↪️ Steering: speed =", speed, "turn =", turn_amount)

	speed_data.emit(speed * 3.6)
	print("📦 _physics_process: speed =", speed, "direction =", direction)
<<<<<<< Updated upstream
=======

	# Stop sign logic: Check if the car is close enough to stop
	if is_approaching_stop_sign():
		if !stopped_early:
			print("🛑 You need to stop at the stop sign.")
			# Show the announcement in the game
			if announcement_label:
				announcement_label.text = "Drive safely! You must stop at the stop sign."
				announcement_label.visible = true
			stopped_early = true
		else:
			print("✅ Stopped at the stop sign in time.")

	# 🔴 Brake lights
	if has_node("BrakeLights"):
		$BrakeLights.visible = false
		if direction == 0 and speed != 0:
			$BrakeLights.visible = true
			print("💡 Brake lights ON (idle braking)")
		elif direction != 0 and sign(direction) != sign(speed):
			$BrakeLights.visible = true
			print("💡 Brake lights ON (reversing direction)")

	# 🧭 UI direction indicator
	if has_node("UI/DirectionLabel"):
		var direction_text = "Idle"
		if speed > 0:
			direction_text = "Forward"
		elif speed < 0:
			direction_text = "Reverse"
		$UI/DirectionLabel.text = "Direction: " + direction_text
		print("🧭 Direction UI =", direction_text)

# Check if the car is approaching the stop sign
func is_approaching_stop_sign() -> bool:
	var distance = stop_position.distance_to(global_position)
	
	# Check if the car is within lane tolerance and approaching from the right plane
	return (distance < lane_tolerance) and (global_position.x > stop_position.x)
>>>>>>> Stashed changes
