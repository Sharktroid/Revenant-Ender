extends Node2D


# Called when the node enters the scene tree for the first time.
func _draw() -> void:
	var top_bounds: Vector2i = Vector2i(4, 4)
	var bottom_bounds: Vector2i = get_viewport().size/GenVars.get_scaling() - Vector2i(4, 4)
#	var bottom_bounds_a = bottom_bounds - top_bounds
#	var bottom_bounds_b = bottom_bounds - Vector2i(4, 4)
#	for i in 2:
#		top_bounds[i] = max(top_bounds[i], 4)
#		bottom_bounds[i] = min(bottom_bounds_a[i], bottom_bounds_b[i])
#		var coord = GenVars.get_map_camera().transform.get_origin()[i]
#		if coord == 0:
#			top_bounds[i] = 0
#		elif coord == -(GenVars.get_map().get_size()[i] - GenVars.get_screen_size()[i]):
#			bottom_bounds[i] += 16

	var size = get_viewport().size
	draw_polygon([Vector2(0, 0), Vector2(size.x, 0), Vector2(size.x, top_bounds.y), Vector2(0, top_bounds.y)], [Color.YELLOW])
	draw_polygon([Vector2(0, 0), Vector2(0, size.y), Vector2(top_bounds.x, size.x), Vector2(top_bounds.x, 0)], [Color.YELLOW])
	draw_polygon([size, Vector2(0, size.y), Vector2(0, bottom_bounds.y), Vector2(size.x, bottom_bounds.y)], [Color.YELLOW])
	draw_polygon([size, Vector2(size.x, 0), Vector2(bottom_bounds.x, 0), Vector2(bottom_bounds.x, size.y)], [Color.YELLOW])
