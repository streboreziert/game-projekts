extends Sprite2D

var size = 100
var turn_radius = 4
var turn_time = 0.5
var turning = 0

var mass = 1500.0
#var mass1 = 0.281333

var speed = 0
var engine_power = 100
var tire_grip = 0.4
var braking = 10

var reverse_gear = 15

var acceleration = 0
var acceleration_time = 2

signal data(speed)
var debug = ""

func speed_change(delta, input):
	var air_density = 0.0012
	var drag_area = 0.5
	var resistance = 0.0
	
	#var D_speed = 0
	#if acceleration < 1:
		#acceleration += delta / acceleration_time
	
	var power = 0
	if speed >= 0:
		debug += "speed: " + String.num(speed)
		
		resistance = ((1.0/2.0) * drag_area * air_density * speed ** 2)
		var kinetic_energy = (mass * speed ** 2)/2.0
		
		debug += " Resistance: " + String.num(resistance)
		debug += " Energy: " + String.num(kinetic_energy)
		if input > 0:
			power = engine_power * 1000
			#flag = 1
		
		#D_speed = flag * sqrt((power*1000 - flag * (1/2 * air_density * drag_area * speed**2) / mass) * 2 / mass)
		debug += " Hz: " + String.num((2/mass) * (kinetic_energy + power * delta - resistance * delta))
		speed = sqrt((2.0/mass) * (kinetic_energy + power * delta - resistance * speed * delta))
		
		if input < 0:
			speed -= braking * delta
		#speed += D_speed * delta
	if speed < 0:
		if input > 0:
			speed += braking * delta
		if input < 0 and -speed < reverse_gear:
			speed += engine_power * delta * input * acceleration
			
	#if input == 0:
		#if speed != 0:
			#if speed > 0:
				#speed -= resistance * delta
				#if speed <0:
					#speed = 0
			#elif speed < 0:
				#speed += resistance * delta
				#if speed > 0:
					#speed = 0
	
func rotation_change(turn, delta):
	var ang_rot = speed / (turn_radius * 2 * PI)
	if turning < 1:
		turning += delta / turn_time
	rotation += 2 * PI * ang_rot * delta * turn * turning

func _process(delta: float) -> void:
	debug = ""
	var direction = Vector2.UP.rotated(rotation) * speed
	
	position += direction
	
	var gas = 0
	if Input.is_action_pressed("ui_up"):
		gas = 1
	if Input.is_action_pressed("ui_down"):
		gas = -1
	speed_change(delta, gas)
	
	
	var turn = 0
	if Input.is_action_pressed("ui_right"):
		turn = 1
	if Input.is_action_pressed("ui_left"):
		turn = -1
	rotation_change(turn, delta)
	data.emit(speed)
	
	print(debug)
