extends Label



func _on_car_data(speed: Variant) -> void:
	text = String.num_scientific(speed)
