extends Node2D

signal attributes(angle)

var controlled_cars = []

func _ready() -> void:
	var default_angle = 45
	emit_angle(default_angle)

func _on_h_slider_value_changed(value: float) -> void:
	var angle = get_node("Button/HSlider").value
	get_node("Button/HSlider/Label").text = str(angle)
	emit_angle(angle)

func emit_angle(angle: float) -> void:
	for car in controlled_cars:
		if car.has_method("set_steering_angle"):
			car.set_steering_angle(deg_to_rad(angle))
