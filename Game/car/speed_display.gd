extends Label

var speed_info = ""
var steering_pos = ""

func _on_car_speed_data(speed: Variant) -> void:
	speed_info = String.num(round(speed)) + " km/h"
	text = speed_info


func _on_car_steering_pos(steering_input: Variant) -> void:
	steering_pos = String.num(round(steering_input*100))
	#text = steering_pos
	
#func _ready() -> void:
	#text = ""
	#text += steering_pos + " %"
	#text += "\n"
	#text += speed_info + " km/h"
	#
