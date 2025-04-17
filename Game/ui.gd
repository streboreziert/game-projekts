extends Node2D



signal attributes(angle)
func _ready() -> void:
	var default_angle = 45
	attributes.emit(default_angle * PI / 180)
	
func _on_h_slider_value_changed(value: float) -> void:
	var angle = get_node("Button/HSlider").value
	get_node("Button/HSlider/Label").text = String.num(angle)
	attributes.emit(PI * angle / 180)
