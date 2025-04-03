extends Label

func _on_car_speed_data(speed: Variant) -> void:
	text = String.num_scientific(round(speed))
	text += " km/h"
