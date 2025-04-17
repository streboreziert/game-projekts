extends Camera2D

var zooming = 0
var zoom_time = 1
var min_zoom = 0.5
var max_zoom = 3
var cur_zoom = 1
var zoom_change = 0

func _process(delta: float) -> void:
	zooming = 0
	if Input.is_key_pressed(KEY_PAGEUP):
		zooming = -1
	if Input.is_key_pressed(KEY_PAGEDOWN):
		zooming = 1
	
	zoom_change += zooming * (delta / zoom_time)
	
	if zoom_change > max_zoom:
		zoom_change = max_zoom
	if zoom_change < min_zoom:
		zoom_change = min_zoom
	
	cur_zoom = 1 / (max_zoom * zoom_change)
	
	zoom = Vector2(cur_zoom,cur_zoom)
