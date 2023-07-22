extends Camera2D
class_name MapCamera

var map_offset := Vector2i()
var map_position: Vector2i
var true_origin: Vector2


func _enter_tree() -> void:
	GenVars.map_camera = self


func _ready():
	update_offset()
	true_origin = map_position


func _physics_process(_delta):
	var speed: float = max(4, (true_origin.distance_to(map_position))/16)
	true_origin = true_origin.move_toward(map_position, speed)
	transform.origin = true_origin - Vector2(map_offset)


func _input(event):
	if event.is_action_pressed("debug"):
		update_offset()


func set_map_position(new_map_position: Vector2i):
	if Vector2(get_destination()) == transform.get_origin():
		var map_size: Vector2i = GenVars.map.get_size()
		var screen_size: Vector2i = GenVars.get_screen_size()
		for i in 2:
			if map_size[i] < screen_size[i]:
				new_map_position[i] = map_position[i]
			else:
				while new_map_position[i] <= -16:
					new_map_position[i] += 16
				while new_map_position[i] + screen_size[i] > (map_size[i]) + 16:
					new_map_position[i] -= 16
		map_position = GenFunc.round_coords_to_tile(new_map_position)


func move(new_map_position: Vector2i):
	set_map_position(map_position + new_map_position)


func get_low_map_position() -> Vector2i:
	return (GenVars.map.get_size() - GenVars.get_screen_size()) - map_position


func update_offset() -> void:
	var map_size: Vector2i = GenVars.map.get_size()
	var screen_size: Vector2i = GenVars.get_screen_size()
	map_offset = GenVars.get_screen_size() % 16 / 2
	for i in 2:
		if map_size[i] < screen_size[i]:
			map_offset[i] = round(screen_size[i] - map_size[i])/2
	GenVars.cursor.move(Vector2i())


func get_destination() -> Vector2i:
	return map_position - map_offset


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
