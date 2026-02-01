extends MovementTile


static func instantiate(new_position: Vector2i, alpha: float) -> MovementTile:
	return _base_instantiate(preload("res://maps/map_tiles/warp_tile.tscn"), new_position, alpha)
