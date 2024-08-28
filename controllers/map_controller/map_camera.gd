## A [Camera2D] that scrolls around the map, with measures to prevent it from going out of bounds.
class_name MapCamera
extends Camera2D

## The position of the top-left corner of the screen relative to the map offset.
var map_position: Vector2i:
	set = _set_map_position
var _true_position: Vector2


func _process(delta: float) -> void:
	_true_position = _true_position.move_toward(
		map_position, maxf(4, (_true_position.distance_to(map_position)) / 16) * 60 * delta
	)
	position = (_true_position - Vector2(get_map_offset())).round()


## Moves the camera relative to its current position.
func move(new_map_position: Vector2i) -> void:
	map_position += new_map_position


## Gets the offset of the top-left of the map.
## Keeps the map centered if it is smaller than the screen.
func get_map_offset() -> Vector2i:
	var map_size: Vector2i = MapController.map.get_size()
	var screen_size: Vector2i = Utilities.get_screen_size()
	var map_offset: Vector2i = Utilities.get_screen_size() % 16 / 2
	for i: int in 2:
		if map_size[i] < screen_size[i]:
			map_offset[i] = roundi(float(screen_size[i] - map_size[i]) / 2)
	return map_offset


## @deprecated
## Gets the destination that the MapCamera is moving towards.
func get_destination() -> Vector2i:
	return map_position - get_map_offset()


func _can_move(new_dest: Vector2i) -> bool:
	var old_pos: Vector2i = map_position
	move(new_dest)
	var answer: bool = map_position != old_pos
	map_position = old_pos
	return answer


func _set_map_position(new_map_position: Vector2i) -> void:
	if Vector2(get_destination()) == position:
		var map_size: Vector2i = MapController.map.get_size()
		var screen_size: Vector2i = Utilities.get_screen_size()
		for i: int in 2:
			if map_size[i] < screen_size[i]:
				new_map_position[i] = map_position[i]
			else:
				while new_map_position[i] <= -16:
					new_map_position[i] += 16
				while new_map_position[i] + screen_size[i] > (map_size[i]):
					new_map_position[i] -= 16
		map_position = Utilities.round_coords_to_tile(new_map_position)
