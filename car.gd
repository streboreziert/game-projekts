extends Sprite2D
var m_to_px = 100 # 1m = 100 px

var turn_radius = 10
#var turn_time = 0.5
#var turning = 0

var mass = 1500.0

var speed = 0
var engine_power = 300
var tire_grip = 0.4
var braking_deceleration = 10

var reverse_gear = 15

var acceleration = 0
var acceleration_time = 2

signal data(speed)
var debug = ""

#func _init() -> void:
	#var x_size = 227
	#var y_size = 500
	
func new_speed(rolling, drag, braking, power, delta):
	var kinetic_energy = (mass * abs(speed) ** 2)/2.0
	
	
	
	if (kinetic_energy + (power - drag * abs(speed) - rolling*abs(speed)) * delta) - braking * delta < 0:
		return 0
	else:
		return (sqrt( (2.0/mass) * (kinetic_energy + (power - drag * abs(speed) - rolling*abs(speed)) * delta)) - braking * delta)

func speed_change(delta, input):
	var speed_old = speed
	var air_density = 1.2
	var drag_area = 1.5
	var rolling_coef = 0.2
	var drag = (0.5 * drag_area * air_density * speed ** 2)
	var rolling_resistance = rolling_coef * mass * 10
	
	var power = 0
	
	var braking_force = 0
	
	if speed * input > 0:
		power = engine_power * 1000
		
	if speed * input < 0:
		braking_force = braking_deceleration
	
	if speed == 0 and input != 0:
		power = engine_power
		speed = input * new_speed(rolling_resistance,drag,braking_force,power,delta)
		
		if (speed-speed_old)/delta > 10:
			speed = speed_old + 10 * delta
	else:
		var dir = 0
		if speed > 0:
			dir = 1
		if speed < 0:
			dir = -1
	
		speed = dir * new_speed(rolling_resistance,drag,braking_force,power,delta)
	
	if (speed-speed_old)/delta > 10:
		speed = speed_old + 10 * delta
	
func rotation_change(turn, delta):
	var ang_rot = speed*m_to_px / (turn_radius * m_to_px * 2 * PI)
	#if turning < 1:
		#turning += delta / turn_time
	rotation += 2 * PI * ang_rot * delta * turn

var line = 0
var prev_dir = 1
func lane_change(dir, pos, rot, delta):
	#signal lanes(dir, pos, )
	if dir != 0:
		prev_dir = dir
	var lane_width = 10
	if dir != 0 or changing_lanes:
		changing_lanes = true
		position = pos + Vector2.UP.rotated(rot + PI/2 * prev_dir) * speed / lane_width * m_to_px * delta
		line += speed/lane_width * delta
		debug = String.num(line)
		
		if line >= lane_width:
			changing_lanes = false
			line = 0
			prev_dir = 0
	
		


var changing_lanes = false
func _process(delta: float) -> void:
	#debug = ""
	var direction = Vector2.UP.rotated(rotation) * speed * m_to_px * delta
	
	position += direction
	
	var gas = 0
	if Input.is_action_pressed("ui_up"):
		gas = 1
	if Input.is_action_pressed("ui_down"):
		gas = -1
	speed_change(delta, gas)
	
	
	var turn = 0
	if Input.is_action_pressed("ui_right") and !changing_lanes:
		turn = 1
	if Input.is_action_pressed("ui_left") and !changing_lanes:
		turn = -1
	rotation_change(turn, delta)
	#lane_change(turn,position,rotation, delta)
	data.emit(speed*3.6)
	
	print(debug)
