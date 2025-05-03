extends CharacterBody2D

var m_to_px = 100 * scale[0]
var speed = 0
var engine_power = 100
var reverse_power = engine_power * 0.6
var braking_deceleration = 10.0
var max_reverse_speed = 30.0 / 3.6
var mass = 1

var tire_grip = 0.2
var acceleration = 0
var acceleration_time = 2
signal speed_data(speed)

func _ready():
	z_index = 100

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
