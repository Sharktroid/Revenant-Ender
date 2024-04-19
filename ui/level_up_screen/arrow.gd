extends Sprite2D


func _process(delta: float) -> void:
	($Polygon2D as Polygon2D).texture_offset.y += 64.0/60 * 8 * delta
