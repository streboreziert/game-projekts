extends CharacterBody2D

var m_to_px = 100 * scale[0]
var speed = 0
var engine_power = 143
var reverse_power = engine_power * 1
var braking_deceleration = 10.0
var max_reverse_speed = 30.0 / 3.6
var mass = 1500

var steer_time = 0.7
var steering_linearity = 1.3
var centering_time = steer_time / 2
var steer_input = 0.0

var acceleration_time = 1
var acceleration_linearity = 0.6
var deceleration_time = 0.2
var direction = 0

var car_length = 4.2
#var max_steering_angle = PI * (45.0/180.0)
var max_steering_angle


var max_g_force = 1000.0

signal speed_data(speed)
signal steering_pos(steering_input)

func _ready():
	max_steering_angle = 45 * PI / 180
	z_index = 100

func speed_change(delta, input):
	var air_density = 1.2
	var drag_area = 1.5
	var rolling_coef = 0.2
	var drag = 0.5 * drag_area * air_density * speed **2
	var rolling_resistance = rolling_coef * mass * 10

	var input_dir = sign(input)
	var speed_dir = sign(speed)
	var power = 0.0
	if input > 0:
		power = engine_power * 1000 * abs(input)
	elif input < 0:
		power = reverse_power * 1000 * abs(input)
	if speed != 0 and input != 0 and input_dir != speed_dir:
		var decel = braking_deceleration * speed_dir
		if abs(speed) < abs(decel * delta):
			speed = 0
		else:
			speed -= decel * delta
		return

	if input == 0 and speed != 0:
		speed = speed_dir * new_speed(rolling_resistance, drag, power, delta)
		return

	if input != 0:
		var s = new_speed(rolling_resistance, drag, power, delta)
		speed = s * input_dir
		if speed < -max_reverse_speed:
			speed = -max_reverse_speed


func new_speed(rolling, drag, power, delta):
	var kinetic_energy = (mass * abs(speed) **2) / 2.0
	var new_energy = kinetic_energy + (power - drag * abs(speed) - rolling * abs(speed)) * delta
	if new_energy > 0:
		var temp_speed = sqrt((2.0 / mass) * new_energy)
		if ((temp_speed-abs(speed))/delta) > max_g_force:
			temp_speed = abs(speed) + max_g_force * delta
			#print("overg")
			#print(temp_speed)
		return temp_speed
	else:
		return 0

func _physics_process(delta):
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		direction += delta / acceleration_time
		if direction > 1:
			direction = 1
	elif Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		direction -= delta / deceleration_time
		if direction < -1:
			direction = -1
	else:
		direction = 0

	speed_change(delta, sign(direction) * abs(direction) ** acceleration_linearity)

	velocity = Vector2.UP.rotated(rotation) * speed * m_to_px
	move_and_slide()

	var collision_count = get_slide_collision_count()
	if collision_count > 0:
		for i in range(collision_count):
			var collision = get_slide_collision(i)
			if collision:
				var min_speed = 5.0 / 3.6  # 5 km/h in m/s ≈ 1.39
				if abs(speed) > min_speed:
					speed = sign(speed) * min_speed
				velocity = velocity.bounce(collision.get_normal())
				break

	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		steer_input -= delta / steer_time
		if steer_input > 0:
			steer_input -= delta / steer_time
		if steer_input < -1:
			steer_input = -1
	elif Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		steer_input += delta / steer_time
		if steer_input < 0:
			steer_input += delta / steer_time
		if steer_input > 1:
			steer_input = 1
	elif !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right") and steer_input != 0:
		if abs(sign(steer_input) * delta / centering_time) > abs(steer_input):
			steer_input = 0
		else:
			steer_input -= sign(steer_input) * delta / centering_time

	var steer_pos = steer_input
	if steer_input != 0:
		var steering_radius = car_length / abs(cos(PI / 2 - abs(steer_input * max_steering_angle)))
		var side_g_force = abs(speed) ** 2 / steering_radius
		if side_g_force > max_g_force:
			steering_radius = abs(speed) ** 2 / max_g_force
			steer_pos = sign(steer_input) * (PI / 2 - acos(car_length / steering_radius)) / max_steering_angle
		rotation += (speed / steering_radius) * steer_input * delta

	speed_data.emit(speed * 3.6)
	steering_pos.emit(steer_pos)
func _on_ui_attributes(angle: Variant) -> void:
	max_steering_angle = angle
