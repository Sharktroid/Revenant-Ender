extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
#	var base_cross: Node2D = $"Base Cross"
#	var x_offset: int = GenVars.get_screen_size().x % 128 / 2
#	var y_offset: int = GenVars.get_screen_size().y % 128 / 2
#	for x in GenVars.get_screen_size().x / 128:
#		for y in ceil((GenVars.get_screen_size().y as float) / 128):
#			var new_cross: Node2D = base_cross.duplicate()
#			new_cross.position = Vector2i(x * 128 - x_offset, y * 128 - y_offset)
#			$"Features/Line Container".add_child(new_cross)
#	base_cross.queue_free()
