extends Camera2D
class_name MapCamera

var map_position: Vector2i
var true_position: Vector2


func _process(delta: float) -> void:
	true_position = true_position.move_toward(map_position,
			maxf(4, (true_position.distance_to(map_position))/16) * 60 * delta)
	transform.origin = (true_position - Vector2(get_map_offset())).round()


func set_map_position(new_map_position: Vector2i) -> void:
	if Vector2(get_destination()) == transform.get_origin():
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


func move(new_map_position: Vector2i) -> void:
	set_map_position(map_position + new_map_position)


func get_low_map_position() -> Vector2i:
	return (Vector2i(MapController.map.get_size()) - Utilities.get_screen_size()) - map_position


func get_map_offset() -> Vector2i:
	var map_size: Vector2i = MapController.map.get_size()
	var screen_size: Vector2i = Utilities.get_screen_size()
	var map_offset: Vector2i = Utilities.get_screen_size() % 16 / 2
	for i: int in 2:
		if map_size[i] < screen_size[i]:
			map_offset[i] = roundi(float(screen_size[i] - map_size[i])/2)
	return map_offset


func get_destination() -> Vector2i:
	return map_position - get_map_offset()


func can_move(new_dest: Vector2i) -> bool:
	var old_pos: Vector2i = map_position
	move(new_dest)
	var answer: bool
	if map_position == old_pos:
		answer = false
	else:
		answer = true
	map_position = old_pos
	return answer
