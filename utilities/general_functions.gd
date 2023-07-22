# General functions used throughout ES
class_name GenFunc


static func slice_string(string: String, start: int, end: int) -> String:
	# Returns a substring of "string" from index "start" to index "end"
	return string.substr(start, string.length() - start - end)


static func clamp_vector(vector: Vector2, min_vector: Vector2, max_vector: Vector2) -> Vector2:
	# Clamps the values of "vector" to between those of "min_vector" and "max_vector".
	for i in range(2):
		vector[i] = clamp(vector[i], min_vector[i], max_vector[i])
	return vector


static func get_tile_distance(pos_a: Vector2, pos_b: Vector2) -> float:
	# Gets the distance between two tiles in tiles.
	return (abs(pos_a.x - pos_b.x) + abs(pos_a.y - pos_b.y))/16


static func round_coords_to_tile(coords: Vector2, offset := Vector2()) -> Vector2i:
	# Rounds "coords" to the nearest tile (16x16).
	coords -= offset
	coords = Vector2(floor(coords.x/16) * 16, floor(coords.y/16) * 16)
	return coords + offset
