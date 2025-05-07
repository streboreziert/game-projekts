extends TestVehicle2D
class_name WheeledVehicle2D

@onready var brakelights = $Brakes
@onready var reverse_lights = $Reverse
@onready var world_parent = get_parent()

func _process(delta: float):
	super(delta)
	_update_brake_lights()
	_update_wheels()

func _input(event):
	super(event)
	
func _update_brake_lights():
	brakelights.visible = brake > 0.1

func gear_up():
	super()
	reverse_lights.visible = gear == gears.REVERSE

func gear_down():
	super()
	reverse_lights.visible = gear == gears.REVERSE

func _update_wheels():
	var adjusted_steering = _sign_squared(steering)
	var is_moving = linear_velocity.length() > 0.1
	for wheel in wheels:
		if wheel.steers && wheel.rotation != adjusted_steering:
			wheel.update_steering(adjusted_steering)
		if is_moving:
			wheel.skid_if_skidding()
