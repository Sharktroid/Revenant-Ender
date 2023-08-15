# General functions used throughout ES
class_name GenFunc


static func slice_string(string: String, start: int, end: int) -> String:
	# Returns a substring of "string" from index "start" to index "end"
	return string.substr(start, string.length() - start - end)


static func get_tile_distance(pos_a: Vector2, pos_b: Vector2) -> float:
	# Gets the distance between two tiles in tiles.
	return (absf(pos_a.x - pos_b.x) + absf(pos_a.y - pos_b.y))/16


static func round_coords_to_tile(coords: Vector2, offset := Vector2()) -> Vector2i:
	# Rounds "coords" to the nearest tile (16x16).
	coords -= offset
	coords = Vector2(floori(coords.x/16) * 16, floori(coords.y/16) * 16)
	return coords + offset


static func sync_animation(animation_player: AnimationPlayer) -> void:
	var seconds: float = float(Time.get_ticks_msec())/1000
	var seconds_mod: float = fmod(seconds, animation_player.current_animation_length)
	animation_player.seek(seconds_mod)
