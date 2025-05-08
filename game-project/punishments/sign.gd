extends Node2D

var car_inside := false
var timer := 0.0
var last_position := Vector2.ZERO
var valid_stop := false
var car_ref: Node2D = null

const STOP_TOLERANCE := 5.0  # pixels of allowed movement

func _ready():
	print("✅ sign.gd script is running and ready")

func _on_area_2d_body_entered(body):
	print("🚗 ENTERED:", body.name)
	car_inside = true
	timer = 0.0
	valid_stop = false
	car_ref = body
	last_position = body.global_position

func _on_area_2d_body_exited(body):
	print("🏁 EXIT:", body.name)

	if car_inside:
		if valid_stop:
			print("✅ STOP ok — no penalty")
		else:
			print("❌ MOVED — Penalty applied")
			punish.emit(1)

	print("🔁 Zone reset. Ready for next entry.")

	car_inside = false
	timer = 0.0
	valid_stop = false
	car_ref = null

signal punish(n)
func _process(delta):
	if car_inside and car_ref != null:
		var dist = car_ref.global_position.distance_to(last_position)

		if dist < STOP_TOLERANCE:
			timer += delta
			if timer >= 1.0 and not valid_stop:
				print("🛑 STOPPED for 1s — accepted")
				valid_stop = true
		else:
			timer = 0.0
			last_position = car_ref.global_position
			# Do not set penalty yet — wait until exit
