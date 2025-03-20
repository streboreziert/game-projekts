extends Label

var prev_speed = 0
var t = Time.get_datetime_dict_from_system()

func _on_car_data(speed: Variant) -> void:
	text = String.num_scientific(round(speed))
	text += " km/h"
	#text += "\n"
	#var delta = Time.get_datetime_dict_from_system() - t
	#text += String.num((speed - prev_speed)/delta)
	#prev_speed = speed
