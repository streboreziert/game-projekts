extends Node2D
var _100m = 10000
var _10m = 1000

var total_length = 0  # Tracks total length of all lines

func _ready():
	spawn_line(0, true)        # First line at x = 0, include length display
	spawn_line(_10m, false)    # Second line at x = 1000px (10m), no length display
	spawn_line(_10m * 2, false) # Third line at x = 2000px (20m), no length display

func spawn_line(offset_x, show_length):
	var line = Line2D.new()  # Create new Line2D
	add_child(line)  # Add to scene

	line.width = 100  # Set line thickness
	line.default_color = Color(1, 1, 1)  # White color

	# Define start and end points (100m long)
	var start_point = Vector2(offset_x, 0)
	var end_point = Vector2(offset_x, 0)

	for x in range(10):
		line.add_point(start_point)
		line.add_point(end_point)
		if show_length:  # Only add label if show_length is true
			add_label(start_point, total_length)
		total_length += _100m
		start_point.y -= _100m
		end_point.y -= _100m

func add_label(position, distance):
	var label = Label.new()
	label.text = str(distance / 100, "m")  # Convert to meters
	label.set_position(position + Vector2(20, 0))  # Offset for readability
	label.add_theme_font_size_override("font_size", 500)  # Bigger label
	add_child(label)
