class_name AttackTile
extends MovementTile


static func instantiate(new_position: Vector2i, alpha: float) -> AttackTile:
	return _base_instantiate(preload("res://maps/map_tiles/attack_tile.tscn"), new_position, alpha)
