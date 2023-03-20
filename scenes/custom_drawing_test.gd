extends Control

var image_size : Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
var outputImg : Image

@onready var output = $output

func _ready():
	$SubViewport.size = image_size
	
	$SubViewport/Line2D.add_point(Vector2.ZERO)
	$SubViewport/Line2D.add_point(Vector2(50, 50))
	
	output.texture = $SubViewport.get_texture()
	
#func bresenham_draw_linev(point1 : Vector2i, point2 : Vector2i, color : Color = Color.BLACK):
#	bresenham_draw_line(point1.x, point1.y, point2.x, point2.y, color)
#
#func bresenham_draw_line(x1 : int, y1 : int, x2 : int, y2 : int, color : Color = Color.BLACK):
#	# Iterators, counters required by algorithm
#	var x
#	var y
#	var xe
#	var ye
#
#	# Calculate line deltas
#	var dx = x2 - x1
#	var dy = y2 - y1
#	# Create a positive copy of deltas (makes iterating easier)
#	var dx1 = abs(dx)
#	var dy1 = abs(dy)
#	# Calculate error intervals for both axis
#	var px = 2 * dy1 - dx1
#	var py = 2 * dx1 - dy1
#	# The line is X-axis dominant
#	if (dy1 <= dx1):
#		# Line is drawn left to right
#		if (dx >= 0):
#			x = x1; y = y1; xe = x2
#		else: # Line is drawn right to left (swap ends)
#			x = x2; y = y2; xe = x1
#		draw_pixel(x, y, color) # Draw first pixel
#		# Rasterize the line
#		for i in range(x, xe):
#			x = x + 1
#			# Deal with octants...
#			if (px < 0):
#				px = px + 2 * dy1
#			else:
#				if ((dx < 0 && dy < 0) || (dx > 0 && dy > 0)):
#					y = y + 1
#				else:
#					y = y - 1
#
#				px = px + 2 * (dy1 - dx1)
#
#			# Draw pixel from line span at
#			# currently rasterized position
#			draw_pixel(x, y, color);
#
#	else: # The line is Y-axis dominant
#		# Line is drawn bottom to top
#		if (dy >= 0):
#			x = x1; y = y1; ye = y2
#		else: # Line is drawn top to bottom
#			x = x2; y = y2; ye = y1
#
#		draw_pixel(x, y, color) # Draw first pixel
#
#		# Rasterize the line
#		for i in range(y, ye):
#			y = y + 1;
#			# Deal with octants...
#			if (py <= 0):
#				py = py + 2 * dx1;
#			else:
#				if ((dx < 0 && dy<0) || (dx > 0 && dy > 0)):
#					x = x + 1;
#				else:
#					x = x - 1
#				py = py + 2 * (dx1 - dy1)
#
#			# Draw pixel from line span at
#			# currently rasterized position
#			draw_pixel(x, y, color);
#
#func draw_pixel(x : int, y : int, color : Color):
#	if (x >= 0 and x < image_size.x) and (y >= 0 and y < image_size.y):
#		outputImg.set_pixel(x, y, color)
#
#func draw_pixelv(pos : Vector2i, color : Color):
#	draw_pixel(pos.x, pos.y, color)
