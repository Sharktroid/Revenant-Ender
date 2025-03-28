## A [Camera2D] that scrolls around the map, with measures to prevent it from going out of bounds.
class_name MapCamera
extends Camera2D

## The position of the top-left corner of the screen relative to the map offset.
var _map_position: Vector2i:
	set = _set_map_position
# The unrounded position.
@onready var _true_position: Vector2 = get_destination()


func _process(delta: float) -> void:
	_true_position = _true_position.move_toward(
		get_destination(), maxf(1, (position.distance_to(get_destination())) / 16) * 4 * 60 * delta
	)
	position = _true_position.round()


## Moves the camera relative to its current position.
func move(new_map_position: Vector2i) -> void:
	_map_position += new_map_position


## Gets the offset of the top-left of the map.
## Keeps the map centered if it is smaller than the screen.
func get_map_offset() -> Vector2i:
	var map_offset := Vector2i()
	for i: int in 2:
		if MapController.map.get_size()[i] < Utilities.get_screen_size()[i]:
			map_offset[i] = -roundi(
				float(Utilities.get_screen_size()[i] - MapController.map.get_size()[i]) / 2
			)
	return map_offset


## Gets the destination that the MapCamera is moving towards.
func get_destination() -> Vector2i:
	return _map_position + get_map_offset()


## The position of the top-left corner of the screen relative to the map offset.
func get_map_position() -> Vector2i:
	return _map_position


## Checks if the camera can perform a move
func _can_move(new_dest: Vector2i) -> bool:
	var old_pos: Vector2i = _map_position
	move(new_dest)
	var answer: bool = _map_position != old_pos
	_map_position = old_pos
	return answer


func _set_map_position(new_map_position: Vector2i) -> void:
	if Vector2(get_destination()) == position:
		var map_size: Vector2i = MapController.map.get_size()
		var screen_size: Vector2i = Utilities.get_screen_size()
		for i: int in 2:
			if map_size[i] > screen_size[i]:
				new_map_position[i] = clampi(new_map_position[i], 0, map_size[i] - screen_size[i])
		_map_position = Utilities.round_coords_to_tile(new_map_position)
