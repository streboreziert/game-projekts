extends Sprite2D


func _on_car_steering_pos(steering_input: Variant) -> void:
	rotation = 2*PI * steering_input
