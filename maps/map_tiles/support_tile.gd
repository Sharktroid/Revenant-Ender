class_name SupportTile
extends MovementTile


static func instantiate(new_position: Vector2i, alpha: float) -> MovementTile:
	return _base_instantiate(preload("res://maps/map_tiles/support_tile.tscn"), new_position, alpha)
